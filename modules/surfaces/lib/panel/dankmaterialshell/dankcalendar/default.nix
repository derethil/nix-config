{inputs, ...}: {
  flake-file.inputs.dcal = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:AvengeMedia/dcal";
  };

  flake.modules.homeManager.dankcalendar = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.dcal.homeModules.default];

    programs.dank-calendar = {
      enable = true;

      # Fixes iCloud CalDAV multiget (github.com/emersion/go-webdav/issues/196):
      # dcal still passes AllProps/AllComps to MultiGetCalendar, which iCloud rejects.
      # go-webdav itself already carries the upstream fix (an empty CompRequest emits
      # bare <calendar-data/>), but that's opt-in per caller — dcal's provider.go never
      # asks for it, so vendoring the latest go-webdav alone doesn't fix this. Remove
      # once dcal's provider.go stops setting AllProps/AllComps in multiGetAll.
      package = pkgs.inputs.dcal.dankcalendar.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./fix-icloud-multiget.patch];
      });

      quickshell.package = config.programs.dank-material-shell.quickshell.package;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
