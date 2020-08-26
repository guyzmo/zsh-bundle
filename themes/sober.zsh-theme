
#CC=%{$fg_bold[$ZSH_HOST_COLOR]%}
#CCH=%{$fg[$ZSH_HOST_COLOR]%}
#RC=%{$reset_color%}

CC="%{%B%F{${ZSH_HOST_COLOR}}%}"
CCH="%{%F{${ZSH_HOST_COLOR}}%}"
RC="%{$reset_color%}"

# Format for git_prompt_info()
ZSH_THEME_GIT_PROMPT_PREFIX="${CC})─(${RC}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_STATUS_BEFORE=""
ZSH_THEME_GIT_PROMPT_STATUS_AFTER=""
ZSH_THEME_GIT_PROMPT_BRANCH_BEFORE=""
ZSH_THEME_GIT_PROMPT_BRANCH_AFTER=""
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=""
ZSH_THEME_GIT_PROMPT_SHA_AFTER=""

# Format for parse_git_dirty()
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[red]%}✗${RC}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓${RC}"
ZSH_THEME_RUBY_PROMPT_BEFORE=")─(rvm:"
ZSH_THEME_RUBY_PROMPT_AFTER=""

virtualenv_prompt_info () {
    [ -n ${VIRTUAL_ENV} ] || return
    echo "${CC})─(${RC}${VIRTUAL_ENV:t}"
}

#ZSH_THEME_VENV_PROMPT_BEFORE="YYYYY"
#ZSH_THEME_VENV_PROMPT_AFTER="XXXXX"
ZSH_THEME_NVM_PROMPT_BEFORE=")─(nvm:"
ZSH_THEME_NVM_PROMPT_AFTER="$RC"

# Format for git_prompt_status()
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[red]%}⚑${RC}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[yellow]%}!${RC}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[yellow]%}±${RC}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}≠${RC}"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[yellow]%}✚${RC}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[yellow]%}…${RC}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[green]%}↑${RC}"

battery_prompt () {
    [ -n ${LAPTOP_MODE} ] || return
    echo $(battery_pct_prompt)
}

if [ ${USER} = "root" ]; then
    ZSH_THEME_PROMPT='${RC}$(battery_prompt)${CC}(${RC}$fg[red]%n${RC}${CCH}@%m${RC}${CC})─(${RC}%D{%H:%M}${CC})${RC} ${ret_prompt} '
else
    ZSH_THEME_PROMPT='${RC}$(battery_prompt)${CC}(${RC}%n${CCH}@%m${RC}${CC})─(${RC}%D{%H:%M}${CC})${RC} ${ret_prompt} '
fi

ZSH_THEME_RPROMPT='${CC}(${RC}%3~$(git_prompt_info)$(git_prompt_status)$(rvm_prompt_info)$(virtualenv_prompt_info)$(nvm_prompt_info)${CC})─${RC}'

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

async_lprompt_job() {
  local -a parts=()
  parts+=$left_part_sq
  parts+=$(battery_prompt)
  parts+=$link_part_sq
  echo -n "${(j::)parts}"
}

sync_lprompt_job() {
  local -a parts=()
  parts+=$left_part_sq
  parts+="…"
  parts+=$link_part_sq
  echo -n "${(j::)parts}"
}

sync_rprompt_job() {
  local -a parts=()
  parts+=${link_part_rd}
  echo -n "${(j::)parts}"
}

async_rprompt_job() {
  local -a parts=()
  parts+=$(git_prompt_info)
  parts+=$(git_prompt_status)
  parts+=${link_part_rd}
  echo -n "${(j::)parts}"
}

build_lprompt() {
  local -a parts=()

  if [[ "$1" != $'\0' ]]; then
    if [[ -n "$1" ]]; then
      parts+="${1}"
    else
      parts+=$sync_lprompt_job
    fi
  fi

  parts+=$left_part_rd
  parts+=$user_part
  parts+=$right_part_rd

  PROMPT="${(j::)parts} ${prompt_part} "
}

build_rprompt() {
  local -a parts=()

  parts+=$left_part_rd
  parts+="${${PWD/#$HOME/~}//(#b)([^\/])[^\/][^\/]#\//$match[1]/}"

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
