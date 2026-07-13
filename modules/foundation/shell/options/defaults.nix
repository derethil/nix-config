{lib, ...}: {
  flake.modules.generic.shell-defaults = {pkgs, ...}: {
    shell.defaultShell = lib.mkDefault pkgs.bashInteractive;

    shell.aliases = {
      wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      c = "clear";
    };
  };
}
