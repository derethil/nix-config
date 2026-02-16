{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.desktop.xdg.mimeapps;
in {
  options.glace.desktop.xdg.mimeapps = {
    enable = mkBoolOpt pkgs.stdenv.isLinux "Whether to enable XDG MIME applications support";

    default = mkOpt (types.attrsOf (types.listOf types.str)) {} ''
      Default MIME type associations. Format: "mime/type" = ["application.desktop"]
      These will be set as the default applications for the given MIME types.
    '';

    associations = mkOpt (types.attrsOf (types.listOf types.str)) {} ''
      Added MIME type associations. Format: "mime/type" = ["application.desktop"]
      These will be added as alternative applications for the given MIME types.
    '';
  };

  config = mkIf cfg.enable {
    assertions = let
      duplicates = lib.filter (
        mime:
          (lib.length (cfg.default.${mime} or [])) > 1
      ) (lib.attrNames cfg.default);
    in [
      {
        assertion = duplicates == [];
        message = ''
          The following MIME types have multiple default applications defined:
          ${lib.concatStringsSep ", " duplicates}

          Each MIME type can only have one default application.
        '';
      }
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = cfg.default;
      associations.added = cfg.associations;
    };
  };
}
