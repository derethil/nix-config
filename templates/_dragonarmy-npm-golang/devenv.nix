{
  pkgs,
  inputs,
  ...
}: let
  playwright = inputs.playwright.packages.${pkgs.stdenv.hostPlatform.system};
  pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  env = {
    GOPRIVATE = "gitlab.dragonarmy.rocks/*";
    GIT_TERMINAL_PROMPT = "1";
    PLAYWRIGHT_BROWSERS_PATH = playwright.playwright-driver.browsers;
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    KEYCLOAK_URL = "https://keycloak-dev.dragonarmy.rocks";
  };

  packages = with pkgs; [
    golangci-lint
    golangci-lint-langserver
    playwright.playwright-test
    temurin-jre-bin-21
  ];

  languages = {
    go = {
      enable = true;
      package = pkgs-unstable.go;
    };

    javascript = {
      enable = true;
      npm.enable = true;
      directory = "webapp";
      package = pkgs.nodejs_24;
    };
  };

  processes = {
    backend = {
      cwd = "./go";
      exec = ''go run main.go ''${DEBUG+-debug}'';
    };
    frontend = {
      cwd = "./webapp";
      exec = "npm run dev";
    };
  };

  tasks = {
    "aws:sso-login" = {
      exec = "aws sts get-caller-identity --no-cli-pager > /dev/null 2>&1 || aws sso login";
      before = ["devenv:processes:backend"];
    };
  };
}
