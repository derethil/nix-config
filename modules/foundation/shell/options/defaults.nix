{...}: {
  flake.modules.generic.shell-defaults = {
    shell.aliases = {
      wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      c = "clear";
    };
  };
}
