{pkgs, ...}: {
  config = {
    environment.systemPackages = with pkgs; [sops age];
    sops.age = {
      keyFile = "/persist/etc/sops/age/keys.txt";
      sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
    };
  };
}
