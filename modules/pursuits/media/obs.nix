{
  flake.modules.homeManager.obs = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
      pkgs.obs-studio
    ];
  };
}
