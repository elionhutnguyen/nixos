# Elio's NixOS Configuration (`~/workspace/nixos`)

A declarative, reproducible NixOS configuration built on **Nix Flakes**, **Den** (aspect-oriented composition), **`import-tree`** (automatic file discovery), and **Home Manager**, tailored for an ASUS AMD + NVIDIA hybrid laptop (`elio-laptop`) running the **Niri** Wayland compositor.

---

## 1. Plain-English Mental Model (How This Repo Works)

If you are new to NixOS, you only need four concepts to navigate everything here:

1. **Declarative System (`flake.nix` + `flake.lock`):**
   - Instead of running `apt install` and losing track of tweaks, your entire OS, desktop, apps, and terminal settings are described in `.nix` text files.
   - `flake.lock` pins exact versions of `nixpkgs` (`nixos-unstable`), `home-manager`, `nix-index-database`, `den`, `flake-parts`, and `import-tree` so rebuilds behave predictably.
2. **Automatic File Loading (`import-tree`):**
   - `flake.nix` automatically imports every `.nix` file inside `aspects/`, `hosts/`, and `users/`.
   - Files starting with `_` (like `hosts/elio-laptop/_hardware-configuration.nix`) are skipped by `import-tree` and imported manually where needed.
3. **Feature-Based Aspects (`den`):**
   - Each file in `aspects/` groups **one topic** (for example `desktop.nix`, `media.nix`, `zsh.nix`) in a single place—combining system-level NixOS rules (`nixos = ...`), user account rules (`user = ...`), and personal app configs (`homeManager = ...`).
   - `hosts/elio-laptop/default.nix` selects machine-wide aspects (12 host aspects); `users/elio.nix` selects personal workspace aspects (8 user aspects).
4. **Live-Reloaded Configs (`mkOutOfStoreSymlink`) vs. Rebuilt Configs:**
   - **No rebuild needed (instant/app-reload):** `config/niri/config.kdl`, `config/nvim/init.lua`, `config/agy/GEMINI.md`, and `config/agy/skills/` are symlinked straight into `~/.config/` and `~/.gemini/`. Edit and save them directly.
   - **Rebuild needed (`nh os switch`):** Any change inside `flake.nix`, `aspects/`, `hosts/`, or `users/`.

---

## 2. Repository Map

```text
nixos/
├── flake.nix                         # Entry point: 6 flake inputs + auto-import of aspects/, hosts/, users/
├── flake.lock                        # Pinned commits for reproducible builds
├── README.md                         # This guide
├── hosts/
│   └── elio-laptop/
│       ├── default.nix               # Host entity: ASUS module, GPU PCI IDs, user `elio`, 12 host aspects
│       └── _hardware-configuration.nix # Auto-generated disk UUIDs (/, /boot, /home/data, swap) & AMD microcode
├── users/
│   └── elio.nix                      # User entity: Git identity (`elionhutnguyen`) + 8 user aspects
├── config/                           # Live-symlinked dotfiles (changes apply without NixOS rebuild)
│   ├── agy/
│   │   ├── GEMINI.md                 # Global AI assistant rules -> ~/.gemini/GEMINI.md
│   │   └── skills/                   # Reusable AI skills (`career-strategy`, `coding-standards`, `strict-audit`) -> ~/.gemini/config/skills
│   ├── niri/config.kdl               # Niri compositor layout, window rules & keybinds -> ~/.config/niri
│   └── nvim/init.lua                 # Neovim plugins, LSPs, Telescope & formatters -> ~/.config/nvim
└── aspects/                          # 21 modular building blocks (auto-discovered by import-tree)
    ├── defaults.nix                  # Baseline stateVersion ("26.05"), Home Manager integration & Den batteries
    ├── system.nix                    # Kernel, systemd-boot (10 gens), zram (50% zstd), tmpfs /tmp, NetworkManager, hotspot firewall, Bluetooth, DNS (1.1.1.1/9.9.9.9), oomd, fstrim, fwupd, journald caps & ananicy-cpp
    ├── nix-daemon.nix                # Unfree packages, flakes, nixpkgs registry, nix-ld, nh helper, weekly GC & store optimization
    ├── nvidia-prime.nix              # NVIDIA open driver, PRIME offload, VA-API & cardwired eBPF GPU switcher
    ├── power-management.nix          # Power profiles, UPower, 80% battery charge limit & Bluetooth USB autosuspend fix
    ├── storage.nix                   # USB/removable auto-mounting (udisks2/gvfs/udiskie), LocalSend LAN sharing & /home/data permissions
    ├── locale.nix                    # Asia/Taipei timezone, en_GB/ja_JP/zh_TW locales, fcitx5 (VN/CN) & Noctalia nightlight
    ├── desktop.nix                   # Niri Wayland compositor, greetd/tuigreet login, keyring, Ghostty, Noctalia & grim/satty
    ├── theming.nix                   # Fonts (JetBrainsMono Nerd Font + Noto/CJK), Catppuccin dark/light & Adwaita GTK/Qt/cursor
    ├── media.nix                     # PipeWire audio, rtkit, mpv (Wayland + uosc + sponsorblock), wiremix & playerctl/playerctld
    ├── gaming.nix                    # faugus-launcher, steam-run, nwjs & GTK2 deprecation warning handler
    ├── zsh.nix                       # Zsh, fzf-tab, carapace, nix-index/comma, tealdeer, pay-respects, zoxide, starship, `ns` & `gcm`
    ├── cli-tools.nix                 # ripgrep, fd, btop, yazi (media previews), trash-cli, nix-search-tv, nixfmt/statix/deadnix & GPU/HW diagnostics (`nvtop`, `pciutils`, `usbutils`)
    ├── neovim.nix                    # Neovim (`vi`/`vim`/`vimdiff` aliases), 21 Treesitter grammars & Nix/Lua/Bash/Markdown/TOML/YAML/JSON LSPs
    ├── vcs.nix                       # Git (SSH commit signing, delta diffs, zdiff3), SSH agent & GitHub CLI (`gh`)
    ├── python.nix                    # Python 3, uv, ruff, basedpyright, sqlite, duckdb, visidata & nix-ld `LD_LIBRARY_PATH`
    ├── research.nix                  # Zathura PDF reader, JabRef reference manager & Typst typesetting
    ├── antigravity.nix               # Google Antigravity CLI (`agy`) with live `GEMINI.md` + `skills/`, MCP, sandbox & tool permissions
    ├── firefox.nix                   # Hardened Firefox (Brave default search, DoH, HTTPS-Only, strict tracking protection, AI/telemetry disabled)
    ├── gui-apps.nix                  # Anki, Brave Origin, Materialgram, OnlyOffice & VS Code
    └── xdg.nix                       # Keeps `~` clean (redirects unused XDG dirs to ~/.local/share/xdg-unused + XDG env vars for dev tools)
```

---

## 3. Daily Commands (Step-by-Step)

Because `aspects/nix-daemon.nix` enables **`nh`** and points it to `/home/elio/workspace/nixos`, you do not need long `sudo nixos-rebuild` commands.

### Safe Update Workflow (Recommended Every Time)
Always test-compile before switching your live desktop:

```bash
# 1. Enter your NixOS folder
cd ~/workspace/nixos

# 2. If you created any NEW .nix file, stage it so Nix Flakes can see it
git add aspects/<new-file>.nix

# 3. If you added a NEW input to flake.nix, lock only the new input first
nix flake lock

# 4. Optional: check formatting & unused Nix code before building
fd -e nix -X nixfmt --check
statix check .
deadnix .

# 5. Test-build WITHOUT modifying your running system or boot menu
nh os build

# 6. If step 5 succeeds, apply the build AND add a new boot entry (asks for sudo password)
nh os switch

# 7. Optional: commit your verified config changes with AI-drafted message (review in Neovim)
git add -A
gcm
```

### Other Useful `nh` & Flake Commands

| Command | What It Does | When to Use It |
| :--- | :--- | :--- |
| `nh os build` | Compiles configuration only | Safe check before switching |
| `nh os switch` | Compiles, activates now, and sets as default boot entry | Normal updates after editing `.nix` files |
| `nh os test` | Compiles and activates now, **without** adding a boot entry | Testing risky changes (rebooting reverts them) |
| `nh os boot` | Compiles and sets for **next reboot** only | Kernel/NVIDIA driver updates before a clean restart |
| `nix flake lock` | Locks newly added `flake.nix` inputs without upgrading existing ones | Right after adding a new input to `flake.nix` |
| `nix flake check` | Validates flake structure and checks | Sanity check before committing or updating |
| `nix flake update` | Updates `flake.lock` to latest upstream commits | Periodic upgrades (always run `nh os build` afterward!) |
| `nh clean all` | Manually deletes old generations/unused store paths | Freeing extra disk space (auto-runs weekly keeping 5 gens / 7d) |

### How to Roll Back If Anything Breaks
1. **If you can still open a terminal:** Undo your bad edit (or `git checkout -- <file>`) and run `nh os switch`.
2. **If your desktop won't boot:** Restart the laptop, pick an earlier **NixOS Generation** in the `systemd-boot` menu at startup, log in normally, and fix the config.

---

## 4. Keybindings & Interactive Shortcuts Cheatsheet

### Niri Desktop (`Mod` = Windows / Super Key)
Configured in `config/niri/config.kdl` *(volume, media playback, and brightness hardware keys also work while the lock screen is active)*:

| Action | Shortcut | Notes |
| :--- | :--- | :--- |
| Show hotkey cheatsheet | `Mod + Shift + /` | Built-in Niri overlay |
| Open Terminal (Ghostty) | `Mod + T` | Borderless Catppuccin theme |
| App Launcher | `Mod + D` | Noctalia launcher |
| Control Center | `Mod + S` | Wi-Fi, Bluetooth, audio, brightness |
| Toggle Top Bar | `Mod + B` | Bar auto-hides (`reserve_space = false`) |
| File Manager (Yazi) | `Mod + E` | Opens Yazi inside Ghostty |
| Screenshot & Annotate (Satty) | `Mod + Shift + S` | Captures focused display via `grim` into Satty (`c` crop, `u` blur/redact, `Ctrl+C` copy & exit, `Esc` cancel) |
| Lock Screen / Monitors Off | `Mod + Alt + L` / `Mod + Shift + P` | Auto-locks after 5 min, screen off after 10 min |
| Mirror Focused Screen (HDMI) | `Mod + P` | Uses `wl-mirror` on current monitor |
| Close Window / Overview | `Mod + Q` / `Mod + O` | `Mod + Shift + E` or `Ctrl + Alt + Del` quits Niri |
| Move Focus | `Mod + H / J / K / L` | Hold `Ctrl` (`Mod + Ctrl + ...`) to move column/window |
| First / Last Column | `Mod + Home` / `Mod + End` | Hold `Ctrl` (`Mod + Ctrl + Home/End`) to move column there |
| Switch Workspace | `Mod + 1..9`, `Mod + U / I`, `PageUp/Down` | Add `Ctrl` to move column; `Shift + U/I` or `Shift + PageUp/Down` moves workspace |
| Column Width Presets | `Mod + R` / `Mod + Shift + R` | Cycles `1/3`, `1/2`, `2/3` screen width forward/backward |
| Window Height Presets / Reset | `Mod + Ctrl + Shift + R` / `Mod + Ctrl + R` | Cycles preset window height or resets height |
| Fine Resize Width / Height | `Mod + - / =` (add `Shift` for height) | Adjusts by `±10%` |
| Maximize / Fullscreen / Edge-Max | `Mod + F` / `Mod + Shift + F` / `Mod + M` | `Mod + Ctrl + F` expands column to available width |
| Center Column / Visible Columns | `Mod + C` / `Mod + Ctrl + C` | Centers active column or all visible columns |
| Float / Tabbed Column | `Mod + V` / `Mod + W` | `Mod + Shift + V` swaps focus between tiled and floating |
| Consume / Expel Window | `Mod + [ or ]` / `Mod + , or .` | `[`/`]` stacks/unstacks left/right; `,`/`.` consumes/expels in current column |
| Screencast Target Controls | `Mod + Shift + C` / `Mod + Ctrl + Shift + C` | Window / monitor dynamic cast; `Mod + Alt + C` clears target (auth dialogs auto-hidden from screencasts) |
| Toggle Shortcut Inhibit | `Mod + Escape` | Passes keybinds straight through to VMs/remote sessions |

### Neovim (`<Space>` = Leader Key)
Configured in `config/nvim/init.lua` *(beginner tip: press `<Space>` and pause ~0.3s in Normal mode to open the interactive **`which-key`** shortcut popup; `gitsigns` automatically marks edited lines in the left gutter with `+`/`~`/`_`)*:

| Action | Shortcut | Tool |
| :--- | :--- | :--- |
| Interactive Shortcut Menu | `<Space>` (then pause) | `which-key.nvim` (lists all `<Space>` groups & bindings) |
| File Explorer (current folder) | `-` | `oil.nvim` (edit filenames like a buffer; deletes to Trash; shows hidden files) |
| Find Files / Live Text Search | `<Space> s f` / `<Space> s g` | `Telescope` |
| Search Open Buffers / Word | `<Space> <Space>` / `<Space> s w` | `Telescope` |
| Diagnostics / Keymaps Search | `<Space> s d` / `<Space> s k` | `Telescope` |
| Search Help / Resume Last Search | `<Space> s h` / `<Space> s r` | `Telescope` |
| Show Diagnostic Error / List | `<Space> e` / `<Space> q` | Floating error popup / diagnostic location list (`setloclist`; inline diagnostics also shown automatically) |
| Hover Docs / Function Info | `K` | Native LSP (built-in hover popup; `blink.cmp` also shows docs & signature hints while typing) |
| Go to Definition / References | `g d` / `g r` | Native LSP (via Telescope) |
| Implementation / Declaration | `g I` / `g D` | Native LSP (`<Space> D` for type definition; `<Space> d s` for document symbols) |
| Rename Symbol / Code Action | `<Space> r n` / `<Space> c a` | Native LSP (`<Space> c a` works in Normal and Visual modes) |
| Format Buffer | `<Space> c f` (also runs on save) | `conform.nvim` (`nixfmt`, `stylua`, `ruff_format`, `shfmt`) |
| Toggle Markdown Preview | `<Space> m p` | `markdown-preview.nvim` |
| Move Between Window Splits | `Ctrl + h / j / k / l` | Standard Vim split navigation |
| Exit Terminal Mode | `Esc` `Esc` | Leaves Neovim built-in terminal back to Normal mode |
| Clear Search Highlight | `Esc` | Normal mode |

### Zsh Terminal, Git & Nix Helpers
Configured in `aspects/zsh.nix`, `aspects/cli-tools.nix`, `aspects/neovim.nix`, `aspects/python.nix`, and `aspects/vcs.nix`:
- `ns` — Interactive fuzzy search across Nixpkgs & NixOS/Home Manager options (`nix-search-tv` + `fzf` live preview).
- `, <cmd>` — Runs any uninstalled Nixpkgs CLI tool on demand without installing it (powered by `comma` + prebuilt `nix-index-database` + locked `nixpkgs` registry).
- Missing command suggestions (`nix-index`) — Typing an uninstalled command automatically tells you which Nix package provides it.
- `tldr <cmd>` — Concise, example-first command cheatsheets via `tealdeer` (auto-updates cache).
- `f` (or `Ctrl + X` then `Ctrl + X`) — Suggests and fixes your last mistyped shell command (`pay-respects`, configured with `--nocnf` so it never conflicts with `nix-index`).
- `Tab` completion hints (`carapace` + `fzf-tab`) — Interactive fuzzy flag/subcommand completion with clean `[group]` headers (`<` / `>` switches groups).
- `vd <file>` — Opens CSV, TSV, JSON, Parquet, or SQLite files in **VisiData**, an interactive terminal spreadsheet/data explorer.
- `git st` / `git lg` / `git unstage <file>` — Compact Git status, colorized commit graph, and unstaging helper (`aspects/vcs.nix`).
- `gcm` — Stage files with `git add`, then run `gcm` to generate a Conventional Commit message via `agy` and review it in Neovim before signing (save & sign with `:wq`, or cancel without committing using `:cq`).
- `vi` / `vim` / `vimdiff` — Aliased to **Neovim** (`aspects/neovim.nix`).
- `y` — Opens **Yazi** file manager and drops your shell into whichever folder you navigated to when quitting.
- `z <name>` — Smart folder jump via **zoxide** (remembers folders you visit often).
- `rg <text>` / `fd <name>` — Fast text search (`ripgrep`) and file search (`fd`).
- `trash-put <file>` — Moves files to Trash safely (prefer this over `rm`).
- `wiremix` / `btop` / `nvtop` — Terminal audio mixer and CPU/GPU monitors.

---

## 5. Hardware, Apps & Development Workflows

### Hybrid GPU, Power & Home Directory Hygiene
- **Default GPU mode:** Desktop apps render on the integrated AMD GPU to save battery (`cardwired` automatically switches GPU state on battery vs. AC and external displays; NVIDIA fine-grained power management is enabled in `aspects/nvidia-prime.nix`).
- **Run a heavy app on the NVIDIA GPU:**
  ```bash
  nvidia-offload <command>
  ```
- **Battery protection:** Charging automatically stops at **80%** (`aspects/power-management.nix`).
- **XDG Home Cleanup (`aspects/xdg.nix`):** Only `Documents`, `Downloads`, and `Pictures` live directly in `~`; `Desktop`, `Music`, `Videos`, `Templates`, and `Public` are routed to `~/.local/share/xdg-unused`, and dev tool caches/configs (`cargo`, `rustup`, `go`, `npm`, `node`, `gnupg`, `docker`, `dotnet`, NVIDIA/CUDA shader caches) are steered into `~/.config`, `~/.local/share`, `~/.local/state`, and `~/.cache`.

### Python, Data & Academic Research Workflows (`uv`, `visidata`, `research.nix`)
- **`nix-ld` + `uv` (Python projects):** `aspects/nix-daemon.nix` enables **`nix-ld`** (and `aspects/python.nix` exports `LD_LIBRARY_PATH`), allowing precompiled Python wheels downloaded by `uv` (like `numpy`, `scipy`, `pandas`, `opencv-python-headless`) to run seamlessly on NixOS. Inside project repos like `~/workspace/career`, use **`uv`** instead of modifying global NixOS packages:
  ```bash
  cd ~/workspace/career
  uv sync              # Creates/updates isolated .venv from pyproject.toml & uv.lock
  uv run pytest -v     # Runs tests inside that environment
  ```
- **Data Inspection & SQL (`aspects/python.nix`):**
  ```bash
  vd dataset.csv       # Interactive terminal spreadsheet (supports CSV, TSV, JSON, Parquet, SQLite)
  duckdb               # Fast in-process SQL analytics over CSV/Parquet files
  sqlite3 app.db       # Lightweight SQLite CLI
  ```
- **Academic Reading & Writing (`aspects/research.nix`):**
  - `zathura paper.pdf` — Fast, keyboard-driven PDF reader (Vim keys: `j`/`k` scroll, `/` search, `q` quit).
  - `jabref` — BibTeX/BibLaTeX reference manager (launch from terminal or `Mod + D` launcher; pairs cleanly with Typst).
  - `typst watch report.typ` — Live-compiles `.typ` manuscripts/CVs to PDF whenever you save.
- Neovim automatically activates `basedpyright` and `ruff` LSPs whenever those binaries are in your `PATH` (provided globally by `aspects/python.nix` or inside a `nix develop` shell).

### Browsers, Networking, Wi-Fi Hotspot & LAN File Sharing
- **Browsers (`aspects/firefox.nix`, `aspects/gui-apps.nix`):**
  - **Firefox** is hardened with enterprise policies: Brave as default search engine, strict tracking protection, HTTPS-Only, DNS-over-HTTPS (Cloudflare), Post-Quantum key agreement, telemetry/AI disabled, and automatic cache + form-data cleanup on shutdown (history, cookies, and sessions are preserved).
  - **Brave Origin** is also installed with `--disable-accelerated-video-encode` for Wayland/hybrid-GPU stability.
- **Wi-Fi Hotspot Ready (`aspects/system.nix`):** Firewall ports **53 (TCP/UDP)** and **67 (UDP)** are pre-opened so NetworkManager's built-in Wi-Fi hotspot (`dnsmasq` DNS + DHCP) works out of the box without clients hanging on "Obtaining IP address".
- **Privacy-Respecting DNS (`aspects/system.nix`):** `systemd-resolved` uses **Cloudflare (`1.1.1.1`)** and **Quad9 (`9.9.9.9`)** as fallback resolvers with opportunistic DNS-over-TLS.
- **LocalSend (`aspects/storage.nix`):** Installed system-wide with firewall port **53317** automatically opened (`openFirewall = true`) for fast, offline LAN file transfers with phones/tablets/other laptops.

### Adding or Removing Software
- **Run a CLI tool once (zero config change):**
  ```bash
  , htop                   # Instant one-shot run via comma + nix-index-database
  nix shell nixpkgs#htop   # Opens a temporary subshell containing the package (uses your locked nixpkgs)
  ```
- **Add a permanent package:** Place it in the matching aspect file, then run `nh os build && nh os switch`:
  - `aspects/gui-apps.nix` — General desktop GUI apps
  - `aspects/cli-tools.nix` — Terminal utilities, Nix linters & hardware diagnostics
  - `aspects/research.nix` — Academic PDF/reference/typesetting tools
  - `aspects/python.nix` — Global Python/SQL/data CLI tools
- **Add a new aspect file:** Create `aspects/<topic>.nix` defining `den.aspects.<topic> = { ... };`, include it in `hosts/elio-laptop/default.nix` (system-wide) or `users/elio.nix` (user-only), stage the new file with `git add aspects/<topic>.nix` (Git-tracked flakes only see tracked files!), and run `nh os build && nh os switch`.

---

## 6. First-Time Setup & Machine-Specific Gotchas

1. **Git SSH Commit Signing & GitHub Push Rewrite (`aspects/vcs.nix`):**
   - `signByDefault = true` signs every commit using `~/.ssh/id_ed25519.pub`, and `pushInsteadOf` automatically rewrites `https://github.com/` pushes to `git@github.com:`.
   - On a fresh machine, make sure your SSH key exists and is added to GitHub before committing/pushing (`ssh-keygen -t ed25519 -C "elio.nhutnguyen@gmail.com"`).
2. **Hardware File Is Machine-Locked (`hosts/elio-laptop/_hardware-configuration.nix`):**
   - Partition UUIDs (`/`, `/boot`, `/home/data`, swap) and GPU PCI bus IDs (`PCI:1:0:0`, `PCI:5:0:0` in `hosts/elio-laptop/default.nix`) are specific to `elio-laptop`. Do not copy `_hardware-configuration.nix` to another computer without regenerating it (`nixos-generate-config`).
3. **Antigravity (`agy`) Authentication, Rules & Live Skills (`aspects/antigravity.nix`):**
   - Uses `mutableSettings = true` so your Google AI Pro OAuth session can persist inside `~/.gemini/antigravity-cli/settings.json` while keeping both `GEMINI.md` (`config/agy/GEMINI.md`) and custom skills (`config/agy/skills/` -> `~/.gemini/config/skills`) live-symlinked.
   - Tool permissions (`allow`/`deny`/`ask`) and terminal sandboxing are managed declaratively in `aspects/antigravity.nix` (global `read_file`/`write_file` deny rules must use **absolute paths** like `/home/data` so the terminal sandbox initializes cleanly).
4. **Input Methods (`fcitx5`):**
   - Configured in `aspects/locale.nix` with `fcitx5-bamboo` (Vietnamese) and `fcitx5-chinese-addons` (Traditional/Simplified Chinese), auto-started in `config/niri/config.kdl`. Run `fcitx5-configtool` in terminal if you want to adjust input-switching hotkeys.
5. **Home Manager `.backup` File Collisions (`aspects/defaults.nix`):**
   - `home-manager.backupFileExtension = "backup"` safely renames existing unmanaged dotfiles to `<file>.backup` instead of aborting on first switch.
   - If a later `nh os switch` ever errors with *"Existing file '...backup' would be clobbered"*, inspect that `.backup` file, move or trash it (`trash-put <path>.backup`), and re-run `nh os switch`.
