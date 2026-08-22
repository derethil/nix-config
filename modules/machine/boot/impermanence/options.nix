{lib, ...}: let
  inherit (lib) mkOption types;

  directoryEntry = types.submodule {
    options = {
      directory = mkOption {
        description = "Path to the directory to bind mount to persistent storage.";
        type = types.str;
      };

      group = mkOption {
        default = "root";
        description = "Group to own the directory if it doesn't already exist in persistent storage.";
        type = types.str;
      };

      mode = mkOption {
        default = "0755";
        description = "Permissions to create the directory with if it doesn't already exist in persistent storage.";
        type = types.str;
      };

      user = mkOption {
        default = "root";
        description = "User to own the directory if it doesn't already exist in persistent storage.";
        type = types.str;
      };
    };
  };
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
          type = types.listOf (types.either types.str directoryEntry);
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
