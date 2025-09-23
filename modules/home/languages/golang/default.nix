{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.languages.golang;
in {
  # TODO: this doesn't work :)

  options.languages.golang = {
    enable = mkBoolOpt false "Whether to enable Golang language support";
  };

  config = mkIf cfg.enable {
    programs.go = {
      enable = true;
      env = {
        GOBIN = "${config.home.homeDirectory}/.local/bin";
        GOPATH = "${config.xdg.dataHome}/go";
      };
    };
  };
}
