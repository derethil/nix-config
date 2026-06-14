{...}: {
  flake.modules.homeManager.wlsunset = {
    lib,
    pkgs,
    ...
  }: let
    systemdTarget = "graphical-session.target";

    wlsunset-auto = pkgs.writeShellApplication {
      name = "wlsunset-auto";
      runtimeInputs = with pkgs; [wlsunset curl jq];
      text = ''
        location=$(curl -s http://ip-api.com/json?fields=lat,lon)
        lat=$(echo "$location" | jq -r '.lat')
        lon=$(echo "$location" | jq -r '.lon')

        exec wlsunset -l "$lat" -L "$lon" "$@"
      '';
    };

    args = lib.cli.toCommandLineShellGNU {} {
      t = 3000; # Nighttime color temperature in Kelvin
      T = 6500; # Daytime color temperature in Kelvin
      g = 1.0; # Gamma adjustment (1.0 = no adjustment)
    };
  in {
    systemd.user.services.wlsunset = {
      Unit = {
        Description = "Day/night gamma adjustments for Wayland compositors";
        After = [systemdTarget];
        PartOf = [systemdTarget];
      };

      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 1;
        ExecStart = "${lib.getExe wlsunset-auto} ${args}";
      };

      Install.WantedBy = [systemdTarget];
    };
  };
}
