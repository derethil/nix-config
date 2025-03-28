{
  inputs,
  pkgs,
  ...
}: let
  traced = builtins.concatStringsSep ", " (builtins.attrNames inputs.lib);
  astal-pkgs = builtins.trace traced inputs.ags.packages.${pkgs.system};
  # astal = inputs.ags.lib.bundle {
  #   inherit pkgs;
  #   src = ./.;
  #   name = "astal";
  #   entry = "app.ts";
  #   gtk4 = false;
  #   extraPackages = with pkgs; [
  #     astal-pkgs.apps
  #     astal-pkgs.battery
  #     astal-pkgs.hyprland
  #     astal-pkgs.mpris
  #     astal-pkgs.notifd
  #     astal-pkgs.tray
  #     astal-pkgs.wireplumber
  #
  #     fzf
  #     libgtop
  #   ];
  # };
in {
  # home.packages = [
  #   astal
  # ];
}
