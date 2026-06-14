{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };
  };

  flake.modules.nixos.starcitizen = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nix-citizen.nixosModules.default
      self.modules.nixos.zram
    ];

    nix.settings = {
      substituters = ["https://nix-citizen.cachix.org"];
      trusted-public-keys = ["nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="];
    };

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
