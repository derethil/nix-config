{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.sober;
in {
  options.tools.sober = {
    enable = mkBoolOpt false "Whether to enable Sober, the Roblox-Linux compatibility layer.";
  };

  config = mkIf cfg.enable {
    services.flatpak.packages = [
      {
        appId = "org.vinegarhq.Sober";
        origin = "flathub";
      }
    ];
  };
}
