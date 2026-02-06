{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt mkOpt;
  inherit (lib.types) nullOr str;
  cfg = config.glace.services.coolercontrol.amdgpu;
in {
  options.glace.services.coolercontrol.amdgpu = {
    enable = mkBoolOpt false "Enable AMD GPU fan control (required for 7000/9000 series and newer)";
    ppfeaturemask = mkOpt (nullOr str) null ''
      AMD GPU ppfeaturemask value with PP_OVERDRIVE_MASK (0x4000) enabled.
      To calculate the correct value for your system, run:
        printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))"
      Then set this option to the hex value from the output (e.g., "0xfff7ffff").
    '';
  };

  config = mkIf cfg.enable {
    boot.kernelParams = mkIf (cfg.ppfeaturemask != null) [
      "amdgpu.ppfeaturemask=${cfg.ppfeaturemask}"
    ];

    assertions = [
      {
        assertion = cfg.ppfeaturemask != null;
        message = "glace.services.coolercontrol.amdgpu.ppfeaturemask must be set when amdgpu.enable is true. Run: printf 'amdgpu.ppfeaturemask=0x%x\\n' \"$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))\"";
      }
    ];
  };
}
