{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.openssh;
  user = config.glace.user.name;
in {
  options.glace.services.openssh = {
    enable = mkBoolOpt false "Whether to enable OpenSSH client configuration.";
  };

  config = mkIf cfg.enable {
    secrets."users/${user}/ssh/private_key" = {};
    secrets."users/${user}/ssh/public_key" = {};

    sops.templates."ssh-private-key" = {
      name = "id_ed25519";
      content = config.sops.placeholder."users/${user}/ssh/private_key";
      path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      mode = "0600";
    };

    sops.templates."ssh-public-key" = {
      name = "id_ed25519.pub";
      content = config.sops.placeholder."users/${user}/ssh/public_key";
      path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      mode = "0644";
    };

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
