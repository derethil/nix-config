{...}: {
  flake.modules.darwin.skhd = {
    services.skhd.enable = true;

    system.activationScripts.reloadSkhd.text = ''
      dscl . -list /Users UniqueID | awk '$2 >= 500 {print $2}' | while read -r uid; do
        /bin/launchctl kickstart -k "gui/$uid/org.nixos.skhd" 2>/dev/null || true
      done
    '';
  };
}
