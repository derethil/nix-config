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

      # Patches go-webdav to fix iCloud CalDAV multiget (github.com/emersion/go-webdav/issues/196,
      # fixed in go-webdav main but unreleased as of dcal v0.3.0). The patch bumps go-webdav to
      # v0.7.1-0.20251218134206-8888fdf9b017 (pre-v0.8.0) and uses an empty CalendarCompRequest
      # to emit bare <calendar-data/> instead of allprop/allcomp, which iCloud requires.
      # vendorHash reflects the updated go-webdav dependency — remove both once dcal bumps go-webdav.
      package = pkgs.inputs.dcal.dankcalendar.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./fix-icloud-multiget.patch];
        vendorHash = "sha256-NO5WH0a6Xfpgwfn6Fr/1EA1yyKMGUNkBWsXd06VEh1c=";
      });

      quickshell.package = config.programs.dank-material-shell.quickshell.package;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };
    };
  };
}
