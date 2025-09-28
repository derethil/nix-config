{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.services.openssh;
in {
  options.services.openssh = {
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