{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.services.davmail;
in {
  options.glace.services.davmail = {
    enable = mkBoolOpt false "Whether to enable the DavMail email service.";
    ports = {
      caldav = mkOpt types.int 1080 "The port to expose the CalDAV service on.";
    };
  };

  config = mkIf cfg.enable {
    services.davmail = {
      enable = true;
      imitateOutlook = true;
      settings = {
        "davmail.server" = true;

        "davmail.mode" = "O365Modern";
        "davmail.url" = "https://outlook.office365.com/EWS/Exchange.asmx";
        "davmail.oauth.persistToken" = true;

        "davmail.caldavPort" = cfg.ports.caldav;
        "davmail.allowRemote" = false;
      };
    };
  };
}
