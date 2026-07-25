{inputs, ...}: {
  flake-file.inputs.cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  flake.modules.nixos.kernel = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkOption types;
  in {
    options.internal.boot.kernel = {
      cachyos.enable = mkEnableOption "CachyOS kernel";

      packages = mkOption {
        default = pkgs.linuxPackages_latest;
        type = types.raw;
      };

      params = mkOption {
        default = [];
        type = types.listOf types.str;
      };
    };

    config = let
      cfg = config.internal.boot.kernel;
    in {
      boot = {
        kernelPackages =
          if cfg.cachyos.enable
          then pkgs.cachyosKernels.linuxPackages-cachyos-latest
          else cfg.packages;

        kernelParams = cfg.params;
      };

      nix.settings = mkIf cfg.cachyos.enable {
        substituters = ["https://attic.xuyh0120.win/lantian"];
        trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
      };

      nixpkgs.overlays = mkIf cfg.cachyos.enable [
        inputs.cachyos-kernel.overlays.pinned
      ];
    };
  };
}
