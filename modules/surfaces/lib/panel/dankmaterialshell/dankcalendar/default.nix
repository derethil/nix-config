{inputs, ...}: {
  flake-file.inputs.dcal = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:AvengeMedia/dcal";
  };

  flake.modules.homeManager.dankcalendar = {config, ...}: {
    imports = [inputs.dcal.homeModules.default];

    programs.dank-calendar = {
      enable = true;
      quickshell.package = config.programs.dank-material-shell.quickshell.package;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
