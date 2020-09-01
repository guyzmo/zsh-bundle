### Colours

CC="%{%B%F{${ZSH_HOST_COLOR}}%}"
CCH="%{%F{${ZSH_HOST_COLOR}}%}"
RC="%{$reset_color%}"

### Parts definition

battery_part () {
    [ -n ${LAPTOP_MODE} ] || return
    echo -n $(battery_pct_prompt)
}

venv_part () {
    [ -n ${DEV_MODE} ] || return
    [ -n ${VIRTUAL_ENV} ] || return
    echo "${VIRTUAL_ENV:t}"
}

path_part () {
  echo -n "$(shrink_path -l -t)"
}

time_part () {
  echo -n "%D{%H:%M}"
}

left_part_sq="${CC}[${RC}"
link_part_sq="${CC}]─${RC}"
right_part_sq="${CC}]${RC}"
left_part_rd="${CC}(${RC}"
link_part_rd="${CC})─${RC}"
right_part_rd="${CC})${RC}"
space_part="%f"
prompt_part="%f%(?:%#:%{$fg_bold[red]%}%#%s)${RC}"

if [[ ${USER} = "root" ]]; then
  user_part="${RC}$fg[red]%n${RC}${CCH}@%m${RC}${CC}"
else
  user_part="${RC}%n${CCH}@%m${RC}${CC}"
fi


### modules formats

# Format for git_prompt_info()
ZSH_THEME_GIT_PROMPT_PREFIX="${link_part_rd}${left_part_rd}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_STATUS_BEFORE=""
ZSH_THEME_GIT_PROMPT_STATUS_AFTER=""
ZSH_THEME_GIT_PROMPT_BRANCH_BEFORE=""
ZSH_THEME_GIT_PROMPT_BRANCH_AFTER=""
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=""
ZSH_THEME_GIT_PROMPT_SHA_AFTER=""

# Format for parse_git_dirty()
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓${RC}"

# rvm/nvm/venv
ZSH_THEME_RUBY_PROMPT_BEFORE="${link-part-rd}${left_part_rd}rvm:"
ZSH_THEME_RUBY_PROMPT_AFTER=""
ZSH_THEME_VENV_PROMPT_BEFORE="${link-part-rd}${left_part_rd}venv:"
ZSH_THEME_VENV_PROMPT_AFTER="${link-part-rd}${right_part_rd}"
ZSH_THEME_NVM_PROMPT_BEFORE="${link-part-rd}${left_part_rd}nvm:"
ZSH_THEME_NVM_PROMPT_AFTER="${link-part-rd}${right_part_rd}"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}⚑${RC}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[yellow]%}!${RC}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[yellow]%}±${RC}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}≠${RC}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[yellow]%}✚${RC}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[blue]%}…${RC}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[green]%}↑${RC}"

### prompt construction jobs

async_lprompt_job() {
  local -a parts=()
  parts+=$left_part_sq
  parts+=$(battery_part)
  parts+=$link_part_sq
  parts+=$left_part_rd
  parts+=$user_part
  parts+=$link_part_rd
  parts+=$left_part_rd
  parts+=$(time_part)
  parts+=$right_part_rd

  echo -n "${(j::)parts}"
}

sync_lprompt_job() {
  local -a parts=()
  parts+=$left_part_sq
  parts+="…"
  parts+=$link_part_sq
  parts+=$left_part_rd
  parts+=$user_part
  parts+=$link_part_rd
  parts+=$(time_part)
  parts+=$right_part_rd

  echo -n "${(j::)parts}"
}

sync_rprompt_job() {
  local -a parts=()
  parts+=$right_part_rd
  echo -n "${(j::)parts}"
}

async_rprompt_job() {
  local -a parts=()
  parts+=$(git_prompt_info)
  parts+=$(git_prompt_status)
  parts+=$(venv_part)
  parts+=$right_part_rd
  echo -n "${(j::)parts}"
}

### prompt assembly tasks

build_lprompt() {
  local -a parts=()

  if [[ "$1" != $'\0' ]]; then
    if [[ -n "$1" ]]; then
      parts+="${1}"
    else
      parts+=$sync_lprompt_job
    fi
  fi

  PROMPT="${(j::)parts} ${prompt_part} "
}

build_rprompt() {
  local -a parts=()

  parts+=$left_part_rd
  parts+=$(path_part)

  if [[ "$1" != $'\0' ]]; then
    if [[ -n "$1" ]]; then
      parts+="${1}"
    else
      parts+=$(sync_rprompt_job)
    fi
  fi

  RPROMPT="${(j::)parts}"
}

async_lprompt_response() {
  typeset -g _async_lprompt_fd

  build_lprompt "$(<&$1)"
  zle reset-prompt

  zle -F $1
  exec {1}<&-
  unset _async_lprompt_fd
}

async_rprompt_response() {
  typeset -g _async_rprompt_fd

  build_rprompt "$(<&$1)"
  zle reset-prompt

  zle -F $1
  exec {1}<&-
  unset _async_rprompt_fd
}

async_lprompt_precmd() {
  typeset -g _async_lprompt_fd

  build_lprompt $(sync_lprompt_job)

  [[ -n $_async_lprompt_fd ]] && {
    zle -F $_async_lprompt_fd
    exec {_async_lprompt_fd}<&-
  }

  exec {_async_lprompt_fd}< <(async_lprompt_job)
  zle -F $_async_lprompt_fd async_lprompt_response
}

async_rprompt_precmd() {
  typeset -g _async_rprompt_fd

  build_rprompt $(sync_rprompt_job)

  [[ -n $_async_rprompt_fd ]] && {
    zle -F $_async_rprompt_fd
    exec {_async_rprompt_fd}<&-
  }

  exec {_async_rprompt_fd}< <(async_rprompt_job)
  zle -F $_async_rprompt_fd async_rprompt_response
}

add-zsh-hook precmd async_lprompt_precmd
add-zsh-hook precmd async_rprompt_precmd
