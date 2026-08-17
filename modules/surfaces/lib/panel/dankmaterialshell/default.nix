{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    dank-material-shell = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/DankMaterialShell";
    };

    dms-plugin-registry = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:AvengeMedia/dms-plugin-registry";
    };

    quickshell = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "git+https://github.com/quickshell-mirror/quickshell?ref=master";
    };
  };

  flake.modules.homeManager.dankmaterialshell-panel = {pkgs, ...}: {
    imports = [
      inputs.dank-material-shell.homeModules.dank-material-shell
      inputs.dms-plugin-registry.homeModules.default
      self.modules.homeManager.dankcalendar
    ];

    programs.dank-material-shell = {
      enable = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = false;
      enableSystemMonitoring = true;
      enableVPN = false;
      quickshell.package = pkgs.inputs.quickshell.default;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
