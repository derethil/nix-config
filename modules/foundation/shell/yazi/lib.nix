{lib, ...}: {
  flake.lib.mkYaziApplication = {
    config,
    pkgs,
    flavor,
    yaziConfig,
    comment ? "Open Yazi file manager",
    genericName ? "File Manager",
    icon ? "file-manager",
    mimeType ? [],
    name ? "Yazi [${flavor}]",
    openToPath ? "",
  }: let
    mkYaziSymlink = p: config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/yazi/${p}";

    yaziConfigPath = "${config.xdg.configHome}/${flavor}";

    launchScript = pkgs.writeShellScript "${flavor}-launch" ''
      exec ${lib.getExe pkgs.xdg-terminal-exec} --app-id=yazi env YAZI_CONFIG_HOME=${yaziConfigPath} yazi${lib.optionalString (openToPath != "") " ${lib.escapeShellArg openToPath}"}
    '';
  in {
    xdg = {
      configFile = {
        "${flavor}/flavors".source = mkYaziSymlink "flavors";
        "${flavor}/init.lua".source = mkYaziSymlink "init.lua";
        "${flavor}/keymap.toml".source = mkYaziSymlink "keymap.toml";
        "${flavor}/plugins".source = mkYaziSymlink "plugins";
        "${flavor}/theme.toml".source = mkYaziSymlink "theme.toml";
        "${flavor}/yazi.toml".text = yaziConfig;
      };

      desktopEntries = {
        "${flavor}" =
          {
            inherit comment genericName icon name;
            categories = ["FileManager" "FileTools" "System"];
            exec = "${launchScript}";
            type = "Application";
          }
          // lib.optionalAttrs (mimeType != []) {inherit mimeType;};
      };
    };
  };
}
