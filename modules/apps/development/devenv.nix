{
  flake.modules = {
    nixos.devenv = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.devenv];
    };

    darwin.devenv = {pkgs, ...}: {
      environment.systemPackages = [pkgs.unstable.devenv];
    };

    homeManager.devenv = {pkgs, ...}: {
      home.packages = [pkgs.unstable.devenv];
    };
  };
}
