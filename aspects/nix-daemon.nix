# aspects/nix-daemon.nix
# Aspect: Nix daemon, NH helper, store optimisation, GC & nix-ld
{ inputs, ... }:
{
  den.aspects.nix-daemon.nixos =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      programs = {
        command-not-found.enable = false;

        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc
            zlib
            zstd
            glib
            libGL
            openssl
          ];
        };

        nh = {
          enable = true;
          flake = "/home/elio/workspace/nixos";
          clean = {
            enable = true;
            dates = "weekly";
            extraArgs = "--keep-since 7d --keep 5";
          };
        };
      };

      nix = {
        package = pkgs.nixVersions.stable;
        channel.enable = false;
        registry.nixpkgs.flake = inputs.nixpkgs;

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          use-xdg-base-directories = true;
          trusted-users = [ "root" ];
        };

        optimise = {
          automatic = true;
          dates = "weekly";
        };
      };
    };
}
