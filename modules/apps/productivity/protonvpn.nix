{self, ...}: {
  flake.modules = {
    darwin.protonvpn = {
      imports = [self.modules.darwin.homebrew];
      config.homebrew.casks = ["protonvpn"];
    };

    homeManager.protonvpn = {
      lib,
      pkgs,
      ...
    }: {
      home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
        pkgs.proton-vpn-cli
        pkgs.proton-vpn
      ];
    };
  };
}
