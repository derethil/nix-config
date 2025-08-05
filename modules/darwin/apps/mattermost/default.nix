{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.apps.mattermost;
in {
  options.apps.mattermost = {
    enable = mkBoolOpt true "Whether to enable the Mattermost desktop client.";
  };

  config = mkIf cfg.enable {
    tools.homebrew.macApps = {
      "Mattermost Desktop" = 1614666244;
    };
  };
}
