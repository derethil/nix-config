{lib, ...}: let
  inherit (lib) types;
  inherit (lib.glace) mkOpt;
in {
  options.distro = mkOpt (types.enum ["arch" "nixos" "darwin"]) "nixos" "Option to enable distro-specific configurations.";
}
