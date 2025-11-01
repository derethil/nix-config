{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.aws-cli;
in {
  options.glace.tools.aws-cli = {
    enable = mkBoolOpt false "Whether to enable the AWS CLI.";
  };

  config = mkIf cfg.enable {
    programs.awscli = {
      enable = true;
      package = pkgs.awscli2;
      settings = {
        default = {
          region = "us-gov-west-1";
          output = "json";
        };
        "profile DragonArmy" = {
          sso_session = "DragonArmy";
          sso_account_id = "284740501404";
          sso_role_name = "DRAGONArmy";
          region = "us-gov-west-1";
          output = "json";
        };
        "sso-session DragonArmy" = {
          sso_start_url = "https://start.us-gov-west-1.us-gov-home.awsapps.com/directory/dragonarmy";
          sso_region = "us-gov-west-1";
          sso_registration_scopes = "sso:account:access";
        };
      };
    };
  };
}
