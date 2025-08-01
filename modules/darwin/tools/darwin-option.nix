{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.tools.darwin-option;
in {
  options.tools.darwin-option = {
    enable = mkBoolOpt false "Whehter to enable the darwin-option tool.";
  };

  config = mkIf cfg.enable {
    system.tools.darwin-option.enable = true;
  };
}
