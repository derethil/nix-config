{lib, ...}: {
  flake.modules.homeManager.easyeffects = {config, ...}: let
    cfg = config.services.easyeffects;
  in {
    services.easyeffects = {
      enable = true;
    };

    assertions = [
      {
        assertion = cfg.preset == null || cfg.extraPresets ? ${cfg.preset};
        message = "services.easyeffects.preset = \"${toString cfg.preset}\" but no matching key in extraPresets (got: ${toString (lib.attrNames cfg.extraPresets)}).";
      }
    ];
  };
}
