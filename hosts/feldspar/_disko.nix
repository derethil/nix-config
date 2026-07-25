let
  device = "/dev/nvme0n1";
  bootSize = "2G";
  swapSize = "32G";
  isSSD = true;
in {
  disko.devices.disk.main = {
    inherit device;

    content = {
      partitions = {
        ESP = {
          content = {
            format = "vfat";
            mountpoint = "/boot";
            type = "filesystem";
          };

          size = bootSize;
          type = "EF00";
        };

        luks = {
          content = {
            content = {
              extraArgs = ["-f"];

              subvolumes = {
                "/home" = {
                  mountOptions = ["compress=zstd" "noatime" "subvol=home"];
                  mountpoint = "/home";
                };

                "/log" = {
                  mountOptions = ["compress=zstd" "noatime" "subvol=log"];
                  mountpoint = "/var/log";
                };

                "/nix" = {
                  mountOptions = ["compress=zstd" "noatime" "subvol=nix"];
                  mountpoint = "/nix";
                };

                "/persist" = {
                  mountOptions = ["compress=zstd" "noatime" "subvol=persist"];
                  mountpoint = "/persist";
                };

                "/root" = {
                  mountOptions = ["compress=zstd" "noatime" "subvol=root"];
                  mountpoint = "/";
                };

                "/root-blank" = {};
              };

              type = "btrfs";
            };

            name = "enc";
            passwordFile = "/tmp/secret.key";
            settings.allowDiscards = isSSD;
            type = "luks";
          };

          size = "100%";
        };

        swap = {
          content.type = "swap";
          size = swapSize;
        };
      };

      type = "gpt";
    };

    type = "disk";
  };

  fileSystems = {
    "/home".neededForBoot = true; # so sops can retrieve ~/.config/sops/age/keys.txt
    "/persist".neededForBoot = true;
    "/var/log".neededForBoot = true;
  };
}
