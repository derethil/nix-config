{
  flake.modules.homeManager.mangohud-options = {lib, ...}: let
    inherit (lib) mkOption types;
  in {
    options.internal.gaming.mangohud = {
      coolantSensor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to hwmon temp input for coolant display, e.g. /sys/class/hwmon/hwmon6/temp2_input";
      };

      pciDevice = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "PCI device ID for GPU, e.g. 0000:03:00.0. If null, MangoHud will attempt to auto-detect the GPU.";
      };
    };
  };
}
