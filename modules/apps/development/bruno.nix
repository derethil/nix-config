{
  flake.modules.homeManager.bruno = {pkgs, ...}: {
    home.packages = [
      pkgs.bruno
      pkgs.bruno-cli
    ];
  };
}
