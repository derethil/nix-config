{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.szuru;
in {
  options.glace.services.szuru = {
    enable = mkBoolOpt false "Enable Szurubooru";
  };

  config = mkIf cfg.enable {
    services.szurubooru = {
      enable = true;
      dataDir = "/var/lib/szurubooru";
      server.settings = {
        domain = "szuru.local";
        delete_source_files = "true";
        port = 9000;
      };
    };

    environment.systemPackages = with pkgs; [
      szurubooru.client
    ];

    glace.system.impermanence.extraDirectories = [
      "/var/lib/szurubooru"
    ];
  };
}
