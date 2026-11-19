# aspects/antigravity.nix
# Aspect: Google Antigravity CLI (`agy`) tuned for Google AI Pro efficiency
_: {
  den.aspects.antigravity.homeManager =
    { config, ... }:
    let
      agyDir = "${config.home.homeDirectory}/workspace/nixos/config/agy";
    in
    {
      home.file = {
        ".gemini/GEMINI.md".source = config.lib.file.mkOutOfStoreSymlink "${agyDir}/GEMINI.md";
        ".gemini/config/skills".source = config.lib.file.mkOutOfStoreSymlink "${agyDir}/skills";
      };

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

          # Terminal sandbox requires absolute paths for global read_file/write_file deny rules
          # (relative paths like `.env` or `data/` cause `sandbox configuration error: non-absolute file path`).
          deny = [
            "read_file(${config.home.homeDirectory}/.ssh)"
            "read_file(/home/data)"
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
