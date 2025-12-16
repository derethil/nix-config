{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.system.ssh;
in {
  options.glace.system.ssh = {
    enable = mkBoolOpt false "Whether or not to enable SSH.";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
    };
  };
}
