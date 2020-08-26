
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
    [[ -n ${VIRTUAL_ENV} ]] || return
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

ret_prompt="%(?:%#:%{$fg_bold[red]%}%#%s)${RC}"

battery_prompt () {
    [[ ${LAPTOP_MODE} -eq true ]] || return
    echo "${CC}[${RC}$(battery_pct_prompt)${CC}]─"
}

if [[ ${USER} == "root" ]]; then
    PROMPT='${RC}$(battery_prompt)${CC}(${RC}$fg[red]%n${RC}${CCH}@%m${RC}${CC})─(${RC}%D{%H:%M}${CC})${RC} ${ret_prompt} '
else
    PROMPT='${RC}$(battery_prompt)${CC}(${RC}%n${CCH}@%m${RC}${CC})─(${RC}%D{%H:%M}${CC})${RC} ${ret_prompt} '
fi

RPROMPT='${CC}(${RC}%3~$(git_prompt_info)$(git_prompt_status)$(rvm_prompt_info)$(virtualenv_prompt_info)$(nvm_prompt_info)${CC})─${RC}'

