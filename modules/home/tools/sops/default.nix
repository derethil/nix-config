{
  config,
  pkgs,
  ...
}: {
  config = {
    home.packages = with pkgs; [sops age];
    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
