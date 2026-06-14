{...}: {
  flake.modules.homeManager.melonloader = {pkgs, ...}: {
    home.packages = [pkgs.melonloader-installer];
  };
}
