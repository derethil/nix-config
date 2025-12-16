{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.system.ssh;
in {
  options.glace.system.ssh = {
    enable = mkBoolOpt false "Whether or not to enable SSH.";
    remote-login.enable = mkBoolOpt false "Whether to enable Remote Login";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
    };

    system.activationScripts.ssh.text = mkAfter ''
      echo "enabling remote login..." >&2
      systemsetup -setremotelogin on
    '';
  };
}
