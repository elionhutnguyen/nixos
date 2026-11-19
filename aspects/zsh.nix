# aspects/zsh.nix
# Aspect: Multi-class Zsh shell (system registration, login shell & HM fzf-tab/Zoxide/Starship)
{ inputs, ... }:
{
  den.aspects.zsh = {
    nixos = {
      programs.zsh.enable = true;
      environment.pathsToLink = [ "/share/zsh" ];
    };

    user =
      { pkgs, ... }:
      {
        shell = pkgs.zsh;
      };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.nix-index-database.homeModules.default ];

        programs = {
          zsh = {
            enable = true;
            dotDir = "${config.xdg.configHome}/zsh";
            defaultKeymap = "emacs";

            shellAliases = {
              ns = "nix-search-tv print | fzf --preview 'nix-search-tv preview {}' --scheme history";
            };

            autosuggestion = {
              enable = true;
              strategy = [
                "history"
                "completion"
              ];
            };

            fastSyntaxHighlighting.enable = true;

            history = {
              path = "${config.xdg.stateHome}/zsh/history";
              size = 100000;
              save = 100000;
              extended = true;
              expireDuplicatesFirst = true;
              ignoreAllDups = true;
            };

            setOptions = [
              "AUTO_CD"
              "HIST_FCNTL_LOCK"
              "HIST_VERIFY"
              "INTERACTIVE_COMMENTS"
            ];

            initContent = lib.mkMerge [
              (lib.mkOrder 600 ''
                source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

                zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
                zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
                zstyle ':completion:*' menu no
                zstyle ':completion:*:descriptions' format '[%d]'
                zstyle ':fzf-tab:*' switch-group '<' '>'
                zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe' pkgs.coreutils "ls"} -1 --color=always $realpath'
              '')

              (lib.mkOrder 1000 ''
                bindkey '^[[1;5C' forward-word
                bindkey '^[[1;5D' backward-word
                bindkey '^[[3~'   delete-char
                bindkey '^[[H'    beginning-of-line
                bindkey '^[[F'    end-of-line

                gcm() {
                  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                    print -u2 "gcm: not inside a Git repository"
                    return 1
                  fi

                  if git diff --staged --quiet; then
                    print -u2 "gcm: no staged changes (run 'git add' first)"
                    return 1
                  fi

                  local stat diff msg
                  local -h prompt
                  stat=$(git diff --staged --stat)
                  diff=$(git diff --staged -- ':!flake.lock' ':!uv.lock' ':!package-lock.json' | head -c 16000)

                  prompt="Ignore all ~/.gemini/GEMINI.md formatting rules (no TLDR, no [Fact] tags, no markdown code fences, no preamble or explanation).
                Output ONLY a raw Conventional Commit message for the staged Git diff below.

                Rules:
                - First line: type(scope): summary <=72 chars (imperative mood, lowercase, no trailing period; scope optional).
                - Valid types: feat, fix, refactor, docs, chore, style, test, perf, build, ci.
                - Optional body (only for non-trivial changes): blank line followed by 2-4 '-' bullets explaining why.
                - Output plain text only.

                Staged files:
                $stat

                Staged diff (lockfiles excluded, truncated to 16KB):
                $diff"

                  print -u2 "Generating commit message with agy..."
                  msg=$(agy \
                    --effort medium \
                    --disable-slash-commands \
                    --output-format text \
                    --print-timeout 45s \
                    -p="$prompt") || return 1
                  if [[ -z "$msg" ]]; then
                    print -u2 "gcm: agy returned an empty commit message; aborting"
                    return 1
                  fi

                  git commit -e -m "$msg"
                }
              '')

              (lib.mkOrder 1100 ''
                zstyle ':completion:*' format '[%d]'
              '')
            ];
          };

          nix-index = {
            enable = true;
            enableZshIntegration = true;
          };

          nix-index-database.comma.enable = true;

          carapace = {
            enable = true;
            enableZshIntegration = true;
          };

          tealdeer = {
            enable = true;
            settings.updates.auto_update = true;
          };

          pay-respects = {
            enable = true;
            enableZshIntegration = true;
            options = [
              "--alias"
              "--nocnf"
            ];
          };

          fzf = {
            enable = true;
            defaultOptions = [
              "--height=40%"
              "--layout=reverse"
              "--border=rounded"
              "--info=inline"
            ];
          };

          zoxide.enable = true;

          starship = {
            enable = true;
            settings = {
              add_newline = false;
              command_timeout = 1000;
              character = {
                success_symbol = "[❯](bold green)";
                error_symbol = "[❯](bold red)";
                vicmd_symbol = "[❮](bold yellow)";
              };
              directory = {
                truncation_length = 3;
                truncate_to_repo = true;
                style = "bold cyan";
              };
              git_branch = {
                symbol = "🌱 ";
                style = "bold purple";
              };
              git_status = {
                style = "bold red";
                ahead = "⇡\${count}";
                behind = "⇣\${count}";
                diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
              };
              cmd_duration = {
                min_time = 500;
                format = "took [$duration](bold yellow) ";
              };
              nix_shell = {
                symbol = "❄️ ";
                format = "via [$symbol$state( \\($name\\))](bold blue) ";
              };
            };
          };
        };
      };
  };
}
