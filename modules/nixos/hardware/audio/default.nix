{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkForce;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.hardware.audio;
in {
  options.glace.hardware.audio = {
    enable = mkBoolOpt false "Whether to enable audio support.";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pulseaudio.enable = mkForce false;

    services.pipewire = {
      enable = true;
      audio.enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # Provided by nix-gaming module
      lowLatency = {
        enable = true;
        quantum = 1024;
        rate = 24000;
      };
    };

    environment.systemPackages = [pkgs.pulsemixer];

    glace.user.extraGroups = ["audio"];
  };
}
