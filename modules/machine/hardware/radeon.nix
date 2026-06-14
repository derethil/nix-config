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
    inherit (lib) mkOption mkIf optional types flatten;
    cfg = config.internal.hardware.radeon;
  in {
    imports = [self.modules.nixos.lact];

    options.internal.hardware.radeon = {
      videoAcceleration = mkOption {
        type = types.bool;
        default = true;
        description = "Enable hardware video acceleration packages.";
      };

      mesa = {
        package = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Custom 64-bit mesa package. Falls back to nixpkgs/unstable based on useUnstable.";
        };
        package32 = mkOption {
          type = types.nullOr types.package;
          default = null;
          description = "Custom 32-bit mesa package. Falls back to nixpkgs/unstable based on useUnstable.";
        };
        useUnstable = mkOption {
          type = types.bool;
          default = true;
          description = "Use mesa from nixpkgs-unstable instead of stable.";
        };
      };

      ppfeaturemask = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          amdgpu.ppfeaturemask with PP_OVERDRIVE_MASK (0x4000) enabled. Required for
          fan control on 7000/9000-series cards via CoolerControl. Compute with:
            printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))"
        '';
      };
    };

    config = {
      assertions = [
        {
          assertion = !(cfg.mesa.useUnstable && (cfg.mesa.package != null || cfg.mesa.package32 != null));
          message = "internal.hardware.radeon.mesa: 'useUnstable' conflicts with explicit 'package'/'package32'. Pick one.";
        }
      ];

      environment.systemPackages = with pkgs; [
        radeontop
        mesa-demos
        vulkan-tools
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;

        package =
          if cfg.mesa.package != null
          then cfg.mesa.package
          else if cfg.mesa.useUnstable
          then pkgs.unstable.mesa
          else pkgs.mesa;

        package32 =
          if cfg.mesa.package32 != null
          then cfg.mesa.package32
          else if cfg.mesa.useUnstable
          then pkgs.unstable.pkgsi686Linux.mesa
          else pkgs.pkgsi686Linux.mesa;

        extraPackages = mkIf cfg.videoAcceleration (with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
        ]);

        extraPackages32 = mkIf cfg.videoAcceleration (with pkgs.driversi686Linux; [
          libva-vdpau-driver
          libvdpau-va-gl
        ]);
      };

      services.xserver.videoDrivers = ["amdgpu"];

      boot.kernelParams = flatten [
        (optional (cfg.ppfeaturemask != null) "amdgpu.ppfeaturemask=${cfg.ppfeaturemask}")
        # SMU driver/firmware interface mismatch (driver 0x2e vs firmware 0x33)
        # causes GPU hangs in GFXOFF transitions. Disable until kernel catches up.
        ["amdgpu.gfxoff=0"]
      ];
    };
  };
}
