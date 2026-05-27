{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.starcitizen;
in {
  options.glace.apps.starcitizen = {
    enable = mkBoolOpt false "Whether to enable Star Citizen";
  };

  config = mkIf cfg.enable {
    programs.rsi-launcher = {
      enable = true;
      umu.enable = true;
      wine = pkgs.unstable.wineWow64Packages.staging;
      preCommands = ''
        export DXVK_HUD=compiler
        export PROTON_ENABLE_NGX_UPDATER="1"
        export DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE="on"
        export DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE="on"
        export DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE="on"
        export DXVK_NVAPI_DRS_NGX_DLSS_SR_OVERRIDE_RENDER_PRESET_SELECTION="render_preset_latest"
        export DXVK_NVAPI_DRS_NGX_DLSS_RR_OVERRIDE_RENDER_PRESET_SELECTION="render_preset_latest"
      '';
    };
  };
}
