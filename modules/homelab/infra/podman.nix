{
  self,
  lib,
  ...
}: let
  inherit (lib) getExe';

  user = "homelab";
  uid = 2000;
  gid = 2000;
  home = "/var/lib/${user}";
  storageRoot = "${home}/.local/share/containers/storage";

  subordinateId = 500000;
  subordinateCount = 65536;
in {
  flake = {
    modules.nixos.podman = {pkgs, ...}: {
      key = "podman";
      imports = [self.modules.nixos.impermanence-options];
      environment.systemPackages = [pkgs.podman];

      internal.boot.impermanence.extraDirectories = [
        {
          inherit user;
          directory = home;
          group = user;
          mode = "0700";
        }
      ];

      users = {
        groups.${user}.gid = gid;

        users.${user} = {
          inherit home uid;
          description = "Rootless Podman container host";
          group = user;
          isNormalUser = true;
          linger = true;

          subGidRanges = [
            {
              count = subordinateCount;
              startGid = subordinateId;
            }
          ];

          subUidRanges = [
            {
              count = subordinateCount;
              startUid = subordinateId;
            }
          ];
        };
      };

      virtualisation = {
        containers.enable = true;

        podman = {
          enable = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };
    };

    lib.podman = {
      inherit gid home storageRoot uid user;

      asUser = pkgs: command: let
        env = getExe' pkgs.coreutils "env";
        runuser = getExe' pkgs.util-linux "runuser";
      in "/run/wrappers/bin/sudo ${runuser} -u ${user} -- ${env} -C / HOME=${home} XDG_RUNTIME_DIR=/run/user/${toString uid} ${command}";

      svc = container: "${container}.service";
      volume = name: "${storageRoot}/volumes/${name}/_data";
    };
  };
}
