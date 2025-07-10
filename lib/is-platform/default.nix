{lib, ...}: let
  osRelease =
    if builtins.pathExists "/etc/os-release"
    then builtins.readFile "/etc/os-release"
    else "";
in {
  platform = {
    isNixOS = builtins.pathExists /etc/NIXOS;
    isArch =
      lib.strings.hasInfix "ID_LIKE=arch" osRelease
      || lib.strings.hasInfix "ID=arch" osRelease;
  };
}
