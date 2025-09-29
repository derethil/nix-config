{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.sober;
in {
  options.glace.apps.sober = {
    enable = mkBoolOpt false "Whether to enable Sober, the Roblox-Linux compatibility layer.";
  };

  config = mkIf cfg.enable {
    glace.services.flatpak = {
      enable = true;
      packages = [
        {
          appId = "org.vinegarhq.Sober";
          origin = "flathub";
        }
      ];
    };
  };
}
