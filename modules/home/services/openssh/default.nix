{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.openssh;
in {
  options.glace.services.openssh = {
    enable = mkBoolOpt false "Whether to enable OpenSSH client configuration.";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        addKeysToAgent = "yes";
        forwardAgent = false;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };

    services.ssh-agent.enable = true;
  };
}
