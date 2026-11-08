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
        extra-substituters = ["https://cache.lantian.pub/lantian"];
        extra-trusted-public-keys = ["lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ="];
      };

      nixpkgs.overlays = mkIf cfg.cachyos.enable [
        inputs.cachyos-kernel.overlays.pinned
      ];
    };
  };
}
