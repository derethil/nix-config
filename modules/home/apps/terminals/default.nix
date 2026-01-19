{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.glace) mkNullableOpt mkOpt;
  cfg = config.glace.apps.terminals;

  options = ["alacritty" "foot" "kitty"];
in {
  options.glace.apps.terminals = with types; {
    default = mkNullableOpt (enum options) null "The default terminal emulator to use.";

    desktopFiles = mkOpt (attrsOf str) {} "Attrset mapping terminal names to their desktop file names. Automatically populated by terminal modules.";

    commands = {
      base = mkOpt (listOf str) [] "Base terminal command";
      withTmux = mkOpt (listOf str) [] "Terminal command with tmux session";
    };
  };

  config = {
    glace.desktop.xdg-terminal-exec.enable = mkIf (cfg.desktopFiles != {}) true;

    assertions = [
      {
        assertion = cfg.default == null || cfg.${cfg.default}.enable or false;
        message = "The default terminal '${cfg.default}' is set but not enabled. Please enable glace.apps.terminals.${cfg.default}.enable";
      }
    ];
  };
}
