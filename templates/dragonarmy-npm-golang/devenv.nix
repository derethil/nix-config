{
  pkgs,
  inputs,
  ...
}: let
  playwright = inputs.playwright.packages.${pkgs.stdenv.hostPlatform.system};
in {
  env = {
    AWS_PROFILE = "DragonArmy";
    GOPRIVATE = "https://gitlab.dragonarmy.rocks";
    GIT_TERMINAL_PROMPT = "1";

    PLAYWRIGHT_BROWSERS_PATH = playwright.playwright-driver.browsers;
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };

  packages = with pkgs; [
    golangci-lint
    golangci-lint-langserver
    awscli2
    zip
    templ
    playwright.playwright-test
  ];

  languages = {
    go.enable = true;

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
