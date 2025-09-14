{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "reset-launch-services" ''
  #!/usr/bin/env bash

  set -euo pipefail

  echo "Resetting macOS Launch Services database..."
  
  # Reset the Launch Services database
  /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister \
    -kill -r -domain local -domain system -domain user

  echo "Launch Services database reset complete!"
  echo "Default application associations should now be properly recognized."
  echo "You may need to restart applications for changes to take full effect."
''