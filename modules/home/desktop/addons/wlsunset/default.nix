{
  lib,
  config,
  ...
}:
with lib;
with glace; {
  options.glace.desktop.addons.wlsunset = {
    enable = mkBoolOpt false "Whether to enable wlsunset.";
  };

  config = mkIf config.glace.desktop.addons.wlsunset.enable {
    services.wlsunset = {
      enable = true;
      systemdTarget = "graphical-session.target";
      latitude = config.glace.user.location.latitude;
      longitude = config.glace.user.location.longitude;
      temperature = {
        day = 6500;
        night = 3000;
      };
    };
  };
}
