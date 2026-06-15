{
  flake.modules.homeManager.obs = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
      pkgs.obs-studio
    ];
  };
}
