{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.mattermost;
in {
  options.glace.apps.mattermost = {
    enable = mkBoolOpt true "Whether to enable the Mattermost desktop client.";
  };

  config = mkIf cfg.enable {
    tools.homebrew.macApps = {
      "Mattermost Desktop" = 1614666244;
    };
  };
}
