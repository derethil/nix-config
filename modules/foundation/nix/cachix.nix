{self, ...}: {
  flake.modules.homeManager.cachix = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.secrets];

    home = {
      packages = [pkgs.cachix];
      sessionVariables.CACHIX_AUTH_TOKEN = "$(${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."nix/cachix/local_auth_token".path})";
    };

    sops.secrets."nix/cachix/local_auth_token" = {};
  };
}
