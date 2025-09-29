{lib, ...}:
with lib;
with glace;
with types; let
  distros = enum ["arch" "nixos" "darwin"];
in {
  options.distro = mkOpt distros "nixos" "Option to enable distro-specific configurations.";
}
