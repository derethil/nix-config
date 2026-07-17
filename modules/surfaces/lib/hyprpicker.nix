{
  flake.modules.homeManager.hyprpicker = {pkgs, ...}: {
    home.packages = [pkgs.hyprpicker];
  };
}
