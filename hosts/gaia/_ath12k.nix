{pkgs, ...}: {
  # Wifi card under-reports legal txpower; pin to a fixed value when wlp15s0
  # comes up to avoid the kernel's overly conservative default.
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "fix-ath12k-txpower" ''
        if [ "$1" = "wlp15s0" ] && [ "$2" = "up" ]; then
          ${pkgs.iw}/bin/iw dev wlp15s0 set txpower fixed 1900
        fi
      '';
    }
  ];
}
