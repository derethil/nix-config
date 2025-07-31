{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) internal mkIf;
  inherit (internal) mkBoolOpt;
  cfg = config.tools.claude-code;
in {
  options.tools.claude-code = {
    enable = mkBoolOpt false "Whether to enable Claude Code.";
  };

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) claude-code;
    };
  };
}
