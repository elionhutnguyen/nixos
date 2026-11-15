# aspects/python.nix
# Aspect: Canonical uv Python workflow, static analysis & SQLite/DuckDB CLI tools
_: {
  den.aspects.python.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.python3
        pkgs.basedpyright
        pkgs.ruff
        pkgs.uv
        pkgs.sqlite
        pkgs.duckdb
      ];

      home.sessionVariables = {
        LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib";
      };
    };
}
