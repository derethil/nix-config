{lib, ...}: {
  flake.modules.homeManager.davmail = {config, ...}: let
    inherit (lib) mkOption types;
  in {
    options.internal.davmail.caldavPort = mkOption {
      default = 1080;
      description = "Local port DavMail exposes its CalDAV bridge on.";
      type = types.int;
    };

    config.services.davmail = {
      enable = true;
      imitateOutlook = true;

      settings = {
        "davmail.allowRemote" = false;
        "davmail.caldavPort" = config.internal.davmail.caldavPort;
        "davmail.mode" = "O365Modern";
        "davmail.oauth.persistToken" = true;
        "davmail.server" = true;
        "davmail.url" = "https://outlook.office365.com/EWS/Exchange.asmx";
      };
    };
  };
}
