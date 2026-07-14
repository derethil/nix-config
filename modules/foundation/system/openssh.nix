{
  self,
  lib,
  ...
}: let
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJZla+P67akIdbI1fb1MQDqb8L42yEsDSCFk8GHiz3il";
in {
  flake.modules.homeManager.openssh = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.modules.generic.user-options
      self.modules.homeManager.secrets
    ];

    sops.secrets."users/${config.internal.user.name}/ssh/private_key" = {};

    sops.templates."ssh-private-key" = {
      name = "id_ed25519";
      content = config.sops.placeholder."users/${config.internal.user.name}/ssh/private_key";
      path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      mode = "0600";
    };

    home.activation.sshPublicKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p "$HOME/.ssh"
      run install -m 644 ${pkgs.writeText "id_ed25519.pub" (publicKey + "\n")} "$HOME/.ssh/id_ed25519.pub"
    '';

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

  flake.modules.nixos.openssh = {config, ...}: {
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

    # Declarative authorized key so a freshly-installed host is reachable before
    # home-manager writes ~/.ssh from sops.
    users.users = self.lib.forEachNormalUser config (_: {
      openssh.authorizedKeys.keys = [publicKey];
    });

    internal.boot.impermanence.extraFiles = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
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
