{self, ...}: {
  flake.modules = {
    nixos.foundation = {
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

    darwin.foundation = {
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

    homeManager.foundation = {
      imports = with self.modules.homeManager; [
        flake-root
        nix-settings
        nix-inputs
        cachix
        trash
        shell
        openssh
        git
        neovim
      ];
    };
  };
}
