{...}: {
  flake.modules.nixos.sunshine = {pkgs, ...}: let
    compositorEnv = ''
      NIRI_PID=$(pgrep -u "$(id -u)" -x niri | head -1)

      if [ -n "$NIRI_PID" ]; then
        export $(tr "\0" "\n" < "/proc/$NIRI_PID/environ" | grep -E "^(WAYLAND_DISPLAY|XDG_RUNTIME_DIR)=")
      else
        echo "sunshine: unsupported compositor" >&2
        echo "Supported compositors: niri" >&2
        exit 1
      fi
    '';

    switchStreaming = pkgs.writeShellScript "sunshine-switch-streaming" ''
      ${compositorEnv}
      wlr-randr --output DP-2 --mode 1920x1080@60
    '';

    switchNormal = pkgs.writeShellScript "sunshine-switch-normal" ''
      ${compositorEnv}
      wlr-randr --output DP-2 --mode 3440x1440@160
    '';

    launchBigPicture = pkgs.writeShellScript "sunshine-launch-bigpicture" ''
      STEAM_PID=$(pgrep -u "$(id -u)" -x steam | head -1)

      if [ -n "$STEAM_PID" ]; then
        export $(tr "\0" "\n" < "/proc/$STEAM_PID/environ" | grep -E "^(DISPLAY|WAYLAND_DISPLAY|DBUS_SESSION_BUS_ADDRESS|XDG_RUNTIME_DIR|XAUTHORITY)=")
      else
        export DISPLAY=:1
        export XAUTHORITY=$HOME/.Xauthority
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
        setsid -f steam &
        sleep 10
      fi

      setsid -f steam steam://open/bigpicture
    '';
  in {
    environment.systemPackages = [pkgs.wlr-randr];

    services.sunshine = {
      enable = true;
      autoStart = true;
      openFirewall = true;
      capSysAdmin = false;
      settings = {
        encoder = "vaapi";
        keyboard = "disabled";
        controller = "disabled";
        mouse = "disabled";
        hevc_mode = "2";
        min_fps_factor = "2";
        system_tray = "disabled";
      };
      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin";
        };
        apps = [
          {
            name = "Steam Big Picture";
            detached = ["${launchBigPicture}"];
            prep-cmd = [
              {
                do = "${switchStreaming}";
                undo = "${switchNormal}";
              }
              {
                do = "";
                undo = "setsid steam steam://close/bigpicture";
              }
            ];
            image-path = "steam.png";
          }
        ];
      };
    };
  };
}
