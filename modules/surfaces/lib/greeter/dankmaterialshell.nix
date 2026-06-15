{
  inputs,
  self,
  ...
}: {
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
    assertions = [
      {
        assertion = enabledCompositors != [];
        message = ''
          dankmaterialshell-greeter: no supported compositor enabled on primary user (${config.internal.primaryUser}).
          Enable one of: ${lib.concatStringsSep ", " (lib.attrNames supportedCompositors)}.
        '';
      }
    ];

    imports = [
      self.modules.nixos.greeter
      self.modules.nixos.primary-user
      inputs.dank-material-shell.nixosModules.greeter
    ];

    programs.dank-material-shell.greeter = {
      enable = true;
      quickshell.package = pkgs.inputs.quickshell.default;

      configHome = config.users.users.${config.internal.primaryUser}.home;

      compositor.name = lib.mkDefault (lib.head enabledCompositors);

      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };
    };
  };
}
