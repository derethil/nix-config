{lib, ...}: {
  flake.modules.homeManager.lossless-scaling = {pkgs, ...}: {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
      lsfg-vk
      lsfg-vk-ui
    ]);
  };
}
