{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce types flatten;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.hardware.audio;
in {
  options.glace.hardware.audio = {
    enable = mkBoolOpt false "Whether to enable audio support.";
    extraPackages = mkOpt (types.listOf types.package) [pkgs.easyeffects] "Additional packages to install.";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pulseaudio.enable = mkForce false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs;
      flatten [
        pulsemixer
        cfg.extraPackages
      ];

    glace.user.extraGroups = ["audio"];
  };
}
