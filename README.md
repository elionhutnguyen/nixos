# Elio's NixOS Configuration (`~/workspace/nixos`)

A declarative, reproducible NixOS configuration built on **Nix Flakes**, **Den** (aspect-oriented composition), **`import-tree`** (automatic file discovery), and **Home Manager**, tailored for an ASUS AMD + NVIDIA hybrid laptop (`elio-laptop`) running the **Niri** Wayland compositor.

---

## 1. Plain-English Mental Model (How This Repo Works)

If you are new to NixOS, you only need four concepts to navigate everything here:

1. **Declarative System (`flake.nix` + `flake.lock`):**
   - Instead of running `apt install` and losing track of tweaks, your entire OS, desktop, apps, and terminal settings are described in `.nix` text files.
   - `flake.lock` pins exact versions of `nixpkgs` (`nixos-unstable`), `home-manager`, `den`, `flake-parts`, and `import-tree` so rebuilds behave predictably.
2. **Automatic File Loading (`import-tree`):**
   - `flake.nix` automatically imports every `.nix` file inside `aspects/`, `hosts/`, and `users/`.
   - Files starting with `_` (like `hosts/elio-laptop/_hardware-configuration.nix`) are skipped by `import-tree` and imported manually where needed.
3. **Feature-Based Aspects (`den`):**
   - Each file in `aspects/` groups **one topic** (for example `desktop.nix`, `media.nix`, `zsh.nix`) in a single place—combining system-level NixOS rules (`nixos = ...`), user account rules (`user = ...`), and personal app configs (`homeManager = ...`).
   - `hosts/elio-laptop/default.nix` selects machine-wide aspects; `users/elio.nix` selects personal workspace aspects.
4. **Live-Reloaded Configs (`mkOutOfStoreSymlink`) vs. Rebuilt Configs:**
   - **No rebuild needed (instant/app-reload):** `config/niri/config.kdl`, `config/nvim/init.lua`, and `config/agy/GEMINI.md` are symlinked straight into `~/.config/` and `~/.gemini/`. Edit and save them directly.
   - **Rebuild needed (`nh os switch`):** Any change inside `flake.nix`, `aspects/`, `hosts/`, or `users/`.

---

## 2. Repository Map

```text
nixos/
├── flake.nix                         # Entry point: inputs + auto-import of aspects/, hosts/, users/
├── flake.lock                        # Pinned commits for reproducible builds
├── hosts/
│   └── elio-laptop/
│       ├── default.nix               # Host entity: ASUS module, GPU PCI IDs, user `elio`, host aspects
│       └── _hardware-configuration.nix # Auto-generated disk UUIDs (/, /boot, /home/data, swap) & CPU
├── users/
│   └── elio.nix                      # User entity: Git identity + user-level aspects
├── config/                           # Live-symlinked dotfiles (changes apply without NixOS rebuild)
│   ├── agy/GEMINI.md                 # Global AI assistant rules -> ~/.gemini/GEMINI.md
│   ├── niri/config.kdl               # Niri compositor layout, window rules & keybinds -> ~/.config/niri
│   └── nvim/init.lua                 # Neovim plugins, LSPs, Telescope & formatters -> ~/.config/nvim
└── aspects/                          # Modular building blocks (auto-discovered by import-tree)
    ├── defaults.nix                  # Baseline stateVersion ("26.05"), Home Manager integration & Den batteries
    ├── system.nix                    # Kernel, systemd-boot (10 gens), zram, NetworkManager, Bluetooth, DNS, oomd
    ├── nix-daemon.nix                # Unfree packages, flakes, nix-ld, nh helper, weekly GC & store optimization
    ├── nvidia-prime.nix              # NVIDIA open driver, PRIME offload, VA-API & cardwired eBPF GPU switcher
    ├── power-management.nix          # Power profiles, 80% battery charge limit & Bluetooth USB autosuspend fix
    ├── storage.nix                   # USB/removable auto-mounting (udisks2/udiskie) & /home/data permissions
    ├── locale.nix                    # Asia/Taipei timezone, en_GB/ja_JP/zh_TW locales, fcitx5 (VN/CN), nightlight
    ├── desktop.nix                   # Niri Wayland compositor, greetd/tuigreet login, keyring, Ghostty & Noctalia
    ├── theming.nix                   # Fonts (JetBrainsMono Nerd Font + Noto/CJK), Catppuccin dark/light & Adwaita
    ├── media.nix                     # PipeWire audio, rtkit, mpv (Wayland + uosc + sponsorblock), wiremix, playerctl
    ├── gaming.nix                    # faugus-launcher, steam-run, nwjs & GTK2 deprecation warning handler
    ├── zsh.nix                       # Zsh login shell, autosuggestions, syntax highlighting, fzf, zoxide, starship
    ├── cli-tools.nix                 # ripgrep, fd, btop, yazi (media previews), trash-cli, nixfmt/statix/deadnix
    ├── neovim.nix                    # Neovim + Treesitter grammars + Nix/Lua/Bash/Markdown/TOML/YAML/JSON LSPs
    ├── vcs.nix                       # Git (SSH commit signing, delta diffs, zdiff3), SSH agent & GitHub CLI (gh)
    ├── python.nix                    # uv, ruff, basedpyright, sqlite, duckdb + Python 3 data/CV packages
    ├── antigravity.nix               # Google Antigravity CLI (`agy`) with MCP, sandbox & tool permissions
    ├── firefox.nix                   # Hardened Firefox (Brave search, DoH, HTTPS-Only, strict tracking protection)
    ├── gui-apps.nix                  # Anki, Brave Origin, Materialgram, OnlyOffice & VS Code
    └── xdg.nix                       # Keeps ~ clean (redirects unused Desktop/Music/Videos to ~/.local/share)
```

---

## 3. Daily Commands (Step-by-Step)

Because `aspects/nix-daemon.nix` enables **`nh`** and points it to `/home/elio/workspace/nixos`, you do not need long `sudo nixos-rebuild` commands.

### Safe Update Workflow (Recommended Every Time)
Always test-compile before switching your live desktop:

```bash
# 1. Enter your NixOS folder
cd ~/workspace/nixos

# 2. Optional: check formatting & unused Nix code before building
nixfmt --check .
statix check .
deadnix .

# 3. Test-build WITHOUT modifying your running system or boot menu
nh os build

# 4. If step 3 succeeds, apply the build AND add a new boot entry (asks for sudo password)
nh os switch
```

### Other Useful `nh` & Flake Commands

| Command | What It Does | When to Use It |
| :--- | :--- | :--- |
| `nh os build` | Compiles configuration only | Safe check before switching |
| `nh os switch` | Compiles, activates now, and sets as default boot entry | Normal updates after editing `.nix` files |
| `nh os test` | Compiles and activates now, **without** adding a boot entry | Testing risky changes (rebooting reverts them) |
| `nh os boot` | Compiles and sets for **next reboot** only | Kernel/NVIDIA driver updates before a clean restart |
| `nix flake check` | Validates flake structure and checks | Sanity check before committing or updating |
| `nix flake update` | Updates `flake.lock` to latest upstream commits | Periodic upgrades (always run `nh os build` afterward!) |
| `nh clean all` | Manually deletes old generations/unused store paths | Freeing extra disk space (auto-runs weekly keeping 5 gens / 7d) |

### How to Roll Back If Anything Breaks
1. **If you can still open a terminal:** Undo your bad edit (or `git checkout -- <file>`) and run `nh os switch`.
2. **If your desktop won't boot:** Restart the laptop, pick an earlier **NixOS Generation** in the `systemd-boot` menu at startup, log in normally, and fix the config.

---

## 4. Keybindings & Interactive Shortcuts Cheatsheet

### Niri Desktop (`Mod` = Windows / Super Key)
Configured in `config/niri/config.kdl`:

| Action | Shortcut | Notes |
| :--- | :--- | :--- |
| Show hotkey cheatsheet | `Mod + Shift + /` | Built-in Niri overlay |
| Open Terminal (Ghostty) | `Mod + T` | Borderless Catppuccin theme |
| App Launcher | `Mod + D` | Noctalia launcher |
| Control Center | `Mod + S` | Wi-Fi, Bluetooth, audio, brightness |
| Toggle Top Bar | `Mod + B` | Bar auto-hides (`reserve_space = false`) |
| File Manager (Yazi) | `Mod + E` | Opens Yazi inside Ghostty |
| Screenshot to Clipboard | `Mod + Shift + S` | Saved straight to clipboard (`screenshot-path null`) |
| Lock Screen / Monitors Off | `Mod + Alt + L` / `Mod + Shift + P` | Auto-locks after 5 min, screen off after 10 min |
| Mirror Focused Screen (HDMI) | `Mod + P` | Uses `wl-mirror` on current monitor |
| Close Window / Overview | `Mod + Q` / `Mod + O` | `Mod + Shift + E` or `Ctrl + Alt + Del` quits Niri |
| Move Focus | `Mod + H / J / K / L` | Hold `Ctrl` (`Mod + Ctrl + ...`) to move column/window |
| Switch Workspace | `Mod + 1..9`, `Mod + U / I`, `PageUp/Down` | Add `Ctrl` to move column; `Shift + U/I` moves workspace |
| Column Width Presets | `Mod + R` / `Mod + Shift + R` | Cycles `1/3`, `1/2`, `2/3` screen width |
| Fine Resize Width / Height | `Mod + - / =` (add `Shift` for height) | Adjusts by `±10%` |
| Maximize / Fullscreen / Edge-Max | `Mod + F` / `Mod + Shift + F` / `Mod + M` | `Mod + C` centers column; `Mod + Ctrl + F` expands |
| Float / Tabbed / Stack Columns | `Mod + V` / `Mod + W` / `Mod + [ or ]` | `Mod + Shift + V` swaps focus between tiled and floating |
| Screencast Target Controls | `Mod + Shift + C` / `Mod + Ctrl + Shift + C` | `Mod + Alt + C` clears dynamic screencast target |

### Neovim (`<Space>` = Leader Key)
Configured in `config/nvim/init.lua`:

| Action | Shortcut | Tool |
| :--- | :--- | :--- |
| File Explorer (current folder) | `-` | `oil.nvim` (edit filenames like a buffer; deletes to Trash) |
| Find Files / Live Text Search | `<Space> s f` / `<Space> s g` | `Telescope` |
| Search Open Buffers / Word | `<Space> <Space>` / `<Space> s w` | `Telescope` |
| Diagnostics / Keymaps Search | `<Space> s d` / `<Space> s k` | `Telescope` |
| Go to Definition / References | `g d` / `g r` | Native LSP |
| Rename Symbol / Code Action | `<Space> r n` / `<Space> c a` | Native LSP |
| Format Buffer | `<Space> c f` (also runs on save) | `conform.nvim` (`nixfmt`, `stylua`, `ruff_format`, `shfmt`) |
| Toggle Markdown Preview | `<Space> m p` | `markdown-preview.nvim` |
| Move Between Window Splits | `Ctrl + h / j / k / l` | Standard Vim split navigation |
| Clear Search Highlight | `Esc` | Normal mode |

### Zsh Terminal Helpers
Configured in `aspects/zsh.nix` and `aspects/cli-tools.nix`:
- `y` — Opens **Yazi** file manager and drops your shell into whichever folder you navigated to when quitting.
- `z <name>` — Smart folder jump via **zoxide** (remembers folders you visit often).
- `rg <text>` / `fd <name>` — Fast text search (`ripgrep`) and file search (`fd`).
- `trash-put <file>` — Moves files to Trash safely (prefer this over `rm`).
- `wiremix` / `btop` / `nvtop` — Terminal mixers and CPU/GPU monitors.

---

## 5. Hardware, Apps & Development Workflows

### Hybrid GPU & Power Management
- **Default GPU mode:** Desktop apps render on the integrated AMD GPU to save battery (`cardwired` automatically adjusts GPU state on battery vs. AC/external displays).
- **Run a heavy app on the NVIDIA GPU:**
  ```bash
  nvidia-offload <command>
  ```
- **Battery protection:** Charging automatically stops at **80%** (`aspects/power-management.nix`).
- **XDG Home Cleanup:** Only `Documents`, `Downloads`, and `Pictures` live directly in `~`; `Desktop`, `Music`, `Videos`, `Templates`, and `Public` are quietly routed to `~/.local/share/xdg-unused` so browsers/Wine never clutter `~`.

### Python & Dry-Lab Research Workflow (`uv` + `nix-ld`)
- `aspects/nix-daemon.nix` enables **`nix-ld`**, allowing precompiled Python wheels downloaded by `uv` (like `numpy`, `scipy`, `pandas`, `opencv-python-headless`) to run seamlessly on NixOS.
- Inside project repos like `~/workspace/career`, use **`uv`** as your canonical project environment instead of modifying global NixOS packages:
  ```bash
  cd ~/workspace/career
  uv sync              # Creates/updates isolated .venv from pyproject.toml & uv.lock
  uv run pytest -v     # Runs tests inside that environment
  ```
- Neovim automatically activates `basedpyright` and `ruff` LSPs whenever those binaries are in your `PATH` (provided globally by `aspects/python.nix` or inside a `nix develop` shell).

### Adding or Removing Software
- **Try a CLI tool temporarily (zero config change):**
  ```bash
  nix shell nixpkgs#htop
  ```
- **Add a permanent GUI app:** Add its package name to `aspects/gui-apps.nix` (or `aspects/cli-tools.nix` for CLI tools), then run `nh os build && nh os switch`.
- **Add a new aspect file:** Create `aspects/<topic>.nix` defining `den.aspects.<topic> = { ... };`, include it in `hosts/elio-laptop/default.nix` (system-wide) or `users/elio.nix` (user-only), stage the new file with `git add aspects/<topic>.nix` (Git-tracked flakes only see tracked files!), and run `nh os build && nh os switch`.

---

## 6. First-Time Setup & Machine-Specific Gotchas

1. **Git SSH Commit Signing (`aspects/vcs.nix`):**
   - `signByDefault = true` signs every commit using `~/.ssh/id_ed25519.pub`.
   - On a fresh machine, make sure your SSH key exists before committing (or generate one via `ssh-keygen -t ed25519 -C "elio.nhutnguyen@gmail.com"` and add it to GitHub).
2. **Hardware File Is Machine-Locked (`hosts/elio-laptop/_hardware-configuration.nix`):**
   - Partition UUIDs (`/`, `/boot`, `/home/data`, swap) and GPU PCI bus IDs (`PCI:1:0:0`, `PCI:5:0:0`) are specific to `elio-laptop`. Do not copy `_hardware-configuration.nix` to another computer without regenerating it (`nixos-generate-config`).
3. **Antigravity (`agy`) Authentication:**
   - `aspects/antigravity.nix` uses `mutableSettings = true` so your Google AI Pro OAuth session can persist inside `~/.gemini/settings.json` while keeping `GEMINI.md` live-linked to `config/agy/GEMINI.md`.
4. **Input Methods (`fcitx5`):**
   - Configured in `aspects/locale.nix` with `fcitx5-bamboo` (Vietnamese) and `fcitx5-chinese-addons` (Traditional/Simplified Chinese), auto-started in `config/niri/config.kdl`. Run `fcitx5-configtool` in terminal if you want to adjust input-switching hotkeys.
