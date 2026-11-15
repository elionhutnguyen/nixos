# aspects/python.nix
# Aspect: Python 3 data/ML runtime & SQLite/DuckDB CLI tools
_: {
  den.aspects.python.homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        (pkgs.python3.withPackages (
          ps: with ps; [
            pytest
            numpy
            pandas
            scipy
            scikit-learn
            opencv4
            duckdb
            matplotlib
          ]
        ))
        pkgs.basedpyright
        pkgs.ruff
        pkgs.sqlite
        pkgs.duckdb
      ];
    };
}
