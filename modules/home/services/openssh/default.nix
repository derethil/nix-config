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
      # TODO: only added in 25.11
      # enableDefaultConfig = false;
      matchBlocks."*" = {
        # TODO: only added in 25.11
        # addKeysToAgent = "yes";
        forwardAgent = false;
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };

    services.ssh-agent.enable = true;
  };
}

