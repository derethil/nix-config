{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.radeon = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) flatten mkIf mkOption optional types;
    cfg = config.internal.hardware.radeon;
  in {
    imports = [self.modules.nixos.lact];

    options.internal.hardware.radeon = {
      mesa = {
        package = mkOption {
          default = null;
          description = "Custom 64-bit mesa package. Falls back to nixpkgs/unstable based on useUnstable.";
          type = types.nullOr types.package;
        };

        package32 = mkOption {
          default = null;
          description = "Custom 32-bit mesa package. Falls back to nixpkgs/unstable based on useUnstable.";
          type = types.nullOr types.package;
        };

        useUnstable = mkOption {
          default = true;
          description = "Use mesa from nixpkgs-unstable instead of stable.";
          type = types.bool;
        };
      };

      ppfeaturemask = mkOption {
        default = null;

        description = ''
          amdgpu.ppfeaturemask with PP_OVERDRIVE_MASK (0x4000) enabled. Required for
          fan control on 7000/9000-series cards via CoolerControl. Compute with:
            printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))"
        '';

        type = types.nullOr types.str;
      };

      videoAcceleration = mkOption {
        default = true;
        description = "Enable hardware video acceleration packages.";
        type = types.bool;
      };
    };

    config = {
      boot.kernelParams = flatten [
        (optional (cfg.ppfeaturemask != null) "amdgpu.ppfeaturemask=${cfg.ppfeaturemask}")
        # SMU driver/firmware interface mismatch (driver 0x2e vs firmware 0x33)
        # causes GPU hangs in GFXOFF transitions. Disable until kernel catches up.
        ["amdgpu.gfxoff=0"]
      ];

      environment.systemPackages = with pkgs; [
        mesa-demos
        radeontop
        vulkan-tools
      ];

      hardware.graphics = {
        enable = true;

        package =
          if cfg.mesa.package != null
          then cfg.mesa.package
          else if cfg.mesa.useUnstable
          then pkgs.unstable.mesa
          else pkgs.mesa;

        enable32Bit = true;

        extraPackages = mkIf cfg.videoAcceleration (with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
        ]);

        extraPackages32 = mkIf cfg.videoAcceleration (with pkgs.driversi686Linux; [
          libva-vdpau-driver
          libvdpau-va-gl
        ]);

        package32 =
          if cfg.mesa.package32 != null
          then cfg.mesa.package32
          else if cfg.mesa.useUnstable
          then pkgs.unstable.pkgsi686Linux.mesa
          else pkgs.pkgsi686Linux.mesa;
      };

      services.xserver.videoDrivers = ["amdgpu"];

      assertions = [
        {
          assertion = !(cfg.mesa.useUnstable && (cfg.mesa.package != null || cfg.mesa.package32 != null));
          message = "internal.hardware.radeon.mesa: 'useUnstable' conflicts with explicit 'package'/'package32'. Pick one.";
        }
      ];
    };
  };
}
