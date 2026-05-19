# Changelog

## 0.3.0 — 2026-04-25

### Added
- **KAI** — the AI persona replacing JARVIS across all user-facing strings
  (commands, banners, voice, docs). `cvui ask` prompts now say `🤖 KAI:`.
- **News** — `cvui news` prints top 5 Hacker News headlines with URLs.
- **Crypto** — `cvui crypto [coin]` shows USD + KES + 24h change via CoinGecko.
  Accepts aliases (btc/eth/sol/doge/…) or any CoinGecko id.
- **IP** — `cvui ip` shows public IP + city/region/country + org (ipinfo.io).
- **Define** — `cvui define <word>` dictionary lookup (dictionaryapi.dev).
- **QR** — `cvui qr <text>` renders an ANSI QR code (requires qrencode).
- **Notes** — `cvui note <text>` appends to `~/.cvui/notes.md`; `cvui notes` lists.
- **Todo** — `cvui todo [text]` / `todo done N` / `todo rm N` / `todo clear`
  against `~/.cvui/todo.md`.
- **Timer** — `cvui timer <minutes>` pomodoro with voice + chime + notification.
- **Doctor** — `cvui doctor` audits every optional dep and cvui file with ✓/✗.
- **Password mask** — auth now echoes `*` per keystroke (backspace supported).
- **Disk bar** — motd disk panel shows `[█████░░] 87%  27G/28G` inline.
- Installer pulls `qrencode` and `termux-api` (optional).

### Changed
- **Compact motd** — removed the `Date & Time:` panel; time now lives on the
  prompt's RPROMPT as `HH:MM:SS`.
- **Prompt** — hides the git branch segment by default (less noise).
- **Joke / fact** — each call picks a random topic + nonce so tgpt stops
  repeating the same punchline.
- **Load-average parsing** — robust against `uptime` format variations.
- Installer / repo URL: `cybervaultke` → `cybervaultke` (username change).
- Socials: X/Twitter → Facebook in the maker intro.

## 0.2.0 — 2026-04-24

### Added
- **One-shot modes** — run commands without entering the REPL:
  `cvui ask <q>`, `cvui joke`, `cvui fact`, `cvui weather [city]`,
  `cvui sysinfo`, `cvui motd`, `cvui update`, `cvui theme [name]`
- **`cvui update`** — self-updates the install via `git pull` + re-runs
  the installer to refresh assets.
- **Prompt themes** — `cvui theme [name]` lists / switches. Three
  built-ins: `cvui` (KAI-blue, default), `minimal`, `cyberpunk`.
  Selection persisted in `~/.cvui/theme`.
- **fzf integration** in KSH (`zsh/plugins/fzf/`):
  - `Ctrl-R` — fuzzy history search
  - `Ctrl-T` — fuzzy file picker with preview
  - `Alt-C` — fuzzy `cd`
- **Motd date/time panel** (`motd/motd.d/25-datetime`).
- Installer now pulls `fzf` and `fd` (optional).
- REPL commands: `theme`, `update`, `motd`, `time`, `date`.

### Changed
- **Login screen** now uses the full motd (big cybervaultke banner +
  sysinfo + datetime + disk) instead of the KAI-face mini-banner.
- `cvui --help` shows the new usage with one-shot subcommands.

### Removed
- Dropped the old `kai.txt` mini-face from the post-login screen.

## 0.1.0 — 2026-04-24

Initial release.

- ASCII boot banner + fake init sequence
- First-run account setup (sha256-hashed local credentials)
- Login screen with 3-attempt lockout
- KAI voice via `espeak` / `festival` / `termux-tts-speak`
- Maker intro with cybervaultke socials
- Commands: `help`, `about`, `ask`, `joke`, `fact`, `meme`, `weather`,
  `sysinfo`, `ls`, `ll`, `cd`, `clear`, `voice`, `whoami`,
  `reset-auth`, `exit`
- Non-destructive installer + uninstaller
- Vendored KSH framework + motd + prompt theme (no oh-my-zsh / p10k /
  external motd dependency)
