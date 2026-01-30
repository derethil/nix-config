{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.openssh-server;
in {
  options.glace.services.openssh-server = {
    enable = mkBoolOpt false "Whether to enable OpenSSH server.";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };

    networking.firewall.allowedTCPPorts = [22];
  };
}
