{lib, ...}: {
  flake.lib.mkMimeApps = app: mimes: lib.genAttrs mimes (_: [app]);

  flake.modules.homeManager.mimeapps = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) filter length isList attrNames concatStringsSep optionals mkIf;
    inherit (pkgs.stdenv.hostPlatform) isLinux;

    defaults = config.xdg.mimeApps.defaultApplications;

    duplicates =
      filter
      (mime: let v = defaults.${mime}; in isList v && length v > 1)
      (attrNames defaults);
  in {
    xdg.mimeApps = {
      enable = mkIf isLinux true;
    };

    assertions = optionals isLinux [
      {
        assertion = duplicates == [];
        message = ''
          The following MIME types have multiple default applications defined: ${concatStringsSep ", " duplicates}

          Each MIME type can only have one default application.
        '';
      }
    ];
  };
}
