{
  config,
  pkgs,
  ...
}: {
  config = {
    environment.systemPackages = with pkgs; [sops age];
    sops.age.keyFile = "${config.user.home}/.config/sops/age/keys.txt";
  };
}
