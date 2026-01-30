{ lib, config, ... }:
let
  inherit (lib) types;
  inherit (lib.glace) mkOpt;
in
{
  options.glace.flakeRoot = mkOpt types.str "${config.glace.user.home or config.home.homeDirectory}/.config/nix-config" "Absolute path to the flake root directory";
}
