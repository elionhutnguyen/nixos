# aspects/defaults.nix
# Horizontal Baseline: Repository-wide stateVersion, HM integration, and Den batteries
{ den, ... }:
{
  den.default = {
    nixos = {
      system.stateVersion = "26.05";
      home-manager = {
        backupFileExtension = "backup";
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
    homeManager.home.stateVersion = "26.05";
    includes = [
      den.batteries.define-user
      den.batteries.hostname
      den.batteries.primary-user
      den.batteries.host-aspects
    ];
  };

  den.schema.user.includes = [ den.batteries.user-aspects ];
}
