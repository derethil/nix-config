{...}: {
  flake.modules.nixos.devenv = {pkgs, ...}: {
    environment.systemPackages = [pkgs.unstable.devenv];
  };

  flake.modules.darwin.devenv = {pkgs, ...}: {
    environment.systemPackages = [pkgs.unstable.devenv];
  };

  flake.modules.homeManager.devenv = {pkgs, ...}: {
    home.packages = [pkgs.unstable.devenv];
  };
}
