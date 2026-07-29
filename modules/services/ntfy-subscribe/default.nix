{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.ntfy-subscribe = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) head length listToAttrs mkOption types;

    cfg = config.internal.services.ntfy-subscribe;

    ntfyBase = self.lib.homelab.mkServiceDomain config "ntfy";

    notifySendScript = topic:
      pkgs.writeShellScript "ntfy-notify-${topic}" ''
        [ "${"\${NTFY_PRIORITY:-3}"}" -lt 3 ] && exit 0
        ${pkgs.libnotify}/bin/notify-send \
          --app-name "Ntfy" \
          --icon "${./icon.png}" \
          "$NTFY_TITLE" \
          "$NTFY_MESSAGE"
      '';

    supportedDaemons = [
      {
        makeNotifyScript = notifySendScript;
        name = "notify-send";
      }
    ];

    activeDaemon = head supportedDaemons;
  in {
    options.internal.services.ntfy-subscribe.topics = mkOption {
      default = [];
      type = types.listOf types.str;
    };

    config = {
      home-manager.sharedModules = [
        {
          systemd.user.services = listToAttrs (map (topic: {
              name = "ntfy-subscribe-${topic}";

              value = {
                Install.WantedBy = ["graphical-session.target"];

                Service = {
                  Environment = "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";
                  ExecStart = "${pkgs.ntfy-sh}/bin/ntfy subscribe ${ntfyBase}/${topic} ${activeDaemon.makeNotifyScript topic}";
                  PassEnvironment = "XDG_RUNTIME_DIR";
                  Restart = "on-failure";
                  RestartSec = "5s";
                };

                Unit = {
                  After = ["graphical-session.target"];
                  Description = "ntfy desktop notifications: ${topic}";
                  PartOf = ["graphical-session.target"];
                };
              };
            })
            cfg.topics);
        }
      ];

      assertions = [
        {
          assertion = length supportedDaemons == 1;
          message = "ntfy-subscribe: exactly one notification daemon must be configured (supported: ${toString (map (d: d.name) supportedDaemons)})";
        }
      ];
    };
  };
}
