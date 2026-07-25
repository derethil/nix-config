{
  self,
  inputs,
  ...
}: let
  defaultSopsFile = "${self}/secrets/secrets.yaml";
  validateSopsFiles = true;
in {
  flake-file.inputs.sops-nix = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:Mic92/sops-nix";
  };

  flake.modules = {
    nixos.secrets = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        inputs.sops-nix.nixosModules.sops
        self.modules.nixos.impermanence-options
      ];

      config = {
        environment.systemPackages = with pkgs; [
          age
          sops
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
        age
        sops
        ssh-to-age
      ];

      sops = {
        inherit defaultSopsFile validateSopsFiles;

        age = {
          generateKey = false;
          keyFile = "/var/lib/sops/age/keys.txt";
          sshKeyPaths = [];
        };

        gnupg.sshKeyPaths = [];
      };
    };

    homeManager.secrets = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.sops-nix.homeManagerModules.sops];

      home.packages = with pkgs; [
        age
        sops
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
