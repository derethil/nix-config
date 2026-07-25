{self, ...}: let
  dbFolder = "/var/cache/locate";
  dbPath = "${dbFolder}/locatedb";
in {
  flake.modules = {
    nixos.locate = {pkgs, ...}: {
      imports = [self.modules.nixos.shell-consumer];

      environment.systemPackages = [
        (pkgs.writeShellScriptBin "ff" ''
          exec ${pkgs.internal.ff}/bin/ff -d ${dbPath} "$@"
        '')
        (pkgs.writeShellScriptBin "updatedb" ''
          exec ${pkgs.plocate}/bin/updatedb -o ${dbPath} "$@"
        '')
      ];

      internal.boot.impermanence.extraDirectories = [dbFolder];

      services.locate = {
        enable = true;
        package = pkgs.plocate;
        output = dbPath;

        # Default prunePaths minus /nix/store — we want the store indexed.
        prunePaths = [
          "/nix/var/log/nix"
          "/tmp"
          "/var/cache"
          "/var/lock"
          "/var/run"
          "/var/spool"
          "/var/tmp"
        ];
      };

      shell.aliases = {
        locate = "/run/wrappers/bin/plocate -d ${dbPath}";
        plocate = "/run/wrappers/bin/plocate -d ${dbPath}";
        udb = "sudo updatedb";
      };
    };

    darwin.locate.launchd.daemons.locate.serviceConfig = {
      Label = "com.apple.locate";
      Nice = 5;
      ProgramArguments = ["/usr/libexec/locate.updatedb"];
      StartCalendarInterval = [{Hour = 3;}];
      StartOnMount = true;
    };
  };
}
