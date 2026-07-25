{
  flake.modules.darwin.finder = {
    system.defaults.finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      FXRemoveOldTrashItems = true;
      ShowPathbar = true;
      _FXSortFoldersFirst = true;
    };
  };
}
