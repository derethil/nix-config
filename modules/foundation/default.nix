{self, ...}: {
  flake.modules = {
    nixos.foundation.imports = with self.modules.nixos; [
      flake-root
      locate
      neovim
      nh
      nix-inputs
      nix-settings
      openssh
      shell
      sudo
      time
    ];

    darwin.foundation.imports = with self.modules.darwin; [
      flake-root
      locate
      neovim
      nh
      nix-inputs
      nix-settings
      openssh
      shell
    ];

    homeManager.foundation.imports = with self.modules.homeManager; [
      cachix
      flake-root
      git
      neovim
      nix-inputs
      nix-settings
      openssh
      shell
      trash
    ];
  };
}
