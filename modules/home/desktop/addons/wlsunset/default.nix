{
  lib,
  config,
  ...
}:
with lib;
with internal; {
  options.desktop.addons.wlsunset = {
    enable = mkBoolOpt false "Whether to enable wlsunset.";
  };

  config = mkIf config.desktop.addons.wlsunset.enable {
    services.wlsunset = {
      enable = true;
      systemdTarget = "graphical-session.target";
      latitude = config.user.location.latitude;
      longitude = config.user.location.longitude;
      temperature = {
        day = 6500;
        night = 3000;
      };
    };
  };
}
