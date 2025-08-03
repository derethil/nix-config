{pkgs, ...}: {
  env = {
    AWS_PROFILE = "DragonArmy";
    GOPRIVATE = "https://gitlab.dragonarmy.rocks";
    GIT_TERMINAL_PROMPT = "1";
  };

  packages = [
    pkgs.golangci-lint
    pkgs.awscli2
  ];

  languages = {
    go = {
      enable = true;
    };
    javascript = {
      enable = true;
      npm.enable = true;
      directory = "webapp";
      package = pkgs.nodejs_20;
    };
  };

  processes = {
    backend.exec = "cd go && go run main.go";
    frontend.exec = "cd webapp && npm run dev";
  };

  enterShell = ''
    if ! aws sts get-caller-identity --profile "DragonArmy" &>/dev/null; then
      aws sso login --profile "DragonArmy"
    fi
  '';
}
