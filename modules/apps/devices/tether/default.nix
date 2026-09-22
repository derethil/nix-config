{inputs, ...}: {
  flake-file.inputs.tether.url = "github:zackb/tether";

  flake.modules.nixos.tether = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe';

    tetherPkg = inputs.tether.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # note that the tether package hard-codes versin=0.2.18 currently so tether --version
    # returns the wrong version, but the package itself is actually latest.
    themedTetherPkg = pkgs.symlinkJoin {
      name = "tether-${tetherPkg.version}";
      nativeBuildInputs = [pkgs.makeWrapper];
      paths = [tetherPkg];

      postBuild = ''
        wrapProgram $out/bin/tether-gtk \
          --set GDK_DPI_SCALE 1.1 \
          --run 'export XDG_CONFIG_HOME="$HOME/.config/tether-gtk-theme"'
      '';
    };
  in {
    imports = [inputs.tether.nixosModules.default];

    home-manager.sharedModules = [
      {
        systemd.user.services.tetherd = {
          Install.WantedBy = ["graphical-session.target"];

          Service = {
            ExecStart = getExe' themedTetherPkg "tetherd";
            Restart = "on-failure";
            RestartSec = "5s";
          };

          Unit = {
            After = ["graphical-session.target"];
            Description = "Tether daemon (iPhone bridge)";
            PartOf = ["graphical-session.target"];
            StartLimitBurst = 5;
            StartLimitIntervalSec = 30;
          };
        };

        xdg.configFile."tether-gtk-theme/gtk-3.0/gtk.css".source = ./imessage.css;
      }
    ];

    programs.tether = {
      enable = true;
      package = themedTetherPkg;

      bluetooth = {
        enable = true;
        adapters = ["hci0"];
      };

      wifi = {
        enable = true;
        openFirewall = true;
      };
    };

    # https://github.com/zackb/tether/blob/main/docs/BLUETOOTH.md#keeping-the-phones-audio-on-the-phone
    services.pipewire.wireplumber.extraConfig."51-no-phone-audio"."monitor.bluez.properties"."bluez5.roles" = ["a2dp_source" "hfp_ag" "bap_source"];
  };
}
