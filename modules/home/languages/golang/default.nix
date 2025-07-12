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
    goPath = mkOpt types.str "${config.xdg.dataHome}/go" "GOPATH directory";
  };

  config = mkIf cfg.enable {
    programs.go = {
      enable = true;
      goBin = ".local/bin";
      goPath = cfg.goPath;
    };
  };
}
