{lib, ...}:
with lib;
with internal;
with types; let
  distros = enum ["arch" "nixos"];
in {
  options.distro = mkOpt distros "nixos" "Option to enable distro-specific configurations.";
}
