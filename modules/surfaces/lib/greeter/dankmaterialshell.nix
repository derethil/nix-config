{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.dank-greeter = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:AvengeMedia/dank-greeter";
  };

  flake.modules.nixos.dankmaterialshell-greeter = {
    config,
    lib,
    pkgs,
    ...
  }: let
    hm = config.home-manager.users.${config.internal.primaryUser};

    supportedCompositors = {
      niri = hm.wayland.windowManager.niri.enable or false;
    };

    enabledCompositors = lib.attrNames (lib.filterAttrs (_: v: v) supportedCompositors);
  in {
    imports = [
      inputs.dank-greeter.nixosModules.default
      self.modules.nixos.greeter
      self.modules.nixos.primary-user
    ];

    internal.boot.impermanence.extraDirectories = ["/var/lib/dms-greeter"];

    programs.dms-greeter = {
      enable = true;
      compositor.name = lib.mkDefault (lib.head enabledCompositors);
      configHome = config.users.users.${config.internal.primaryUser}.home;

      logs = {
        path = "/tmp/dms-greeter.log";
        save = true;
      };

      quickshell.package = pkgs.inputs.quickshell.default;
    };

    assertions = [
      {
        assertion = enabledCompositors != [];

        message = ''
          dankmaterialshell-greeter: no supported compositor enabled on primary user (${config.internal.primaryUser}).
          Enable one of: ${lib.concatStringsSep ", " (lib.attrNames supportedCompositors)}.
        '';
      }
    ];
  };
}
