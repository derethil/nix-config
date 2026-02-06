{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.services.openssh;
in {
  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      authorizedKeysFiles = cfg.authorizedKeyFiles;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };
    networking.firewall.allowedTCPPorts = [22];
    glace.system.impermanence.extraDirectories = ["/etc/ssh"];
  };
}
