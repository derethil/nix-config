{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption types mkDefault;
in {
  flake-file.inputs.quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  flake.modules.nixos.quadlet = {
    config,
    pkgs,
    ...
  }: {
    key = "quadlet";

    imports = [
      inputs.quadlet-nix.nixosModules.quadlet
      self.modules.nixos.podman
      self.modules.nixos.time
    ];

    options.virtualisation.quadlet.containers = let
      tzEnvFile = "/run/quadlet-tz.env";
      writeTz = pkgs.writeShellScript "quadlet-write-tz" ''
        echo "TZ=$(${config.systemd.package}/bin/timedatectl show -p Timezone --value)" > ${tzEnvFile}
      '';
    in
      mkOption {
        type = types.attrsOf (types.submodule {
          config = {
            containerConfig = {
              environmentFiles = [tzEnvFile];
              timezone = mkDefault "local";
            };

            serviceConfig.ExecStartPre = mkDefault "${writeTz}";
          };
        });
      };

    config.virtualisation.quadlet.enable = true;
  };
}
