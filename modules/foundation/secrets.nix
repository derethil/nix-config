{
  inputs,
  self,
  ...
}: let
  defaultSopsFile = "${self}/secrets/secrets.yaml";
  validateSopsFiles = true;
in {
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules = {
    nixos.secrets = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        inputs.sops-nix.nixosModules.sops
        self.modules.nixos.impermanence-options
      ];

      config = {
        environment.systemPackages = with pkgs; [
          sops
          age
          ssh-to-age
        ];

        sops = {
          inherit defaultSopsFile validateSopsFiles;
          age = {
            generateKey = false;
            keyFile = "${config.internal.persistRoot}/etc/sops/age/keys.txt";
            sshKeyPaths = ["${config.internal.persistRoot}/etc/ssh/ssh_host_ed25519_key"];
          };
        };
      };
    };

    darwin.secrets = {pkgs, ...}: {
      imports = [inputs.sops-nix.darwinModules.sops];

      environment.systemPackages = with pkgs; [
        sops
        age
        ssh-to-age
      ];

      sops = {
        inherit defaultSopsFile validateSopsFiles;
        age = {
          generateKey = false;
          keyFile = "/var/lib/sops/age/keys.txt";
          sshKeyPaths = [];
        };
        gnupg = {
          sshKeyPaths = [];
        };
      };
    };

    homeManager.secrets = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops];

      home.packages = with pkgs; [
        sops
        age
        ssh-to-age
      ];

      sops = {
        inherit defaultSopsFile validateSopsFiles;
        age = {
          generateKey = false;
          keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        };
      };
    };
  };
}
