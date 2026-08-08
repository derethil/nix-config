{lib, ...}: {
  flake.modules.nixos.ntfy-subscribe = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) head length;

    ntfyBase = "https://ntfy.sh";
    ntfyTopicSecret = config.sops.secrets."serve/gatus/ntfy_topic".path;

    notifyScript = pkgs.writeShellScript "ntfy-notify" ''
      [ "${"\${NTFY_PRIORITY:-3}"}" -lt 3 ] && exit 0
      ${pkgs.libnotify}/bin/notify-send \
        --app-name "Ntfy" \
        --icon "${./icon.png}" \
        "$NTFY_TITLE" \
        "$NTFY_MESSAGE"
    '';

    supportedDaemons = [
      {
        inherit notifyScript;
        name = "notify-send";
      }
    ];

    activeDaemon = head supportedDaemons;
  in {
    config = {
      home-manager.sharedModules = [
        {
          systemd.user.services.ntfy-subscribe = {
            Install.WantedBy = ["graphical-session.target"];

            Service = {
              Environment = "PATH=/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";

              ExecStart = pkgs.writeShellScript "ntfy-subscribe" ''
                topic=$(cat ${ntfyTopicSecret})
                exec ${pkgs.ntfy-sh}/bin/ntfy subscribe ${ntfyBase}/"$topic" ${activeDaemon.notifyScript}
              '';

              PassEnvironment = "XDG_RUNTIME_DIR";
              Restart = "on-failure";
              RestartSec = "5s";
            };

            Unit = {
              After = ["graphical-session.target"];
              Description = "ntfy desktop notifications";
              PartOf = ["graphical-session.target"];
            };
          };
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
