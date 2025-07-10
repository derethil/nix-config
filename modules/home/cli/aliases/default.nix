{lib, ...}:
with lib;
with internal; {
  options.cli = with types; {
    aliases = mkOption {
      type = attrsOf str;
      default = {};
      description = "Aliases for the CLI.";
    };
    abbreviations = mkOption {
      type = attrsOf str;
      default = {};
      description = "Abbreviations for the CLI.";
    };
  };

  config = {
    cli = {
      aliases = {
        agsv2 = "ags run --directory ~/.config/astal";
        wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
        hueadm = "hueadm --config ~/.config/.hueadm.json";
        c = "clear";
      };
      abbreviations = {
        be = "bundle exec";
      };
    };
  };
}
