{
  config,
  pkgs,
  ...
}: {
  config = {
    environment.systemPackages = with pkgs; [sops age];
    sops.age = {
      generateKey = true;
      keyFile = "${config.glace.user.home}/.config/sops/age/keys.txt";
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
  };
}
