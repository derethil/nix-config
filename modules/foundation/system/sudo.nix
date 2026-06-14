{
  flake.modules.nixos.sudo = {
    security.sudo = {
      enable = true;
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
        Defaults env_keep += "DISPLAY EDITOR PATH"
      '';
    };

    internal.boot.impermanence.extraDirectories = ["/var/db/sudo"];
  };
}
