{ config, lib, ... }: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.glace.system.swap;
in {
  options.glace.system.swap = {
    zram.enable = mkEnableOption "zram swap";
  };

  config = mkIf cfg.zram.enable {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };
  };
}
