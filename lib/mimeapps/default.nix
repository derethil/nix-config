{lib, ...}:
with lib; {
  ## mkMimeApps

  ## Create MIME type associations for an application.
  ##
  ## ```nix
  ## lib.mkMimeApps "firefox.desktop" ["text/html" "image/png"]
  ## ```
  ##
  #@ String -> [String] -> AttrSet
  mkMimeApps = app: mimes:
    genAttrs mimes (mime: [app]);
}
