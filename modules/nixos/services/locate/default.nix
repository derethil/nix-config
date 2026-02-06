{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.locate;
  dbFolder = "/var/cache/locate";
  dbPath = "${dbFolder}/locatedb";
in {
  options.glace.services.locate = {
    enable = mkBoolOpt false "Whether to enable the plocate database service.";
  };

  config = mkIf cfg.enable {
    services.locate = {
      enable = true;
      package = pkgs.plocate;
      output = dbPath;

      # I don't want to prune /nix/store, so just copy the default path list aside from that
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
        exec ${pkgs.glace.ff}/bin/ff -d ${dbPath} "$@"
      '')
    ];

    environment.shellAliases = {
      plocate = "/run/wrappers/bin/plocate -d ${dbPath}";
      locate = "/run/wrappers/bin/plocate -d ${dbPath}";
    };

    glace.system.impermanence.extraDirectories = [dbFolder];
  };
}
