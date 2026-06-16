{...}: {
  flake.modules.homeManager.aws-cli = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [
      pkgs.awsebcli
    ];

    programs.awscli = {
      enable = true;
      package = pkgs.awscli2;
      settings = {
        default = {
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

    programs.fish.interactiveShellInit = lib.mkAfter ''
      complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed "s/ \$//"; end)'
    '';

    programs.bash.initExtra = ''
      complete -C aws_completer aws
    '';

    programs.zsh.initContent = ''
      autoload -U +X bashcompinit && bashcompinit
      complete -C aws_completer aws
    '';
  };
}
