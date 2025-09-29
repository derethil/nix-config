{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.claude-code;
in {
  options.glace.tools.claude-code = {
    enable = mkBoolOpt false "Whether to enable Claude Code.";
  };

  config = mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit (pkgs) claude-code;
    };
  };
}
