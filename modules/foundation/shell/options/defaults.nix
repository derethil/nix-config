{lib, ...}: {
  flake.modules.generic.shell-defaults = {pkgs, ...}: {
    shell = {
      aliases = {
        c = "clear";
        wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      };

      defaultShell = lib.mkDefault pkgs.bashInteractive;
    };
  };
}
