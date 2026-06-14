{self, ...}: {
  # Symlink the themes directory back to this repo so theme JSON files are
  # tracked in git (survives impermanence resets) AND DMS's UI can still
  # download new themes — they land in the repo and show up as `git status`
  # for review/commit. The rest of the DMS config stays read-only/declarative.
  flake.modules.homeManager.dankmaterialshell-panel = {config, ...}: {
    imports = [self.modules.homeManager.flake-root];

    xdg.configFile."DankMaterialShell/themes".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.internal.flakeRoot}/modules/surfaces/lib/panel/dankmaterialshell/_themes";
  };
}
