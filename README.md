# cvui — cybervaultke UI (Proprietary In-House Edition)

> A KAI-inspired Termux shell UI + zsh framework, made by **cybervaultke**.
> Everything is custom-made in-house: proprietary font, custom history search, and iconified tools.

```
 ██╗  ██╗ █████╗ ███████╗██╗  ██╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
 ██║ ██╔╝██╔══██╗██╔════╝██║  ██║    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
 █████╔╝ ███████║███████╗███████║    ███████╗██║██║  ███╗███████║   ██║
 ██╔═██╗ ██╔══██║╚════██║██╔══██║    ╚════██║██║██║   ██║██╔══██║   ██║
 ██║  ██╗██║  ██║███████║██║  ██║    ███████║██║╚██████╔╝██║  ██║   ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
                     ⚡ cybervaultke • KAI UI ⚡
```

---

## ✨ Proprietary Features

**Proprietary In-House Shell**:
- 🔐 **Authentication**: First-run account setup with sha256-hashed local credentials.
- 🗣 **KAI Voice**: Live TTS for greetings, jokes, facts, and creative timer alerts.
- 📁 **Custom `ls`**: Iconified file listing (📂, 🏗, 📄) built directly into the shell (no `lsd` required).
- 🔍 **History Search**: Custom in-house history prefix search via Up/Down arrows.
- ⚡ **Zero Bloat**: All unnecessary Python build tools and external libraries removed.

**Proprietary cvui System Font**:
- 🖋 **Classic Look**: Text displays in a clear, readable style similar to **Times New Roman**.
- 🛠 **Icon Support**: Full support for emojis, icons, and glyphs (Nerd Font compatible).
- 📐 **Lines Support**: Native support for box-drawing characters and UI lines.
- 📦 **Bundled**: The font is proprietary and comes bundled with the installation (`assets/fonts/cvui.ttf`).

---

## 🚀 Installation

```bash
pkg update && pkg upgrade -y && pkg install git -y && git clone https://github.com/cybervaultke/cvui.git && cd cvui/install && bash install.sh
```

The installer:
1. Installs minimal system packages (git, python, tgpt, espeak, sox, ...).
2. Deploys the proprietary **`cvui.ttf`** system font to `~/.termux/font.ttf`.
3. Drops the KAI-blue `colors.properties` and 3-row extra-keys layout.
4. Sets up the custom-made **KSH** zsh framework.
5. Symlinks `cvui` into your PATH.

Then run:

```bash
cvui            # Launch interactive REPL
cvui --help     # Show one-shot modes
```

---

## 🗣 KAI Commands

```
ask <q...>          Ask KAI anything (AI-powered)
joke / fact         AI-generated (KAI speaks the response!)
timer <min>         Pomodoro timer with creative voice alerts
weather [city]      Weather via wttr.in
sysinfo             Proprietary system info panel
motd                Reprint the banner
time / date         Live clock and date
ls / ll / la        Custom iconified file listing
theme [name]        Switch prompt themes
noauth [on|off]     Toggle session lock (auth)
update              Pull latest proprietary updates
exit / quit         Shut down cvui
```

---

## ⌨️ Custom Key Bindings

| Key | Action |
|---|---|
| `Up Arrow` | Search history (prefix match) |
| `Down Arrow` | Search history (prefix match) |
| `Ctrl+F` | Accept autosuggestion |
| `Alt+F` | Accept one word of suggestion |

---

## 👤 Maker

Made with ⚡ by **cybervaultke**

- 🎬 YouTube — [youtube.com/@cybervaultke](https://youtube.com/@cybervaultke)
- 📸 Instagram — [instagram.com/cybervaultke](https://instagram.com/cybervaultke)
- 💻 GitHub — [github.com/cybervaultke](https://github.com/cybervaultke)
- 🤖 Last Updated — By AI Agent

---

## 📜 License

MIT — see [LICENSE](LICENSE).
