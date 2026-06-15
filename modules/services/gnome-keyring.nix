{lib, ...}: {
  flake.modules.nixos.gnome-keyring = {config, ...}: {
    services.gnome.gnome-keyring.enable = true;

    # Auto-unlock the keyring when greetd authenticates the user. No-op
    # on hosts without greetd.
    security.pam.services.greetd.enableGnomeKeyring =
      lib.mkIf config.services.greetd.enable true;
  };
}
