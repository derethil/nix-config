{
  lib,
  config,
  ...
}:
with lib;
with lib.internal; let
  cfg = config.apps.sober;
in {
  options.apps.sober = {
    enable = mkBoolOpt false "Whether to enable Sober, the Roblox-Linux compatibility layer.";
  };

  config = mkIf cfg.enable {
    services.flatpak = {
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

