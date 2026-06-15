{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://github.com/quickshell-mirror/quickshell?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.dankmaterialshell-panel = {pkgs, ...}: {
    imports = [
      inputs.dank-material-shell.homeModules.dank-material-shell
      inputs.dms-plugin-registry.homeModules.default
      self.modules.homeManager.calendars
    ];

    programs.dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      dgop.package = pkgs.unstable.dgop;
      quickshell.package = pkgs.inputs.quickshell.default;

      enableVPN = false;
      enableSystemMonitoring = true;
      enableDynamicTheming = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
    };
  };
}
