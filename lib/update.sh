#!/data/data/com.termux/files/usr/bin/env bash
# cvui — auto-update checker

update::check() {
  [[ -d "$cvui_HOME/.git" ]] || return 0
  
  # Fetch latest
  git -C "$cvui_HOME" fetch origin -q
  
  local local_hash=$(git -C "$cvui_HOME" rev-parse HEAD 2>/dev/null)
  local remote_hash=$(git -C "$cvui_HOME" rev-parse origin/main 2>/dev/null)
  
  if [[ -n "$local_hash" && -n "$remote_hash" && "$local_hash" != "$remote_hash" ]]; then
    printf "
  ${C_YELLOW}⚠ An update is available for cvui.${C_RESET}
"
    read -r -p "  Update now? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      cmd::update
    fi
  fi
}
