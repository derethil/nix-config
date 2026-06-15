{...}: {
  flake.modules.nixos.gaia-ath12k-fixes = {pkgs, ...}: {
    # Card takes a very long time to scan, this limits the channels to the US ones to speed it up.
    hardware.wirelessRegulatoryDatabase = true;
    boot.extraModprobeConfig = "options cfg80211 ieee80211_regdom=US";

    # Card gets stuck in PCIe D3cold on warm reboot; disabling ASPM forces a clean power state.
    boot.kernelParams = ["pcie_aspm=off"];

    # Card under-reports legal txpower; pin to a fixed value when wlp15s0
    # comes up to avoid the kernel's overly conservative default.
    networking.networkmanager.dispatcherScripts = [
      {
        type = "pre-up";
        source = pkgs.writeShellScript "fix-ath12k-txpower" ''
          if [ "$1" = "wlp15s0" ]; then
            if ${pkgs.iw}/bin/iw dev wlp15s0 set txpower fixed 1900; then
              echo "ath12k-txpower: set txpower fixed 1900: ok" | ${pkgs.systemd}/bin/systemd-cat -t ath12k-txpower
            else
              echo "ath12k-txpower: set txpower fixed 1900: failed (exit $?)" | ${pkgs.systemd}/bin/systemd-cat -t ath12k-txpower -p err
            fi
          fi
        '';
      }
    ];
  };
}
