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
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
      authorizedKeysFiles = cfg.authorizedKeyFiles;
    };
    networking.firewall.allowedTCPPorts = [22];
  };
}
