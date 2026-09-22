{self, ...}: {
  flake.modules.nixos.hydroxide = {
    config,
    lib,
    pkgs,
    ...
  }: let
    imapPort = "1143";
    smtpPort = "1025";

    stateDir = "/var/lib/hydroxide";
    authFile = "${stateDir}/hydroxide/auth.json";

    inherit (lib) toInt;
  in {
    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.impermanence-options
      self.modules.nixos.secrets
    ];

    internal = {
      boot.impermanence.extraDirectories = [
        {
          directory = stateDir;
          group = "hydroxide";
          mode = "0700";
          user = "hydroxide";
        }
      ];

      homelab.gatus.endpoints.hydroxide = {
        conditions = ["[CONNECTED] == true"];
        group = "infrastructure";
        url = "tcp://host.containers.internal:${imapPort}";
      };
    };

    networking.firewall.interfaces."podman0".allowedTCPPorts = [
      (toInt imapPort)
      (toInt smtpPort)
    ];

    sops.secrets."services/hydroxide/auth_json" = {
      group = "hydroxide";
      owner = "hydroxide";
    };

    systemd.services.hydroxide = {
      after = ["network-online.target"];
      description = "Hydroxide ProtonMail Bridge";
      environment.XDG_CONFIG_HOME = stateDir;

      preStart = ''
        if [ ! -e ${authFile} ]; then
          install -D -m 0600 ${config.sops.secrets."services/hydroxide/auth_json".path} ${authFile}
        fi
      '';

      serviceConfig = {
        ExecStart = "${pkgs.hydroxide}/bin/hydroxide -imap-host 0.0.0.0 -imap-port ${imapPort} -smtp-host 0.0.0.0 -smtp-port ${smtpPort} -disable-carddav serve";
        Group = "hydroxide";
        Restart = "always";
        User = "hydroxide";
      };

      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
    };

    users = {
      groups.hydroxide = {};

      users.hydroxide = {
        group = "hydroxide";
        home = stateDir;
        isSystemUser = true;
      };
    };
  };
}
