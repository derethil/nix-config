{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.noctalia.url = "github:noctalia-dev/noctalia/cachix";

  flake.modules = {
    nixos.noctalia = {
      imports = [inputs.noctalia.nixosModules.default];

      nix.settings = {
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      };

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };
    };

    homeManager.noctalia-panel = {config, ...}: {
      imports = [
        inputs.noctalia.homeModules.default
        self.modules.homeManager.flake-root
        self.modules.homeManager.calendars
        self.modules.homeManager.wallpaper
      ];

      # Settings UI changes are intentionally ephemeral.  The complete source
      # of truth is programs.noctalia.settings in this module tree.
      home.activation.clearNoctaliaState = config.lib.dag.entryAfter ["writeBoundary"] ''
        run rm -f ${config.xdg.stateHome}/noctalia/settings.toml
      '';

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };
    };
  };
}
