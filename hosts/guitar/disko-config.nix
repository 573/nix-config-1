{
  # nix eval .#nixosConfigurations.guitar.config.fileSystems | nix run nixpkgs#nixfmt-rfc-style
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "luks-35babb35-1c2d-49df-bf46-6c9efd7d44b6";
		device = "/dev/disk/by-uuid/35babb35-1c2d-49df-bf46-6c9efd7d44b6";
                # disable settings.keyFile if you want to use interactive password entry
                # TODO I think - because I type in the password in grub already - this
		# passwordFile line is the reason I got asked twice on boot
		# probably I can resort to settings.keyFile here or maybe first
		# I leave both out and only when the new system won't start will
		# try settings.keyFile 
		# reusePassphrase which is default should sort the rest
		#passwordFile = "/boot/crypto_keyfile.bin"; # Interactive
                settings = {
		  # See https://wiki.archlinux.org/index.php?title=Dm-crypt/Specialties&oldid=844866#Discard/TRIM_support_for_solid_state_drives_(SSD)
                  #allowDiscards = true;
		  fallbackToPassword = true;
                  keyFile = "/boot/crypto_keyfile.bin";
                };
                content = {
                  type = "filesystem";
		  device = "/dev/disk/by-uuid/aa10d8ce-0844-4789-b345-2024e7449a0b";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
	    # See https://unix.stackexchange.com/a/23074
            swap = {
              size = "8G";
              content = {
                type = "luks";
                name = "luks-7c125b64-c9f3-43dd-818e-1d5e9453b934";
		device = "/dev/disk/by-uuid/7c125b64-c9f3-43dd-818e-1d5e9453b934";
                #passwordFile = "/boot/crypto_keyfile.bin"; # Interactive
                settings = {
		  # See https://wiki.archlinux.org/index.php?title=Dm-crypt/Specialties&oldid=844866#Discard/TRIM_support_for_solid_state_drives_(SSD)
                  #allowDiscards = true;
		  fallbackToPassword = true;
                  keyFile = "/boot/crypto_keyfile.bin";
                };
                content = {
                  type = "swap";
		  device = "/dev/disk/by-uuid/3ea81e03-fc18-498f-bc61-5fdc11c23fdd";
                };
              };
            };
          };
        };
      };
    };
  };
}
