{
  lib,
  pkgs,
  stdenv,
  inputs,
}:
lib.internal.buildFirefoxXpiAddon {
  pname = "ultimadark";
  version = "latest";
  addonId = "7c7f6dea-3957-4bb9-9eec-2ef2b9e5bcec";
  src = inputs.ultimadark;
  inherit pkgs stdenv;

  meta = with lib; {
    description = "The Fastest Dark Mode Extension - uses aggressive techniques to enable dark mode on every site";
    homepage = "https://github.com/ThomazPom/Moz-Ext-UltimaDark";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
