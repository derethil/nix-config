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
    };

    environment.systemPackages = [
      pkgs.glace.ff
    ];
  };
}
