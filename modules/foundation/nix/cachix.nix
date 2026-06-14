{self, ...}: {
  flake.modules.homeManager.cachix = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [self.modules.homeManager.secrets];

    sops.secrets."nix/cachix/local_auth_token" = {};

    home = {
      packages = [pkgs.cachix];
      sessionVariables = {
        CACHIX_AUTH_TOKEN = "$(${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."nix/cachix/local_auth_token".path})";
      };
    };
  };
}
