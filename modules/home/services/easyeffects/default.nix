{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.easyeffects;
in {
  options.glace.services.easyeffects = {
    enable = mkBoolOpt false "Whether to enable the EasyEffects audio effects service.";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.easyeffects
    ];

    services.easyeffects = {
      enable = true;
      preset = "Edifier-Speakers";
      extraPresets = {
        EdEQ = builtins.fromJSON (builtins.readFile ./presets/Edifier-Speakers.json);
        Pass = builtins.fromJSON (builtins.readFile ./presets/Passthrough.json);
      };
    };
  };
}
