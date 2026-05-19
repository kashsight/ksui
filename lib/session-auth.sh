#!/data/data/com.termux/files/usr/bin/env bash
# cvui — session lock. Runs auth::login on shell startup.
# Skipped if: stdin is not a tty, no creds set up yet, or the user has
# opted out via `touch ~/.cvui/no-lock`.

cvui_HOME="${cvui_HOME:-$HOME/cvui}"
cvui_CFG="${cvui_CFG:-$HOME/.cvui}"

# Don't lock non-interactive shells, scripts, or cvui's own REPL.
[[ -t 0 && -t 1 ]] || exit 0
[[ -n $cvui_REPL ]] && exit 0
[[ -f "$cvui_CFG/no-lock" ]] && exit 0

# If creds haven't been created yet, run setup so the user has something
# to log in with. Skip silently if the auth lib is missing.
[[ -r "$cvui_HOME/lib/ui.sh"       ]] && source "$cvui_HOME/lib/ui.sh"
[[ -r "$cvui_HOME/lib/auth.sh"     ]] || exit 0
[[ -r "$cvui_HOME/lib/commands.sh" ]] && source "$cvui_HOME/lib/commands.sh"
[[ -r "$cvui_HOME/lib/update.sh"   ]] && source "$cvui_HOME/lib/update.sh"

# Check for updates before authentication bypass
if command -v update::check >/dev/null 2>&1; then
  update::check
fi

[[ -n $cvui_REPL ]] && exit 0
[[ -f "$cvui_CFG/no-lock" ]] && exit 0

source "$cvui_HOME/lib/auth.sh"

# Render a small banner so the lock screen feels intentional.
clear 2>/dev/null
[[ -x "$cvui_HOME/motd/motd.d/10-cvui-logo" ]] \
  && "$cvui_HOME/motd/motd.d/10-cvui-logo"

if [[ ! -f "$cvui_AUTH" ]]; then
  auth::setup
fi
auth::login || {
  # Lockdown: refuse to drop the user at a usable shell.
  printf '\n%sShell locked.%s Close this session and try again.\n' \
    "${C_RED:-}" "${C_RESET:-}"
  exec sleep 86400
}
