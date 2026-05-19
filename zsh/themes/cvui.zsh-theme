# cvui prompt theme — KAI-blue, two-line, no external deps
#
# Layout:
#   [time] ~/path/to/dir  (git-branch±)
#   ❯ command...

autoload -U colors && colors
autoload -U add-zsh-hook
setopt PROMPT_SUBST

zmodload zsh/datetime 2>/dev/null

# ── command timing ────────────────────────────────────────────────────────
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

# ── git status ──────────────────────────────────────────────────────────
_cvui_git() {
  command -v git >/dev/null 2>&1 || return
  local b dirty
  b=$(command git symbolic-ref --short HEAD 2>/dev/null)     || b=$(command git rev-parse --short HEAD 2>/dev/null)     || return
  if [[ -n $(command git status --porcelain 2>/dev/null) ]]; then
    dirty="%F{221}±%f"
  else
    dirty="%F{120}✓%f"
  fi
  printf " %%F{120}(%s)%s" "$b" "$dirty"
}

# ── prompt ────────────────────────────────────────────────────────────────
PROMPT="%F{51}[%D{%H:%M:%S}] %F{120}%~%f\$(_cvui_git)%f
%(?.%F{51}.%F{203})❯%f "
RPROMPT="%F{93}%(1?. .  )%(1?.\${_cvui_LAST_DUR}s  .)%F{203}%(?..✖ %?)%f"
