#!/data/data/com.termux/files/usr/bin/env bash
# cvui installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/cybervaultke/cvui/main/install/install.sh | bash
#
# Non-destructive: only installs missing packages, never removes or
# downgrades anything you already have. Existing Termux font and color
# scheme are backed up (.cvui-backup) before being replaced so the
# uninstaller can restore them.
# ...
REPO="${cvui_REPO:-https://github.com/cybervaultke/cvui.git}"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

# Detect if we are already inside the cvui repo
if [[ -d "$(dirname "$0")/../.git" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    INSTALL_DIR="${cvui_INSTALL_DIR:-$SCRIPT_DIR}"
else
    INSTALL_DIR="${cvui_INSTALL_DIR:-$HOME/.cvui-app}"
fi

BIN_LINK="$PREFIX/bin/cvui"
# ...
TERMUX_DIR="${TERMUX_DIR:-$HOME/.termux}"

# opt-outs
cvui_SKIP_FONT="${cvui_SKIP_FONT:-0}"
cvui_SKIP_COLORS="${cvui_SKIP_COLORS:-0}"
cvui_SKIP_SOUNDS="${cvui_SKIP_SOUNDS:-0}"
cvui_SKIP_KEYS="${cvui_SKIP_KEYS:-0}"
cvui_SKIP_KSH="${cvui_SKIP_KSH:-0}"
cvui_SKIP_MOTD="${cvui_SKIP_MOTD:-0}"

# Update mode: when set, the installer behaves non-destructively — it only
# pulls upstream code/feature/fix changes and refreshes the cvui managed
# block in ~/.zshrc. It WILL NOT overwrite the user's font, colors, theme
# selection, banner, or extra-keys layout, even if those have backups.
# `cmd::update` sets this; first-time installs leave it unset.
cvui_UPDATE_MODE="${cvui_UPDATE_MODE:-0}"

say()  { printf "\033[38;5;120m✔\033[0m %s\n" "$*"; }
warn() { printf "\033[38;5;221m⚠\033[0m %s\n" "$*"; }
err()  { printf "\033[38;5;203m✖\033[0m %s\n" "$*" >&2; }
info() { printf "\033[38;5;75mℹ\033[0m %s\n" "$*"; }
hr()   { printf '\033[2m%s\033[0m\n' "────────────────────────────────────"; }

banner() {
cat <<'EOF'
 ██╗  ██╗███████╗██╗   ██╗██╗
 ██║ ██╔╝██╔════╝██║   ██║██║
 █████╔╝ ███████╗██║   ██║██║
 ██╔═██╗ ╚════██║██║   ██║██║
 ██║  ██╗███████║╚██████╔╝██║
 ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝
       installer
EOF
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

pkg_install_if_missing() {
  local pkg=$1 bin=${2:-$1}
  if need_cmd "$bin"; then
    say "$bin already installed — skipping"
    return 0
  fi
  if need_cmd pkg; then
    warn "Installing $pkg via pkg…"
    pkg install -y "$pkg" >/dev/null 2>&1 || warn "pkg install $pkg failed (optional)"
  elif need_cmd apt; then
    warn "Installing $pkg via apt…"
    sudo apt-get install -y "$pkg" >/dev/null 2>&1 || warn "apt install $pkg failed (optional)"
  else
    warn "No package manager found — please install '$pkg' manually"
  fi
}

backup_file() {
  # backup_file <path>  → moves path → path.cvui-backup (only once)
  local f=$1
  [[ -e $f ]] || return 0
  [[ -e $f.cvui-backup ]] && { info "Backup already exists: $f.cvui-backup"; return 0; }
  cp -a "$f" "$f.cvui-backup" && say "Backed up $f → $f.cvui-backup"
}

install_font() {
  (( cvui_SKIP_FONT )) && { info "Skipping font install (cvui_SKIP_FONT=1)"; return; }
  if (( cvui_UPDATE_MODE )) && [[ -f "$TERMUX_DIR/font.ttf" ]]; then
    info "Update mode: keeping existing font ($TERMUX_DIR/font.ttf)"
    return
  fi
  mkdir -p "$TERMUX_DIR"

  local font_dest="$TERMUX_DIR/font.ttf"
  local bundled="$INSTALL_DIR/assets/fonts/cvui.ttf"

  # 1. Use the bundled cvui in-house font
  if [[ -f $bundled ]]; then
    backup_file "$font_dest"
    cp "$bundled" "$font_dest" && say "Installed in-house cvui system font"
    return
  fi

  # 2. Fallback only if bundle is missing
  warn "Bundled font missing. Please ensure assets/fonts/cvui.ttf exists."
}

install_colors() {
  (( cvui_SKIP_COLORS )) && { info "Skipping color scheme (cvui_SKIP_COLORS=1)"; return; }
  [[ -f "$INSTALL_DIR/assets/colors.properties" ]] || return 0
  if (( cvui_UPDATE_MODE )) && [[ -f "$TERMUX_DIR/colors.properties" ]]; then
    info "Update mode: keeping existing color scheme"
    return
  fi
  mkdir -p "$TERMUX_DIR"

  local dest="$TERMUX_DIR/colors.properties"
  backup_file "$dest"
  cp "$INSTALL_DIR/assets/colors.properties" "$dest" && \
    say "Installed KAI-blue color scheme"
}

install_extra_keys() {
  (( cvui_SKIP_KEYS )) && { info "Skipping extra-keys layout (cvui_SKIP_KEYS=1)"; return; }
  [[ -f "$INSTALL_DIR/assets/termux.properties" ]] || return 0
  if (( cvui_UPDATE_MODE )) && [[ -f "$TERMUX_DIR/termux.properties" ]]; then
    info "Update mode: keeping existing extra-keys layout"
    return
  fi
  mkdir -p "$TERMUX_DIR"

  local dest="$TERMUX_DIR/termux.properties"
  backup_file "$dest"
  cp "$INSTALL_DIR/assets/termux.properties" "$dest" && \
    say "Installed 3-row extra-keys layout"
}

reload_termux() {
  if need_cmd termux-reload-settings; then
    termux-reload-settings 2>/dev/null || true
    say "Reloaded Termux settings (font + colors active)"
  else
    info "Run 'termux-reload-settings' or restart Termux to apply font/colors"
  fi
}

install_ksh() {
  (( cvui_SKIP_KSH )) && { info "Skipping KSH shell framework (cvui_SKIP_KSH=1)"; return; }
  local zshrc="$HOME/.zshrc"
  local tmpl="$INSTALL_DIR/zsh/zshrc.template"
  [[ -f $tmpl ]] || return 0

  local rendered
  rendered=$(sed "s|__cvui_INSTALL_DIR__|$INSTALL_DIR|g" "$tmpl")

  # Extract just the managed block from the rendered template
  local block
  block=$(awk '/# cvui-BEGIN/,/# cvui-END/' <<<"$rendered")

  # Case A — existing .zshrc already has cvui markers: only refresh the
  # managed block, never touch the rest. Safe for both fresh installs and
  # `cvui update`.
  if [[ -f $zshrc ]] && grep -q '# cvui-BEGIN' "$zshrc"; then
    local tmp="${zshrc}.cvui.tmp"
    awk -v block="$block" '
      /# cvui-BEGIN/ { in_block=1; print block; next }
      /# cvui-END/   { in_block=0; next }
      !in_block      { print }
    ' "$zshrc" > "$tmp" && mv "$tmp" "$zshrc"
    say "Refreshed cvui block in $zshrc"
    return
  fi

  # Case B — update mode but no cvui block found: append the block, do
  # NOT wipe the user's .zshrc. They asked us to fix bugs, not their dotfiles.
  if (( cvui_UPDATE_MODE )); then
    [[ -f $zshrc ]] && backup_file "$zshrc"
    printf '\n%s\n' "$block" >> "$zshrc"
    say "Appended cvui block to $zshrc (update mode)"
    return
  fi

  # Case C — fresh install: back up the existing .zshrc once, then write
  # the full cvui .zshrc on top. The user explicitly invoked the installer.
  [[ -f $zshrc ]] && backup_file "$zshrc"
  printf '%s\n' "$rendered" > "$zshrc"
  say "Installed cvui .zshrc (backup: $zshrc.cvui-backup)"
  info "Personal overrides? Put them in ~/.zshrc.local — sourced automatically."
}

install_motd() {
  (( cvui_SKIP_MOTD )) && { info "Skipping motd (cvui_SKIP_MOTD=1)"; return; }
  # motd files ship in the repo under $INSTALL_DIR/motd — nothing to fetch.
  # The KSH framework sources init.sh on new interactive shells automatically.
  chmod +x "$INSTALL_DIR/motd/init.sh" "$INSTALL_DIR/motd/motd.d/"* 2>/dev/null || true
  say "cvui motd ready (shown on new interactive shells)"

  # Disable other motds so cvui's is the only one that shows.
  # We comment out the motd line in $PREFIX/etc/zprofile (used by
  # GR3YH4TT3R93/termux-motd and similar) and back it up first.
  local zp="$PREFIX/etc/zprofile"
  if [[ -f $zp ]] && grep -qE '^[^#]*etc/motd/init\.sh' "$zp"; then
    backup_file "$zp"
    sed -i -E 's|^([^#]*etc/motd/init\.sh.*)$|# \1  # disabled by cvui|' "$zp"
    say "Disabled global motd in $zp (backup: $zp.cvui-backup)"
  fi
  # Termux's plain /etc/motd file (if it exists as a regular file): silence
  # by ensuring ~/.hushlogin exists.
  if [[ -f $PREFIX/etc/motd && ! -e $HOME/.hushlogin ]]; then
    : > "$HOME/.hushlogin" && say "Created ~/.hushlogin to silence default Termux motd"
  fi
}

banner
hr
say "Installing cvui into: $INSTALL_DIR"
say "Bin symlink         : $BIN_LINK"
hr

# --- 1. dependencies (from requirements files) ---
say "Checking dependencies from requirements files..."

# Ensure pip is available
pkg_install_if_missing python-pip pip

# Install system packages from pkg_requirements.txt
if [[ -f "$INSTALL_DIR/install/pkg_requirements.txt" ]]; then
    info "Installing system packages..."
    while read -r pkg; do
        [[ -z "$pkg" || "$pkg" == "#"* ]] && continue
        pkg_install_if_missing "$pkg"
    done < "$INSTALL_DIR/install/pkg_requirements.txt"
fi

# --- 2. fetch repo ---
# (only if we are not already in it, handled by INSTALL_DIR detection above)
if [[ ! -d "$INSTALL_DIR/.git" ]]; then
    say "Cloning cvui..."
    git clone --depth 1 "$REPO" "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/bin/cvui"

# --- 3. font + colors + sounds + ksh + motd ---
# Silence the "zsh-newuser-install" prompt by ensuring .zshrc exists
# This prevents the configuration menu on first Zsh launch.
if [[ ! -e "$HOME/.zshrc" && ! -e "$HOME/.zshenv" ]]; then
    touch "$HOME/.zshrc"
    say "Silenced zsh-newuser-install prompt"
fi

install_font
install_colors
install_extra_keys
install_motd
install_ksh

# Set zsh as default shell if possible
if [[ "$SHELL" != */zsh ]] && need_cmd chsh; then
    chsh -s zsh && say "Default shell changed to Zsh" || warn "Could not change default shell (optional)"
fi

# Ensure .bashrc also execs zsh for consistency if zsh is preferred
if [[ ! -f "$HOME/.bashrc" ]] || ! grep -q "exec zsh" "$HOME/.bashrc"; then
    printf '\n# Auto-start zsh\nif [[ -t 0 && $- == *i* ]]; then\n    exec zsh\nfi\n' >> "$HOME/.bashrc"
    say "Configured .bashrc to auto-start Zsh"
fi
# sounds ship inside the repo — nothing else to fetch for them

# --- 4. symlink into PATH ---
if [[ -w $(dirname "$BIN_LINK") ]]; then
  ln -sf "$INSTALL_DIR/bin/cvui" "$BIN_LINK"
  say "Linked cvui → $BIN_LINK"
else
  warn "Cannot write $BIN_LINK — add this to your PATH manually:"
  printf '   export PATH="%s/bin:$PATH"\n' "$INSTALL_DIR"
fi

# --- 5. reload termux so font/colors take effect ---
reload_termux

# --- 6. done ---
hr
say "cvui installed successfully!"
printf "\n  Run it with:  \033[1;36mcvui\033[0m\n"
printf "  Uninstall  :  \033[1;36mbash %s/install/uninstall.sh\033[0m\n\n" "$INSTALL_DIR"
printf "  Made by \033[38;5;215m⚡ cybervaultke ⚡\033[0m — youtube.com/@cybervaultke\n\n"
