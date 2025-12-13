{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.displayManagers.dankGreeter;
in {
  options.glace.desktop.displayManagers.dankGreeter = {
    enable = mkBoolOpt false "Whether to enable Dank Greeter.";
  };

  config = mkIf cfg.enable {
    programs.dankMaterialShell.greeter = {
      enable = true;
      configHome = config.glace.user.home;
      quickshell.package = pkgs.inputs.quickshell.default;
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
      compositor.name =
        if config.glace.desktop.niri.enable
        then "niri"
        else if config.glace.desktop.hyprland.enable
        then "hyprland"
        else throw "No supported compositor enabled for Dank Material Shell greeter.";
    };
  };
}
