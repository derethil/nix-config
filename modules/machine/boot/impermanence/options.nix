{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.nixos.impermanence-options = {
    key = "impermanence-options";
    options = {
      internal.persistRoot = mkOption {
        type = types.str;
        default = "";
      };

      internal.boot.impermanence = {
        enabled = mkOption {
          type = types.bool;
          default = false;
        };
        luksDevice = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "LUKS device name as configured in disko (e.g. 'enc' for /dev/mapper/enc). Set to null for non-LUKS systems.";
        };
        device = mkOption {
          type = types.str;
          default = "";
          description = "Block device containing the BTRFS filesystem. Derived from luksDevice automatically when set; must be specified explicitly for non-LUKS systems (e.g. /dev/disk/by-partlabel/root).";
        };
        blankSnapshot = mkOption {
          type = types.str;
          description = "Name of the blank BTRFS subvolume to restore root from on each boot (e.g. 'root-blank' as defined in disko).";
        };
        extraDirectories = mkOption {
          type = types.listOf types.str;
          default = [];
        };
        extraFiles = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };
    };
  };
}
