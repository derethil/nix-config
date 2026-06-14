{lib, ...}: {
  flake.modules.homeManager.davmail = {config, ...}: let
    inherit (lib) mkOption types;
  in {
    options.internal.davmail.caldavPort = mkOption {
      type = types.int;
      default = 1080;
      description = "Local port DavMail exposes its CalDAV bridge on.";
    };

    config.services.davmail = {
      enable = true;
      imitateOutlook = true;
      settings = {
        "davmail.server" = true;

        "davmail.mode" = "O365Modern";
        "davmail.url" = "https://outlook.office365.com/EWS/Exchange.asmx";
        "davmail.oauth.persistToken" = true;

        "davmail.caldavPort" = config.internal.davmail.caldavPort;
        "davmail.allowRemote" = false;
      };
    };
  };
}
