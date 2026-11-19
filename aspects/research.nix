# aspects/research.nix
# Aspect: Academic PDF reader, reference manager & scientific typesetting
_: {
  den.aspects.research.homeManager =
    { pkgs, ... }:
    {
      programs.zathura.enable = true;

      home.packages = with pkgs; [
        jabref
        typst
      ];
    };
}
