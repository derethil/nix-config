{
  flake.modules.darwin.settings = {
    system.defaults = {
      NSGlobalDomain = {
        NSDisableAutomaticTermination = true;
        NSDocumentSaveNewDocumentsToCloud = false;
      };

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
    };
  };
}
