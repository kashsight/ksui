# cvui — cybervaultke UI (Legacy Edition)

> A KAI-inspired Termux shell UI + custom zsh framework, made by **cybervaultke**.
> Everything is custom-made in-house: proprietary font, custom history search, iconified tools, and automatic update checks.

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

## ✨ Features

**Custom Shell Framework**:
- 🔐 **Authentication**: First-run account setup with local security.
- 🔄 **Auto-Updates**: Automatically checks for updates on launch and prompts to pull changes.
- 🗣 **KAI Voice**: Live TTS for greetings, jokes, facts, and creative timer alerts.
- 📁 **Iconified `ls`**: Built-in file listing with custom icons (📂, 🏗, 📝, ⚙️).
- 🔍 **History Search**: Custom in-house prefix search via Up/Down arrows.
- ⚡ **Zero Bloat**: All unnecessary Python build tools and external libraries removed.

**Proprietary cvui System Font**:
- 🖋 **Classic Look**: Clear, readable style.
- 🛠 **Icon Support**: Full support for emojis, icons, and glyphs (Nerd Font compatible).
- 📦 **Bundled**: The font comes bundled with the installation (`assets/fonts/cvui.ttf`).

---

## 🚀 Installation

```bash
pkg update && pkg upgrade -y && pkg install git -y && git clone https://github.com/cybervaultke/cvui-legacy.git && cd cvui-legacy/install && bash install.sh
```

The installer:
1. Installs minimal system packages.
2. Deploys the proprietary **`cvui.ttf`** system font.
3. Sets up the custom-made zsh framework.
4. Symlinks `cvui` into your PATH.

---

## 🗣 KAI Commands

| Command | Description |
|---|---|
| `ask <q...>` | Ask KAI anything (AI-powered) |
| `joke` / `fact` | AI-generated jokes or facts |
| `timer <min>` | Pomodoro timer with voice alerts |
| `weather [city]` | Weather via wttr.in |
| `sysinfo` | System information panel |
| `time` / `date` | Live clock and date |
| `ls` / `ll` / `la` | Iconified file listing |
| `theme [name]` | Switch prompt themes |
| `noauth [on|off]` | Toggle session lock (auth) |
| `update` | Manually check/pull updates |
| `exit` / `quit` | Shut down cvui |

---

## ⌨️ Custom Key Bindings

| Key | Action |
|---|---|
| `Up Arrow` | Search history (prefix match) |
| `Down Arrow` | Search history (prefix match) |

---

## 👤 Maker

Made with ⚡ by **cybervaultke**

- 🎬 YouTube — [youtube.com/@cybervaultke](https://youtube.com/@cybervaultke)
- 📸 Instagram — [instagram.com/kash.sight](https://instagram.com/kash.sight)
- 📘 Facebook — [facebook.com/kash1sight](https://facebook.com/kash1sight)
- 💻 GitHub — [github.com/cybervaultke](https://github.com/cybervaultke)

---

## 📜 License

MIT — see [LICENSE](LICENSE).
