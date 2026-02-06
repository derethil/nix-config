{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  cfg = config.glace.services.openssh;
in {
  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
        KbdInteractiveAuthentication no
        AuthorizedKeysFile ${lib.concatStringsSep " " config.glace.services.openssh.authorizedKeyFiles}
      '';
    };

    system.activationScripts.ssh.text = mkAfter ''
      echo "enabling remote login..." >&2
      systemsetup -setremotelogin on
    '';
  };
}
