{inputs, ...}: {
  flake-file.inputs.cachyos-kernel = {
    url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  flake.modules.nixos.kernel = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
  in {
    options.internal.boot.kernel = {
      cachyos.enable = mkEnableOption "CachyOS kernel";
      packages = mkOption {
        type = types.raw;
        default = pkgs.linuxPackages_latest;
      };
      params = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };

    config = let
      cfg = config.internal.boot.kernel;
    in {
      nixpkgs.overlays = mkIf cfg.cachyos.enable [
        inputs.cachyos-kernel.overlays.pinned
      ];

      nix.settings = mkIf cfg.cachyos.enable {
        substituters = ["https://attic.xuyh0120.win/lantian"];
        trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
      };

      boot.kernelPackages =
        if cfg.cachyos.enable
        then pkgs.cachyosKernels.linuxPackages-cachyos-latest
        else cfg.packages;

      boot.kernelParams = cfg.params;
    };
  };
}
