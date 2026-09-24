{self, ...}: let
  lsregister = "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister";
in {
  flake.modules = {
    darwin.reset-launch-services = {pkgs, ...}: {
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

      home-manager.sharedModules = [self.modules.homeManager.reset-launch-services];
    };

    homeManager.reset-launch-services = {lib, ...}: {
      # mac-app-util creates these after writeBoundary, so a domain-wide scan
      # during system activation cannot discover them.
      home.activation.registerLaunchServices = lib.hm.dag.entryAfter ["trampolineApps"] ''
        apps="$HOME/Applications/Home Manager Trampolines"

        if [[ -d "$apps" ]]; then
          echo "Registering Home Manager applications with Launch Services..."

          while IFS= read -r -d $'\0' app; do
            ${lsregister} -f "$app"
          done < <(find "$apps" -maxdepth 1 -name '*.app' -print0)
        fi
      '';
    };
  };
}
