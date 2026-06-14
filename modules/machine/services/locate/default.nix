{self, ...}: let
  dbFolder = "/var/cache/locate";
  dbPath = "${dbFolder}/locatedb";
in {
  flake.modules.nixos.locate = {pkgs, ...}: {
    imports = [self.modules.nixos.shell-consumer];

    services.locate = {
      enable = true;
      package = pkgs.plocate;
      output = dbPath;

      # Default prunePaths minus /nix/store — we want the store indexed.
      prunePaths = [
        "/tmp"
        "/var/tmp"
        "/var/cache"
        "/var/lock"
        "/var/run"
        "/var/spool"
        "/nix/var/log/nix"
      ];
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "updatedb" ''
        exec ${pkgs.plocate}/bin/updatedb -o ${dbPath} "$@"
      '')
      (pkgs.writeShellScriptBin "ff" ''
        exec ${pkgs.internal.ff}/bin/ff -d ${dbPath} "$@"
      '')
    ];

    shell.aliases = {
      plocate = "/run/wrappers/bin/plocate -d ${dbPath}";
      locate = "/run/wrappers/bin/plocate -d ${dbPath}";
      udb = "sudo updatedb";
    };

    internal.boot.impermanence.extraDirectories = [dbFolder];
  };

  flake.modules.darwin.locate = {
    launchd.daemons.locate = {
      serviceConfig = {
        Label = "com.apple.locate";
        ProgramArguments = ["/usr/libexec/locate.updatedb"];
        StartCalendarInterval = [{Hour = 3;}];
        StartOnMount = true;
        Nice = 5;
      };
    };
  };
}
