# cvui prompt theme: forest — dark green, two-line, no external deps
#
# Layout matches cvui.zsh-theme but with a forest-green palette.

autoload -U colors && colors
autoload -U add-zsh-hook
setopt PROMPT_SUBST

zmodload zsh/datetime 2>/dev/null

_cvui_t0=0
_cvui_timer_start() { _cvui_t0=$EPOCHSECONDS; }
_cvui_timer_stop()  {
  _cvui_LAST_STATUS=$?
  if (( _cvui_t0 )); then
    _cvui_LAST_DUR=$(( EPOCHSECONDS - _cvui_t0 ))
    _cvui_t0=0
  else
    _cvui_LAST_DUR=0
  fi
}
add-zsh-hook preexec _cvui_timer_start
add-zsh-hook precmd  _cvui_timer_stop

_cvui_git() {
  command -v git >/dev/null 2>&1 || return
  local b
  b=$(command git symbolic-ref --short HEAD 2>/dev/null) \
    || b=$(command git rev-parse --short HEAD 2>/dev/null) \
    || return
  local dirty
  if [[ -n $(command git status --porcelain 2>/dev/null) ]]; then
    dirty='%F{220}±%f'
  else
    dirty='%F{34}✓%f'
  fi
  printf ' %%F{34}(%s)%s' "$b" "$dirty"
}

_cvui_rp() {
  local out=""
  (( ${_cvui_LAST_DUR:-0} > 1 )) && out+="%F{106}⏱ ${_cvui_LAST_DUR}s%f  "
  (( ${_cvui_LAST_STATUS:-0} != 0 )) && out+="%F{203}✖ ${_cvui_LAST_STATUS}%f"
  printf '%s' "$out"
}

# Dark forest-green path, brighter green prompt char.
PROMPT=$'\n%F{28}%~%f$(_cvui_git)\n%(?.%F{34}.%F{203})❯%f '
RPROMPT='$(_cvui_rp)%F{244} %D{%H:%M:%S}%f'
