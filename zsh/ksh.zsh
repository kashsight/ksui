# KSH — cybervaultke Shell framework
# A small, self-contained zsh framework. Replaces oh-my-zsh for cvui users.
# Everything is custom-made in-house.

: ${KSH_HOME:=${0:A:h}}
export KSH_HOME

# ── 1. history ────────────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_HISTORY:-0} )); then
  HISTFILE=${HISTFILE:-$HOME/.zsh_history}
  HISTSIZE=50000
  SAVEHIST=50000
  setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
  setopt SHARE_HISTORY APPEND_HISTORY INC_APPEND_HISTORY
fi

# ── 2. completion ─────────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_COMPLETION:-0} )); then
  autoload -Uz compinit
  compinit -C 2>/dev/null
  zstyle ":completion:*" menu select
  zstyle ":completion:*" matcher-list "m:{a-zA-Z}={A-Za-z}"
  zstyle ":completion:*" list-colors ""
fi

# ── 3. custom key bindings & history search ──────────────────────────────
bindkey -e  # emacs-style

# In-house history prefix search
_ksh_h_pos=0
_ksh_h_query=""

_ksh_history_search_backward() {
  if [[ $LASTWIDGET != _ksh_history_search_* ]]; then
    _ksh_h_query=$LBUFFER
    _ksh_h_pos=$HISTCMD
  fi
  
  if [[ -z $_ksh_h_query ]]; then
    zle .up-line-or-history
    return
  fi

  local i=$_ksh_h_pos
  while (( --i > 0 )); do
    if [[ $history[$i] == $_ksh_h_query* && $history[$i] != $BUFFER ]]; then
      BUFFER=$history[$i]
      CURSOR=${#BUFFER}
      _ksh_h_pos=$i
      return
    fi
  done
}

_ksh_history_search_forward() {
  if [[ $LASTWIDGET != _ksh_history_search_* ]]; then
    zle .down-line-or-history
    return
  fi

  local i=$_ksh_h_pos
  while (( ++i < HISTCMD )); do
    if [[ $history[$i] == $_ksh_h_query* && $history[$i] != $BUFFER ]]; then
      BUFFER=$history[$i]
      CURSOR=${#BUFFER}
      _ksh_h_pos=$i
      return
    fi
  done
  
  if [[ $i -ge $HISTCMD ]]; then
    BUFFER=$_ksh_h_query
    CURSOR=${#BUFFER}
    _ksh_h_pos=$HISTCMD
  fi
}

zle -N _ksh_history_search_backward
zle -N _ksh_history_search_forward
bindkey "^[[A" _ksh_history_search_backward
bindkey "^[[B" _ksh_history_search_forward
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# ── 4. plugins ──────────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_AUTOSUGGEST:-0} )); then
  [[ -f "$KSH_HOME/plugins/autosuggestions/autosuggestions.zsh" ]] &&     source "$KSH_HOME/plugins/autosuggestions/autosuggestions.zsh"
fi

if (( ! ${KSH_SKIP_Z:-0} )); then
  [[ -f "$KSH_HOME/plugins/z/z.sh" ]] && source "$KSH_HOME/plugins/z/z.sh"
fi

if (( ! ${KSH_SKIP_SYNTAX:-0} )); then
  [[ -f "$KSH_HOME/plugins/syntax-highlighting/syntax-highlighting.zsh" ]] &&     source "$KSH_HOME/plugins/syntax-highlighting/syntax-highlighting.zsh"
fi

# ── 5. prompt theme ──────────────────────────────────────────────────────
if (( ! ${KSH_SKIP_THEME:-0} )); then
  local _ksh_theme="cvui"
  [[ -f "$HOME/.cvui/theme" ]] && _ksh_theme=$(<"$HOME/.cvui/theme")
  [[ -f "$KSH_HOME/themes/${_ksh_theme}.zsh-theme" ]] && source "$KSH_HOME/themes/${_ksh_theme}.zsh-theme"
  unset _ksh_theme
fi

# ── 6. in-house ls with icons ───────────────────────────────────────────
_cvui_ls() {
  ls -F --color=auto "$@" | while read -r line; do
    local icon="📄"
    case "$line" in
      */*) icon="📂" ;;
      *\*) icon="🏗" ;;
      *.sh) icon="🏗" ;;
      *.md) icon="📝" ;;
      *.txt) icon="📄" ;;
      *.py|*.js|*.go|*.c|*.cpp) icon="⚙️" ;;
    esac
    printf "%s  %s\n" "$icon" "$line"
  done
}

alias ls="_cvui_ls"
alias ll="_cvui_ls -lh"
alias la="_cvui_ls -lah"

# ── 7. other aliases ────────────────────────────────────────────────────
alias ..="cd .."
alias c="clear"
alias gs="git status"

# session lock
if (( ! ${KSH_SKIP_AUTH:-0} )) && [[ -o interactive && -z $cvui_REPL ]]; then
  [[ -x "$KSH_HOME/../lib/session-auth.sh" ]] && "$KSH_HOME/../lib/session-auth.sh"
fi

# motd
if (( ! ${KSH_SKIP_MOTD:-0} )) && [[ -o interactive ]]; then
  _ksh_motd="$KSH_HOME/../motd/init.sh"
  if [[ -r $_ksh_motd ]]; then
    _cvui_show_motd() {
      [[ -x $_ksh_motd ]] && "$_ksh_motd" || bash "$_ksh_motd"
      add-zsh-hook -d precmd _cvui_show_motd
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _cvui_show_motd
  fi
fi
