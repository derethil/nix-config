{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.nixos.impermanence-options = {
    key = "impermanence-options";

    options.internal = {
      boot.impermanence = {
        blankSnapshot = mkOption {
          description = "Name of the blank BTRFS subvolume to restore root from on each boot (e.g. 'root-blank' as defined in disko).";
          type = types.str;
        };

        device = mkOption {
          default = "";
          description = "Block device containing the BTRFS filesystem. Derived from luksDevice automatically when set; must be specified explicitly for non-LUKS systems (e.g. /dev/disk/by-partlabel/root).";
          type = types.str;
        };

        enabled = mkOption {
          default = false;
          type = types.bool;
        };

        extraDirectories = mkOption {
          default = [];
          type = types.listOf types.str;
        };

        extraFiles = mkOption {
          default = [];
          type = types.listOf types.str;
        };

        luksDevice = mkOption {
          default = null;
          description = "LUKS device name as configured in disko (e.g. 'enc' for /dev/mapper/enc). Set to null for non-LUKS systems.";
          type = types.nullOr types.str;
        };
      };

      persistRoot = mkOption {
        default = "";
        type = types.str;
      };
    };
  };
}
