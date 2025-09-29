{lib, ...}: let
  inherit (lib.glace) mkBoolOpt;
in {
  options.glace.cli.fish.enable = mkBoolOpt false "Whether to enable the Fish shell.";
}
