{self, ...}: {
  flake.modules.nixos.foundation = {...}: {
    imports = with self.modules.nixos; [
      flake-root
      nix-settings
      nix-inputs
      nh
      shell
      time
      sudo
      openssh
      neovim
      locate
    ];
  };

  flake.modules.darwin.foundation = {...}: {
    imports = with self.modules.darwin; [
      flake-root
      nix-settings
      nix-inputs
      nh
      shell
      openssh
      neovim
      locate
    ];
  };

  flake.modules.homeManager.foundation = {...}: {
    imports = with self.modules.homeManager; [
      flake-root
      nix-settings
      nix-inputs
      cachix
      shell
      openssh
      git
      neovim
    ];
  };
}
