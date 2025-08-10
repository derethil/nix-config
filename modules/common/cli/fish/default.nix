{lib, ...}: let
  inherit (lib.internal) mkBoolOpt;
in {
  options.cli.fish.enable = mkBoolOpt false "Whether to enable the Fish shell.";
}
