# aspects/antigravity.nix
# Aspect: Google Antigravity CLI (`agy`) tuned for Google AI Pro efficiency
_: {
  den.aspects.antigravity.homeManager =
    { config, ... }:
    {
      home.file.".gemini/GEMINI.md".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/nixos/config/agy/GEMINI.md";

      programs.antigravity-cli = {
        enable = true;
        enableMcpIntegration = true;

        # Merge declarative settings into a writable file on activation so
        # Google AI Pro OAuth sign-in can persist auth state in settings.json.
        mutableSettings = true;

        permissions = {
          allow = [
            "read_file(/nix)"
            "read_file(/run)"
            "read_file(/etc)"
            "read_file(${config.home.homeDirectory}/workspace)"
            "write_file(/tmp)"
            "command(nix)"
            "command(nh)"
            "command(nixos-rebuild)"
            "command(git)"
            "command(gh)"
            "command(fd)"
            "command(rg)"
            "command(nixfmt)"
            "command(statix)"
            "command(deadnix)"
            "command(shellcheck)"
            "command(shfmt)"
            "command(stylua)"
            "command(trash-put)"
            "command(python3)"
            "command(pytest)"
            "command(ruff)"
            "command(basedpyright)"
            "command(uv)"
            "command(sqlite3)"
            "command(duckdb)"
          ];

          deny = [
            "read_file(.env)"
            "read_file(.env.local)"
            "read_file(.env.production)"
            "read_file(${config.home.homeDirectory}/.ssh)"
            "read_file(data/)"
            "read_file(/home/data)"
            "read_file(datasets/)"
            "write_file(.git/)"
            "command(rm -rf)"
            "command(sudo)"
          ];

          ask = [
            "command(git push)"
            "command(git reset --hard)"
            "command(git clean)"
            "command(nh os switch)"
            "command(nixos-rebuild switch)"
          ];
        };

        settings = {
          agentMode = "auto";
          enableTerminalSandbox = true;
          toolPermission = "proceed-in-sandbox";
          allowNonWorkspaceAccess = false;
          altScreenMode = "always";
          artifactReviewPolicy = "always-proceed";
          showTips = false;
          showFeedbackSurvey = false;
        };
      };
    };
}
