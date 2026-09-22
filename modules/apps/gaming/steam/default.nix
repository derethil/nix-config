{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.nix-gaming.url = "github:fufexan/nix-gaming";

  flake.modules = {
    nixos.steam = {
      config,
      lib,
      pkgs,
      ...
    }: let
      isCachyKernel = lib.hasInfix "cachyos" config.boot.kernelPackages.kernel.name;
    in {
      imports = [
        inputs.nix-gaming.nixosModules.platformOptimizations
        self.modules.nixos.pipewire-low-latency
        self.modules.nixos.steam-options
      ];

      config = {
        environment.systemPackages = [pkgs.internal.freeze-game-version];

        hardware = {
          steam-hardware.enable = true;
          xpadneo.enable = true;
        };

        programs = {
          gamemode.enable = true;

          gamescope = {
            enable = true;
            capSysNice = false;
          };

          steam = {
            enable = true;

            package = pkgs.unstable.steam.override {
              extraEnv =
                {
                  DXVK_ASYNC = "1";
                  ENABLE_LAYER_MESA_ANTI_LAG = "1";
                  GAMEMODERUN = "1";
                  MESA_SHADER_CACHE_MAX_SIZE = "16G";
                  PROTON_FSR4_UPGRADE = "1";
                  PROTON_LOCAL_SHADER_CACHE = "1";
                  PROTON_VKD3D_HEAP = "1";
                }
                // config.gaming.steam.extraEnv;
            };

            extest.enable = true;
            gamescopeSession.enable = false;
            localNetworkGameTransfers.openFirewall = true;
            platformOptimizations.enable = true;
            protontricks.enable = true;
            remotePlay.openFirewall = true;
          };
        };

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
