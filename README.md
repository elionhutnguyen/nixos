# Elio NixOS Configuration (Den Aspect Architecture)

Modular NixOS + Home Manager configuration for `elio-laptop` (`x86_64-linux`) built on `nixos-unstable`, `flake-parts`, `import-tree`, and `den`.

## How It Is Organized

`flake.nix` automatically imports every `.nix` file under `aspects/`, `hosts/`, and `users/` via `import-tree`:

- `flake.nix` & `flake.lock` — Flake inputs (`nixpkgs` unstable, `den`, `flake-parts`, `home-manager`, `import-tree`) and pinned versions.
- `hosts/elio-laptop/` — Machine-specific hardware config (`_hardware-configuration.nix`), ASUS WMI module, NVIDIA PRIME bus IDs, and host aspect list.
- `users/elio.nix` — User identity (`elio`) and personal workspace aspects.
- `aspects/` — Reusable, single-purpose modules split by system (`nixos`), user (`user`), and Home Manager (`homeManager`) layers:
  - **System & Hardware:** `defaults.nix`, `system.nix`, `nix-daemon.nix`, `nvidia-prime.nix`, `power-management.nix`, `storage.nix`, `locale.nix` (`Asia/Taipei`, `fcitx5`)
  - **Desktop & Look:** `desktop.nix` (`Niri`, `greetd`/`tuigreet`, `Ghostty`, `Noctalia`), `theming.nix` (`Catppuccin`, `JetBrainsMono Nerd Font`, `Adwaita`), `media.nix` (`PipeWire`, `mpv`), `xdg.nix`
  - **Dev & Apps:** `zsh.nix` (`fzf-tab`, `zoxide`, `starship`), `neovim.nix`, `vcs.nix` (`git` + SSH signing + `delta`, `gh`), `cli-tools.nix` (`yazi`, `ripgrep`, `fd`, `btop`), `python.nix` (`uv`, `ruff`, `basedpyright`, `duckdb`, `sqlite`), `antigravity.nix` (`agy`), `firefox.nix`, `gui-apps.nix`, `gaming.nix`
- `config/` — Mutable app configs symlinked directly into `$HOME` via `mkOutOfStoreSymlink`:
  - `config/niri/config.kdl` → `~/.config/niri` (Niri reloads live on save)
  - `config/nvim/init.lua` → `~/.config/nvim` (restart `nvim` to apply)
  - `config/agy/GEMINI.md` → `~/.gemini/GEMINI.md` (applies on next `agy` run)

## Important Rules Before Editing

1. **Live configs vs. `.nix` files:** Edits inside `config/` take effect without rebuilding NixOS; edits to `.nix` files require a rebuild.
2. **Track new files in Git first:** Nix Flakes ignore untracked files. Whenever you create a new `.nix` file, run `git add <file>` before building.
3. **Never delete `hosts/elio-laptop/_hardware-configuration.nix`:** It holds your disk UUIDs and boot mounts.

## Common Commands

`nh` is preconfigured in `aspects/nix-daemon.nix` to use `/home/elio/workspace/nixos` automatically.

```bash
# 1. Format and lint Nix files before building
nixfmt .
statix check .
deadnix .

# 2. Validate flake evaluation and test-build WITHOUT changing the running system
nix flake check
nh os build

# 3. Apply changes to the live system (prompts for sudo password)
nh os switch
