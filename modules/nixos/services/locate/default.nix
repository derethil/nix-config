{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.locate;
in {
  options.glace.services.locate = {
    enable = mkBoolOpt false "Whether to enable the plocate database service.";
  };

  config = mkIf cfg.enable {
    services.locate = {
      enable = true;
      package = lib.mkDefault pkgs.plocate;
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
      pkgs.glace.ff
    ];

    glace.system.impermanence.extraFiles = [
      "/var/cache/locatedb"
    ];
  };
}
