{self, ...}: let
  lsregister = "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister";
in {
  flake.modules.homeManager.reset-launch-services = {lib, ...}: {
    home.activation.resetLaunchServices = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Resetting Launch Services database..."
      ${lsregister} -r -domain local -domain system -domain user
    '';
  };

  flake.modules.darwin.reset-launch-services = {pkgs, ...}: {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "reset-launch-services" ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "Resetting macOS Launch Services database..."
        ${lsregister} -r -domain local -domain system -domain user
        echo "Launch Services database reset complete!"
        echo "Default application associations should now be properly recognized."
        echo "You may need to restart applications for changes to take full effect."
      '')
    ];

    system.activationScripts.resetLaunchServices.text = ''
      echo "Resetting Launch Services database..."
      ${lsregister} -r -domain local -domain system -domain user
    '';

    home-manager.sharedModules = [self.modules.homeManager.reset-launch-services];
  };
}
