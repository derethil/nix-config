{
  self,
  lib,
  ...
}: {
  flake.modules.homeManager.openssh = {config, ...}: {
    imports = [
      self.modules.generic.user-options
      self.modules.homeManager.secrets
    ];

    sops.secrets."users/${config.internal.user.name}/ssh/private_key" = {};
    sops.secrets."users/${config.internal.user.name}/ssh/public_key" = {};

    sops.templates."ssh-private-key" = {
      name = "id_ed25519";
      content = config.sops.placeholder."users/${config.internal.user.name}/ssh/private_key";
      path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      mode = "0600";
    };

    sops.templates."ssh-public-key" = {
      name = "id_ed25519.pub";
      content = config.sops.placeholder."users/${config.internal.user.name}/ssh/public_key";
      path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      mode = "0644";
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        AddKeysToAgent = "yes";
        ForwardAgent = false;
        ServerAliveInterval = 60;
        ServerAliveCountMax = 3;
        ProxyCommand = "none";
      };
    };

    services.ssh-agent.enable = true;
  };

  flake.modules.nixos.openssh = {...}: {
    services.openssh = {
      enable = true;
      authorizedKeysFiles = [
        "%h/.ssh/id_ed25519.pub"
        "%h/.ssh/authorized_keys"
      ];
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };

    internal.boot.impermanence.extraDirectories = ["/etc/ssh"];
  };

  flake.modules.darwin.openssh = {...}: {
    services.openssh = {
      enable = true;
      extraConfig = ''
        PasswordAuthentication no
        PermitRootLogin no
        KbdInteractiveAuthentication no
        AuthorizedKeysFile %h/.ssh/id_ed25519.pub
      '';
    };

    system.activationScripts.ssh.text = lib.mkAfter ''
      echo "enabling remote login..." >&2
      systemsetup -setremotelogin on
    '';
  };
}
