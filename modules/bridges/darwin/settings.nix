{
  flake.modules.darwin.settings = {
    system.defaults = {
      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = false;
      };

      NSGlobalDomain = {
        NSDisableAutomaticTermination = true;
        NSDocumentSaveNewDocumentsToCloud = false;
      };
    };
  };
}
