#!/data/data/com.termux/files/usr/bin/env bash
# cvui — built-in commands

cmd::help() {
  cat <<EOF

${C_CYAN}${C_BOLD}cvui Commands${C_RESET}
${C_GRAY}──────────────────────────────${C_RESET}
  ${C_GREEN}help${C_RESET}           Show this menu
  ${C_GREEN}about${C_RESET}          About the maker (cybervaultke)
  ${C_GREEN}ask${C_RESET} <q...>     Ask KAI anything (uses tgpt)
  ${C_GREEN}joke${C_RESET}           Tell a joke (tgpt, random topic)
  ${C_GREEN}fact${C_RESET}           Random fun fact (tgpt, random topic)
  ${C_GREEN}meme${C_RESET}           Fetch a random meme
  ${C_GREEN}news${C_RESET}           Top headlines (Hacker News)
  ${C_GREEN}crypto${C_RESET} [coin]  Crypto price (CoinGecko)
  ${C_GREEN}ip${C_RESET}             Public IP + geo (ipinfo.io)
  ${C_GREEN}define${C_RESET} <word>  Dictionary lookup
  ${C_GREEN}weather${C_RESET} [city] Current weather (wttr.in)
  ${C_GREEN}sysinfo${C_RESET}        System info (neofetch if available)
  ${C_GREEN}qr${C_RESET} <text>      Render a QR code in the terminal
  ${C_GREEN}note${C_RESET} <text>    Append a timestamped note
  ${C_GREEN}notes${C_RESET}          Show all notes
  ${C_GREEN}todo${C_RESET} [text]    Add/list todo items (todo done N to check off)
  ${C_GREEN}timer${C_RESET} <min>    Pomodoro timer with voice alert
  ${C_GREEN}time${C_RESET}       Live clock with hacker UI
  ${C_GREEN}calc${C_RESET}       Terminal calculator
  ${C_GREEN}bible${C_RESET}      Bible verse lookup
  ${C_GREEN}apps${C_RESET}       Launcher listing cvui apps
  ${C_GREEN}doctor${C_RESET}         Audit optional deps + cvui health
  ${C_GREEN}motd${C_RESET}           Reprint the banner
  ${C_GREEN}banner${C_RESET} <text>   Build a custom banner (a-z/0-9 only)
  ${C_GREEN}time${C_RESET} / ${C_GREEN}date${C_RESET}    Current date and time
  ${C_GREEN}ls${C_RESET} / ${C_GREEN}ll${C_RESET}       List files with icons
  ${C_GREEN}cd${C_RESET} <dir>       Change directory
  ${C_GREEN}clear${C_RESET} / ${C_GREEN}cls${C_RESET}   Clear screen
  ${C_GREEN}voice${C_RESET} on|off   Toggle KAI voice
  ${C_GREEN}theme${C_RESET} [name]   List / switch prompt theme
  ${C_GREEN}noauth${C_RESET} on|off  Toggle session lock (auth)
  ${C_GREEN}update${C_RESET}         git pull + re-run installer
  ${C_GREEN}whoami${C_RESET}         Show logged-in user
  ${C_GREEN}reset-auth${C_RESET}     Reset username/password
  ${C_GREEN}exit${C_RESET} / ${C_GREEN}quit${C_RESET}   Shut down cvui
${C_GRAY}──────────────────────────────${C_RESET}
Any other input is passed to your shell.

EOF
}

cmd::about() {
  ui::banner
  ui::maker_intro
}

cmd::_need_tgpt() {
  if ! command -v tgpt >/dev/null 2>&1; then
    ui::say_status ERR "tgpt not installed. Run: pkg install tgpt  (or see README)"
    return 1
  fi
}

cmd::_need_curl() {
  if ! command -v curl >/dev/null 2>&1; then
    ui::say_status ERR "curl is required for this command"
    return 1
  fi
}

cmd::ask() {
  cmd::_need_tgpt || return 1
  local q="$*"
  [[ -z $q ]] && { ui::say_status WARN "Usage: ask <question>"; return 1; }
  printf "${C_BLUE}🤖 KAI:${C_RESET}\n"
  tgpt "$q"
}

cmd::joke() {
  cmd::_need_tgpt || return 1
  local topics=(programming science animals food coffee space "dad joke" music
                math cats dogs AI robots aliens pirates ninjas wizards)
  local t=${topics[RANDOM % ${#topics[@]}]}
  local nonce=$RANDOM
  printf "${C_YELLOW}😄${C_RESET} "
  local joke; joke=$(tgpt "Tell me ONE fresh short clean genuinely funny joke about $t. Different from your last one. Just the joke, no preamble. [seed=$nonce]" 2>/dev/null); printf "%s\n" "$joke"; voice::say "$joke"
}

cmd::fact() {
  cmd::_need_tgpt || return 1
  local topics=(history biology physics space oceans animals "ancient civilizations"
                psychology geography chemistry technology music language food
                mathematics medicine sports "deep sea" insects)
  local t=${topics[RANDOM % ${#topics[@]}]}
  local nonce=$RANDOM
  printf "${C_CYAN}💡${C_RESET} "
  local fact; fact=$(tgpt "Give me ONE surprising fun fact about $t in 1-2 sentences. Something most people don't know. No preamble. [seed=$nonce]" 2>/dev/null); printf "%s\n" "$fact"; voice::say "$fact"
}

cmd::meme() {
  local url=""
  if command -v curl >/dev/null 2>&1; then
    url=$(curl -fsSL --max-time 5 https://meme-api.com/gimme 2>/dev/null | \
          grep -oE '"url":"[^"]+"' | head -n1 | cut -d'"' -f4)
  fi
  if [[ -z $url && -f ${cvui_HOME}/assets/memes.txt ]]; then
    url=$(shuf -n1 "${cvui_HOME}/assets/memes.txt" 2>/dev/null || \
          awk 'NR==int(rand()*NR)+1' "${cvui_HOME}/assets/memes.txt")
    ui::say_status INFO "Using bundled meme (API unreachable)"
  fi
  if [[ -z $url ]]; then
    ui::say_status ERR "No meme available"; return 1
  fi
  printf "${C_MAGENTA}🖼  Meme:${C_RESET} %s\n" "$url"
  if command -v termux-open-url >/dev/null 2>&1; then
    termux-open-url "$url"
  fi
}

cmd::weather() {
  local city="${*:-}"
  cmd::_need_curl || return 1
  curl -fsSL --max-time 10 "https://wttr.in/${city// /+}?format=v2&m" 2>/dev/null || \
    ui::say_status ERR "Weather service unreachable"
}

cmd::sysinfo() {
  if command -v neofetch >/dev/null 2>&1; then
    neofetch
  else
    printf "User     : %s\n" "${cvui_USER:-$USER}"
    printf "Shell    : %s\n" "$SHELL"
    printf "Host     : %s\n" "$(uname -n)"
    printf "Kernel   : %s\n" "$(uname -sr)"
    printf "Uptime   : %s\n" "$(uptime -p 2>/dev/null || uptime)"
  fi
}

# ── news (Hacker News top 5) ─────────────────────────────────────────────
cmd::news() {
  cmd::_need_curl || return 1
  printf "${C_CYAN}${C_BOLD}📰 Top headlines${C_RESET}  ${C_DIM}(news.ycombinator.com)${C_RESET}\n"
  local ids
  ids=$(curl -fsSL --max-time 8 \
    "https://hacker-news.firebaseio.com/v0/topstories.json" 2>/dev/null \
    | tr ',' '\n' | tr -d '[]' | head -n 8)
  [[ -z $ids ]] && { ui::say_status ERR "News service unreachable"; return 1; }
  local n=0
  while read -r id; do
    [[ -z $id ]] && continue
    local title url
    title=$(curl -fsSL --max-time 5 \
      "https://hacker-news.firebaseio.com/v0/item/$id.json" 2>/dev/null \
      | grep -oE '"title":"[^"]+"' | head -n1 | cut -d'"' -f4)
    url=$(curl -fsSL --max-time 5 \
      "https://hacker-news.firebaseio.com/v0/item/$id.json" 2>/dev/null \
      | grep -oE '"url":"[^"]+"' | head -n1 | cut -d'"' -f4)
    [[ -z $title ]] && continue
    n=$((n+1))
    printf "  ${C_YELLOW}%d.${C_RESET} %s\n" "$n" "$title"
    [[ -n $url ]] && printf "     ${C_DIM}%s${C_RESET}\n" "$url"
    (( n >= 5 )) && break
  done <<< "$ids"
}

# ── crypto (CoinGecko simple-price) ──────────────────────────────────────
cmd::crypto() {
  cmd::_need_curl || return 1
  local coin="${1:-bitcoin}"
  coin=${coin,,}
  # a few friendly aliases
  case $coin in
    btc) coin=bitcoin;;
    eth) coin=ethereum;;
    sol) coin=solana;;
    ada) coin=cardano;;
    doge) coin=dogecoin;;
    bnb) coin=binancecoin;;
    xrp) coin=ripple;;
    ltc) coin=litecoin;;
  esac
  local data
  data=$(curl -fsSL --max-time 8 \
    "https://api.coingecko.com/api/v3/simple/price?ids=$coin&vs_currencies=usd,kes&include_24hr_change=true" 2>/dev/null)
  if [[ -z $data || $data == "{}" ]]; then
    ui::say_status ERR "Unknown coin: $coin"
    ui::say_status INFO "Try: btc, eth, sol, doge, or a coingecko id"
    return 1
  fi
  local usd kes chg
  usd=$(printf '%s' "$data" | grep -oE '"usd":[0-9.eE+-]+' | head -n1 | cut -d: -f2)
  kes=$(printf '%s' "$data" | grep -oE '"kes":[0-9.eE+-]+' | head -n1 | cut -d: -f2)
  chg=$(printf '%s' "$data" | grep -oE '"usd_24h_change":[0-9.eE+-]+' | head -n1 | cut -d: -f2)
  local arrow color
  if [[ ${chg:-0} == -* ]]; then arrow="▼"; color=$C_RED; else arrow="▲"; color=$C_GREEN; fi
  printf "${C_CYAN}₿  %s${C_RESET}\n" "$coin"
  printf "   USD : ${C_BOLD}\$%s${C_RESET}  ${color}%s %s%%${C_RESET}\n" \
    "${usd:-?}" "$arrow" "$(printf '%.2f' "${chg:-0}" 2>/dev/null || echo "${chg}")"
  [[ -n $kes ]] && printf "   KES : ${C_BOLD}KSh %s${C_RESET}\n" "$kes"
}

# ── ip (public IP + geo) ─────────────────────────────────────────────────
cmd::ip() {
  cmd::_need_curl || return 1
  local data
  data=$(curl -fsSL --max-time 6 "https://ipinfo.io/json" 2>/dev/null)
  [[ -z $data ]] && { ui::say_status ERR "ipinfo.io unreachable"; return 1; }
  local ip city region country org
  ip=$(printf '%s' "$data" | grep -oE '"ip":"[^"]+"' | cut -d'"' -f4)
  city=$(printf '%s' "$data" | grep -oE '"city":"[^"]+"' | cut -d'"' -f4)
  region=$(printf '%s' "$data" | grep -oE '"region":"[^"]+"' | cut -d'"' -f4)
  country=$(printf '%s' "$data" | grep -oE '"country":"[^"]+"' | cut -d'"' -f4)
  org=$(printf '%s' "$data" | grep -oE '"org":"[^"]+"' | cut -d'"' -f4)
  printf "${C_CYAN}🌐 Public IP${C_RESET}\n"
  printf "   IP       : ${C_BOLD}%s${C_RESET}\n" "${ip:-?}"
  printf "   Location : %s, %s, %s\n" "${city:-?}" "${region:-?}" "${country:-?}"
  [[ -n $org ]] && printf "   Org      : ${C_DIM}%s${C_RESET}\n" "$org"
}

# ── define (dictionaryapi.dev) ───────────────────────────────────────────
cmd::define() {
  cmd::_need_curl || return 1
  local word="${1:-}"
  [[ -z $word ]] && { ui::say_status WARN "Usage: define <word>"; return 1; }
  local data
  data=$(curl -fsSL --max-time 6 \
    "https://api.dictionaryapi.dev/api/v2/entries/en/$word" 2>/dev/null)
  if [[ -z $data || $data == *'"title":"No Definitions Found"'* ]]; then
    ui::say_status ERR "No definition found for: $word"
    return 1
  fi
  printf "${C_CYAN}${C_BOLD}📖 %s${C_RESET}\n" "$word"
  # pull a couple of definitions with crude grep (no jq dependency)
  printf '%s' "$data" \
    | grep -oE '"partOfSpeech":"[^"]+"|"definition":"[^"]+"' \
    | head -n 8 \
    | awk -F'"' '
        /partOfSpeech/ { printf "\n  \033[38;5;215m(%s)\033[0m\n", $4; next }
        /definition/   { printf "    • %s\n", $4 }'
}

# ── qr ───────────────────────────────────────────────────────────────────
cmd::qr() {
  if ! command -v qrencode >/dev/null 2>&1; then
    ui::say_status ERR "qrencode not installed. Run: pkg install qrencode"
    return 1
  fi
  local text="$*"
  [[ -z $text ]] && { ui::say_status WARN "Usage: qr <text or URL>"; return 1; }
  qrencode -t ANSIUTF8 "$text"
}

# ── note / notes ─────────────────────────────────────────────────────────
cmd::note() {
  local f="$HOME/.cvui/notes.md"
  mkdir -p "$(dirname "$f")"
  local text="$*"
  if [[ -z $text ]]; then
    ui::say_status WARN "Usage: note <text>  (use 'notes' to list)"
    return 1
  fi
  printf '- [%s] %s\n' "$(date '+%Y-%m-%d %H:%M')" "$text" >> "$f"
  ui::say_status OK "Noted."
}

cmd::notes() {
  local f="$HOME/.cvui/notes.md"
  if [[ ! -s $f ]]; then
    ui::say_status INFO "No notes yet. Add with: note <text>"
    return 0
  fi
  printf "${C_CYAN}${C_BOLD}📝 Your notes${C_RESET}  ${C_DIM}(%s)${C_RESET}\n" "$f"
  cat "$f"
}

# ── todo ─────────────────────────────────────────────────────────────────
cmd::todo() {
  local f="$HOME/.cvui/todo.md"
  mkdir -p "$(dirname "$f")"
  touch "$f"
  local sub="${1:-}"
  case "$sub" in
    done|do)
      local n="${2:-}"
      [[ -z $n ]] && { ui::say_status WARN "Usage: todo done <number>"; return 1; }
      awk -v n="$n" '
        /^- \[ \]/ { i++; if (i==n) { sub(/\[ \]/, "[x]") } }
        { print }
      ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
      ui::say_status OK "Marked #$n done."
      cmd::todo   # reprint
      ;;
    rm|remove)
      local n="${2:-}"
      [[ -z $n ]] && { ui::say_status WARN "Usage: todo rm <number>"; return 1; }
      awk -v n="$n" '
        /^- \[/ { i++; if (i==n) next }
        { print }
      ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
      ui::say_status OK "Removed #$n."
      cmd::todo
      ;;
    clear)
      : > "$f"
      ui::say_status OK "Todo list cleared."
      ;;
    "")
      if [[ ! -s $f ]]; then
        ui::say_status INFO "Empty. Add with: todo <text>   |  Check off: todo done <n>"
        return 0
      fi
      printf "${C_CYAN}${C_BOLD}✅ Todo${C_RESET}\n"
      awk '
        /^- \[/ {
          i++
          line=$0
          if (line ~ /\[x\]/) {
            gsub(/\[x\]/, "\033[38;5;120m[✓]\033[0m", line)
            printf "  \033[2m%2d. %s\033[0m\n", i, line
          } else {
            gsub(/\[ \]/, "\033[38;5;221m[ ]\033[0m", line)
            printf "  %2d. %s\n", i, line
          }
        }
      ' "$f"
      ;;
    *)
      printf '- [ ] %s\n' "$*" >> "$f"
      ui::say_status OK "Added."
      ;;
  esac
}

# ── timer (pomodoro) ─────────────────────────────────────────────────────
# ── timer (hacker‑styled countdown) ─────────────────────────────────
cmd::timer() {
  local mins="${1:-25}"
  if ! [[ $mins =~ ^[0-9]+$ ]] || (( mins <= 0 )); then
    ui::say_status WARN "Usage: timer <minutes>"; return 1
  fi
  local secs=$(( mins * 60 ))
  local end=$(( $(date +%s) + secs ))
  
  # Weather‑style frame
  local top="┌─────────────────────────────────────────────────────────────────┐"
  local mid="├─────────────────────────────────────────────────────────────────┤"
  local bot="└─────────────────────────────────────────────────────────────────┘"
  
  ui::say_status INFO "⚡ HACKER TIMER: ${mins}m session - Ctrl+C to abort"
  printf "\n${C_CYAN}%s${C_RESET}\n" "$top"
  printf "${C_CYAN}│${C_RESET}  ${C_GREEN}⏳ cvui TIMER${C_RESET}                                    ${C_CYAN}│${C_RESET}\n"
  printf "${C_CYAN}%s${C_RESET}\n" "$mid"
  
  trap 'printf "\n${C_CYAN}%s${C_RESET}\n" "$bot"; ui::say_status WARN "⚠ Timer aborted."; trap - INT; return 130' INT
  
  while (( $(date +%s) < end )); do
    local left=$(( end - $(date +%s) ))
    local perc=$(( ( (secs - left) * 100 ) / secs ))
    local filled=$(( perc * 60 / 100 ))
    local empty=$(( 60 - filled ))
    
    # Build gradient bar
    local bar=""
    for ((i=0; i<filled; i++)); do
      if (( i < filled/3 )); then
        bar+="${C_GREEN}█${C_RESET}"
      elif (( i < filled*2/3 )); then
        bar+="${C_YELLOW}▓${C_RESET}"
      else
        bar+="${C_RED}▒${C_RESET}"
      fi
    done
    for ((i=0; i<empty; i++)); do
      bar+="${C_DIM}░${C_RESET}"
    done
    
    local min_left=$(( left / 60 )); local sec_left=$(( left % 60 ));
    local time_str=$(printf "%02d:%02d" $min_left $sec_left)
    
    printf "${C_CYAN}│${C_RESET}  [${bar}] ${C_BOLD}%s${C_RESET}  ${C_YELLOW}%3d%%${C_RESET} ${C_CYAN}│${C_RESET}\r" "$time_str" "$perc"
    sleep 1
  done
  
  printf "\n${C_CYAN}│${C_RESET}  ${C_BOLD}${C_GREEN}✔ TIMER COMPLETE!${C_RESET}                                   ${C_CYAN}│${C_RESET}\n"
  printf "${C_CYAN}%s${C_RESET}\n\n" "$bot"

  if command -v voice::say >/dev/null 2>&1; then
    local msgs=("Timer complete, ${cvui_USER:-sir}. Your ${mins} minute session has ended." "Focus session finished. Time to take a break, ${cvui_USER:-sir}." "The countdown has reached zero. Subsystems are standing by." "Alert. ${mins} minutes have elapsed. Task duration complete."); voice::say "${msgs[RANDOM % ${#msgs[@]}]}"
  fi
  if command -v sound::chime >/dev/null 2>&1; then sound::chime; fi
  if command -v termux-notification >/dev/null 2>&1; then
    termux-notification -t "cvui timer" -c "${mins}m elapsed" 2>/dev/null || true
  fi
}

# ── doctor (environment audit) ───────────────────────────────────────────
cmd::doctor() {
  printf "${C_CYAN}${C_BOLD}🩺 cvui Doctor${C_RESET}\n"
  printf "${C_GRAY}────────────────────────────────${C_RESET}\n"
  _cvui_doctor_check() {
    local label=$1 bin=$2 required=${3:-optional}
    if command -v "$bin" >/dev/null 2>&1; then
      printf "  ${C_GREEN}✔${C_RESET} %-22s ${C_DIM}(%s)${C_RESET}\n" "$label" "$(command -v "$bin")"
    else
      if [[ $required == required ]]; then
        printf "  ${C_RED}✖${C_RESET} %-22s ${C_RED}MISSING (required)${C_RESET}\n" "$label"
      else
        printf "  ${C_YELLOW}○${C_RESET} %-22s ${C_DIM}not installed${C_RESET}\n" "$label"
      fi
    fi
  }
  _cvui_doctor_check "bash"      bash    required
  _cvui_doctor_check "zsh"       zsh     required
  _cvui_doctor_check "git"       git     required
  _cvui_doctor_check "curl"      curl    required
  _cvui_doctor_check "lsd"       lsd
  _cvui_doctor_check "tgpt"      tgpt
  _cvui_doctor_check "fzf"       fzf
  _cvui_doctor_check "fd"        fd
  _cvui_doctor_check "espeak"    espeak
  _cvui_doctor_check "sox"       play
  _cvui_doctor_check "qrencode"  qrencode
  _cvui_doctor_check "neofetch"  neofetch
  _cvui_doctor_check "openssl"   openssl
  _cvui_doctor_check "termux-api" termux-notification
  printf "${C_GRAY}────────────────────────────────${C_RESET}\n"
  # cvui installation checks
  local ok=1
  for f in "$cvui_HOME/bin/cvui" "$cvui_HOME/motd/init.sh" "$cvui_HOME/lib/auth.sh"; do
    if [[ -e $f ]]; then
      printf "  ${C_GREEN}✔${C_RESET} %s\n" "${f#$cvui_HOME/}"
    else
      printf "  ${C_RED}✖${C_RESET} %s ${C_RED}missing${C_RESET}\n" "${f#$cvui_HOME/}"
      ok=0
    fi
  done
  if (( ok )); then
    ui::say_status OK "cvui install looks healthy."
  else
    ui::say_status ERR "Some cvui files are missing — try: cvui update"
  fi
  unset -f _cvui_doctor_check
}

cmd::voice_toggle() {
  local cfg="$HOME/.cvui/voice"
  case "${1:-}" in
    on)
      export cvui_VOICE=1
      mkdir -p "$(dirname "$cfg")"
      printf '1\n' > "$cfg"
      ui::say_status OK "Voice enabled (saved)"
      voice::say "Voice online."
      ;;
    off)
      export cvui_VOICE=0
      mkdir -p "$(dirname "$cfg")"
      printf '0\n' > "$cfg"
      ui::say_status OK "Voice muted (saved)"
      ;;
    *)
      ui::say_status INFO "Voice is currently: $([[ ${cvui_VOICE:-1} -eq 1 ]] && echo on || echo off)"
      ;;
  esac
}

cmd::banner() {
  local text="$*"
  if [[ -z $text ]]; then
    ui::say_status WARN "Usage: banner <text>   (letters/digits only, no spaces)"
    return 1
  fi
  if ! command -v banner::build >/dev/null 2>&1; then
    [[ -f "$cvui_HOME/lib/banner.sh" ]] && source "$cvui_HOME/lib/banner.sh"
  fi
  banner::build "$text"
}

cmd::whoami() {
  printf "  ${C_CYAN}%s${C_RESET} (cvui session)\n" "${cvui_USER:-unknown}"
}

cmd::update() {
  if [[ ! -d $cvui_HOME/.git ]]; then
    ui::say_status ERR "Not a git install — cannot self-update."
    ui::say_status INFO "Re-run the installer manually to update."
    return 1
  fi

  # Stash any user-modified tracked files so `git pull --ff-only` can't
  # blow away their banner / theme tweaks. We restore them after pulling.
  local stashed=0
  if [[ -n "$(git -C "$cvui_HOME" status --porcelain 2>/dev/null)" ]]; then
    ui::say_status INFO "Saving your local tweaks (banner, themes, etc.)…"
    if git -C "$cvui_HOME" stash push -u -m "cvui-update-$(date +%s)" \
         >/dev/null 2>&1; then
      stashed=1
    else
      ui::say_status WARN "Could not stash local changes — aborting update."
      return 1
    fi
  fi

  ui::say_status INFO "Fetching latest from origin…"
  if ! git -C "$cvui_HOME" pull --ff-only; then
    ui::say_status ERR "git pull failed — resolve conflicts and retry."
    (( stashed )) && git -C "$cvui_HOME" stash pop >/dev/null 2>&1 || true
    return 1
  fi

  # Restore the user's tweaks on top of the new code. If a tweak now
  # conflicts with an upstream change, leave the conflict in-tree for the
  # user to resolve — better than silently losing their work.
  if (( stashed )); then
    if git -C "$cvui_HOME" stash pop >/dev/null 2>&1; then
      ui::say_status OK "Restored your local tweaks on top of the update."
    else
      ui::say_status WARN "Some of your tweaks conflicted with upstream — "
      ui::say_status WARN "see 'cd $cvui_HOME && git status' to resolve."
    fi
  fi

  ui::say_status OK "cvui is now up to date."

  # Re-run the installer in *update mode*: refreshes code-side assets and
  # the managed .zshrc block, but never touches font/colors/extra-keys/
  # theme selection that the user may have customized.
  if [[ -x $cvui_HOME/install/install.sh ]]; then
    ui::say_status INFO "Refreshing managed bits (non-destructive)…"
    cvui_REPO="$cvui_HOME" cvui_INSTALL_DIR="$cvui_HOME" cvui_UPDATE_MODE=1 \
      bash "$cvui_HOME/install/install.sh" || true
  fi
}


cmd::noauth() {
  local cfg="$HOME/.cvui/no-lock"
  case "${1:-}" in
    on)
      mkdir -p "$(dirname "$cfg")"
      touch "$cfg"
      ui::say_status OK "Authentication bypass enabled (no-auth ON)"
      ;;
    off)
      rm -f "$cfg"
      ui::say_status OK "Authentication bypass disabled (no-auth OFF)"
      ;;
    *)
      ui::say_status INFO "No-auth is currently: $([[ -f $cfg ]] && echo ON || echo OFF)"
      ui::say_status INFO "Use: noauth on|off to toggle."
      ;;
  esac
}
cmd::theme() {
  local themes_dir="$cvui_HOME/zsh/themes"
  local cfg="$HOME/.cvui/theme"
  local name="${1:-}"

  local -a available=()
  if [[ -d $themes_dir ]]; then
    for f in "$themes_dir"/*.zsh-theme; do
      [[ -f $f ]] || continue
      available+=("$(basename "$f" .zsh-theme)")
    done
  fi

  if [[ -z $name ]]; then
    local current=""
    [[ -f $cfg ]] && current=$(cat "$cfg")
    printf "${C_CYAN}Available themes:${C_RESET}\n"
    for t in "${available[@]}"; do
      if [[ $t == "${current:-cvui}" ]]; then
        printf "  ${C_GREEN}●${C_RESET} %s ${C_DIM}(active)${C_RESET}\n" "$t"
      else
        printf "  ${C_DIM}○${C_RESET} %s\n" "$t"
      fi
    done
    printf "\n${C_DIM}Use: cvui theme <name>${C_RESET}\n"
    return 0
  fi

  local chosen=""
  for t in "${available[@]}"; do
    [[ $t == "$name" ]] && chosen=$t && break
  done
  if [[ -z $chosen ]]; then
    ui::say_status ERR "Unknown theme: $name"
    ui::say_status INFO "Available: ${available[*]}"
    return 1
  fi
  mkdir -p "$(dirname "$cfg")"
  printf '%s\n' "$chosen" > "$cfg"
  ui::say_status OK "Theme set to: $chosen"
  ui::say_status INFO "Open a new shell (or run: exec zsh) to see it."
}

# ── time (hacker‑styled clock) ────────────────────────────────────────
cmd::time() {
  clear
  local top="┌─────────────────────────────────────────────────────────────────┐"
  local mid="├─────────────────────────────────────────────────────────────────┤"
  local bot="└─────────────────────────────────────────────────────────────────┘"
  
  printf "${C_CYAN}%s${C_RESET}\n" "$top"
  printf "${C_CYAN}│${C_RESET}  ${C_GREEN}⏰ cvui SYSTEM CLOCK${C_RESET}                                ${C_CYAN}│${C_RESET}\n"
  printf "${C_CYAN}%s${C_RESET}\n" "$mid"
  
  while true; do
    local now=$(date '+%Y-%m-%d %H:%M:%S')
    local day=$(date '+%A')
    local zone=$(date '+%Z')
    printf "${C_CYAN}│${C_RESET}  ${C_BOLD}${C_YELLOW}%s${C_RESET}  ${C_DIM}(%s %s)${C_RESET}                     ${C_CYAN}│${C_RESET}\r" "$now" "$day" "$zone"
    sleep 1
  done
}

cmd::date() {
  printf "${C_CYAN}📅 ${C_BOLD}%s${C_RESET}\n" "$(date '+%A, %B %d, %Y')"
  printf "  ${C_DIM}Full:${C_RESET} %s\n" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
  printf "  ${C_DIM}Unix:${C_RESET} %s\n" "$(date +%s)"
}

# ── calc (terminal calculator) ────────────────────────────────────────
cmd::calc() {
  local expr="$*"
  if [[ -z $expr ]]; then
    ui::say_status WARN "Usage: calc <expression>"
    ui::say_status INFO "Example: calc 2+2, calc '(10*5)/2', calc 'sqrt(144)'"
    return 1
  fi
  # Use bc for calculation, sanitize input
  local clean=$(printf '%s' "$expr" | tr -cd '0-9.+\\-*/%()sqrt ' 2>/dev/null)
  if [[ -z $clean ]]; then
    ui::say_status ERR "Invalid expression"
    return 1
  fi
  local result
  result=$(echo "scale=4; $clean" | bc 2>/dev/null)
  if [[ -z $result ]]; then
    ui::say_status ERR "Calculation error"
    return 1
  fi
  printf "${C_CYAN}🧮 ${C_BOLD}%s${C_RESET} = ${C_GREEN}%s${C_RESET}\n" "$expr" "$result"
}

# ── bible (verse lookup) ─────────────────────────────────────────────
cmd::bible() {
  cmd::_need_curl || return 1
  local ref="${*:-John 3:16}"
  
  # Parse reference
  local book chapter verse
  book=$(printf '%s' "$ref" | grep -oE '^[0-9a-zA-Z]+' | head -1)
  chapter=$(printf '%s' "$ref" | grep -oE '[0-9]+:[0-9]+' | head -1 | cut -d: -f1)
  verse=$(printf '%s' "$ref" | grep -oE '[0-9]+:[0-9]+' | head -1 | cut -d: -f2)
  
  if [[ -z $book || -z $chapter || -z $verse ]]; then
    ui::say_status WARN "Usage: bible <book chapter:verse>"
    ui::say_status INFO "Example: bible John 3:16, bible Genesis 1:1"
    return 1
  fi
  
  # Using bible-api.com (free, no key needed)
  local api_ref=$(printf '%s' "$ref" | sed 's/ /%20/g')
  local data
  data=$(curl -fsSL --max-time 8 "https://bible-api.com/$api_ref" 2>/dev/null)
  
  if [[ -z $data ]]; then
    ui::say_status ERR "Verse not found or service unreachable"
    return 1
  fi
  
  local text=$(printf '%s' "$data" | grep -oE '"text":"[^"]+"' | head -1 | cut -d'"' -f4 | sed 's/\\n/ /g' | xargs)
  local ref_out=$(printf '%s' "$data" | grep -oE '"reference":"[^"]+"' | head -1 | cut -d'"' -f4)
  
  if [[ -z $text ]]; then
    ui::say_status ERR "Could not parse verse"
    return 1
  fi
  
  # Display with nice formatting
  local top="┌─────────────────────────────────────────────────────────────────┐"
  local bot="└─────────────────────────────────────────────────────────────────┘"
  
  printf "\n${C_CYAN}%s${C_RESET}\n" "$top"
  printf "${C_CYAN}│${C_RESET}  ${C_YELLOW}📖 ${C_BOLD}%s${C_RESET}                                      ${C_CYAN}│${C_RESET}\n" "${ref_out:-$ref}"
  printf "${C_CYAN}│${C_RESET}                                                                ${C_CYAN}│${C_RESET}\n"
  
  # Word wrap the verse text
  local words=($text)
  local line=""
  for word in "${words[@]}"; do
    if ((${#line} + ${#word} + 1 > 60)); then
      printf "${C_CYAN}│${C_RESET}  %s ${C_CYAN}│${C_RESET}\n" "$line"
      line=""
    fi
    line+="$word "
  done
  [[ -n $line ]] && printf "${C_CYAN}│${C_RESET}  %s ${C_CYAN}│${C_RESET}\n" "$line"
  
  printf "${C_CYAN}%s${C_RESET}\n\n" "$bot"
}

# ── apps (launcher listing) ──────────────────────────────────────────
cmd::apps() {
  printf "${C_CYAN}${C_BOLD}🚀 cvui App Launcher${C_RESET}\n"
  printf "${C_GRAY}────────────────────────────────────────────${C_RESET}\n"
  
  local -a apps=(
    "weather ⛅ Weather forecast (wttr.in)"
    "crypto 💰 Cryptocurrency prices"
    "news 📰 Hacker News headlines"
    "calc 🧮 Terminal calculator"
    "bible 📖 Bible verse lookup"
    "define 📖 Dictionary lookup"
    "ip 🌐 Public IP & geolocation"
    "timer ⏳ Pomodoro timer"
    "notes 📝 View/edit notes"
    "todo ✅ Todo list manager"
    "ask 🤖 Ask KAI (AI assistant)"
    "joke 😄 Random jokes"
    "fact 💡 Fun facts"
    "qr 🖼 Generate QR codes"
    "sysinfo 💻 System information"
    "time ⏰ Live clock"
    "theme 🎨 Switch prompt theme"
    "doctor 🩺 System health check"
  )
  
  for app in "${apps[@]}"; do
    local cmd="${app%% *}"
    local desc="${app#* }"
    printf "  ${C_GREEN}%-12s${C_RESET} %s\n" "$cmd" "$desc"
  done
  
  printf "\n${C_GRAY}────────────────────────────────────────────${C_RESET}\n"
  printf "${C_DIM}Usage: cvui <command>${C_RESET}\n"
}
