{
  config,
  pkgs,
  ...
}: {
  config = {
    environment.systemPackages = with pkgs; [sops age];
    sops.age.keyFile = "${config.glace.user.home}/.config/sops/age/keys.txt";
  };
}
