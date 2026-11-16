# aspects/neovim.nix
# Aspect: Neovim editor with Nix-packaged plugins/LSPs and live out-of-store init.lua
_: {
  den.aspects.neovim.homeManager =
    { config, pkgs, ... }:
    {
      programs.neovim = {
        enable = true;
        sideloadInitLua = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        extraPackages = with pkgs; [
          nixd

          lua-language-server
          stylua

          bash-language-server
          shellcheck
          shfmt

          marksman
          taplo
          yaml-language-server
          vscode-langservers-extracted
        ];

        plugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          nvim-web-devicons
          (nvim-treesitter.withPlugins (
            p: with p; [
              bash
              diff
              git_config
              git_rebase
              gitcommit
              gitignore
              json
              kdl
              lua
              luadoc
              markdown
              markdown_inline
              nix
              python
              query
              regex
              sql
              toml
              vim
              vimdoc
              yaml
            ]
          ))
          oil-nvim
          plenary-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
          nvim-lspconfig
          blink-cmp
          conform-nvim
          gitsigns-nvim
          which-key-nvim
          mini-nvim
          markdown-preview-nvim
        ];
      };

      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos/config/nvim";
    };
}
