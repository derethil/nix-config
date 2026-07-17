{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  flake.modules = {
    nixos.steam = {
      pkgs,
      config,
      lib,
      ...
    }: let
      isCachyKernel = lib.hasInfix "cachyos" config.boot.kernelPackages.kernel.name;
    in {
      imports = [
        self.modules.nixos.steam-options
        self.modules.nixos.pipewire-low-latency
        inputs.nix-gaming.nixosModules.platformOptimizations
      ];

      config = {
        programs = {
          steam = {
            enable = true;

            package = pkgs.unstable.steam.override {
              extraEnv =
                {
                  GAMEMODERUN = "1";
                  DXVK_ASYNC = "1";
                  PROTON_LOCAL_SHADER_CACHE = "1";
                  PROTON_VKD3D_HEAP = "1";
                  PROTON_FSR4_UPGRADE = "1";
                  MESA_SHADER_CACHE_MAX_SIZE = "16G";
                  ENABLE_LAYER_MESA_ANTI_LAG = "1";
                }
                // config.gaming.steam.extraEnv;
            };

            extest.enable = true;
            remotePlay.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
            gamescopeSession.enable = false;

            protontricks.enable = true;

            platformOptimizations.enable = true;
          };

          gamemode = {
            enable = true;
          };

          gamescope = {
            enable = true;
            capSysNice = false;
          };
        };

        hardware = {
          steam-hardware.enable = true;
          xpadneo.enable = true;
        };

        environment.systemPackages = [pkgs.internal.freeze-game-version];

        # work around for issue with capSysNice not working in gamescope. even though it still
        # complains that it doesn't have cap nice ability to set it its own nice value.  ananicy
        # is setting it -20 (highest priority).
        # See: https://github.com/NixOS/nixpkgs/issues/351516
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider =
            if isCachyKernel
            then pkgs.ananicy-rules-cachyos
            else pkgs.ananicy-cpp;
        };
      };
    };

    darwin.steam = {
      imports = [self.modules.darwin.homebrew];
      config.homebrew.casks = ["steam"];
    };
  };
}
