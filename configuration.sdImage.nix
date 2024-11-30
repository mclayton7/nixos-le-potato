{ config, pkgs, lib, ... }:
{

  imports = [
    <nixos/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>

    # For nixpkgs cache
    <nixos/nixos/modules/installer/cd-dvd/channel.nix>

    # main configuration
    ./configuration.nix
  ];

  sdImage = {
    compressImage = false;
    populateFirmwareCommands = "";
    postBuildCommands = ''
      dd if=${pkgs.ubootLibreTechCC}/u-boot.gxl.sd.bin of=$img conv=fsync,notrunc bs=512 seek=1 skip=1
    '';
  };
  system.copySystemConfiguration = true;
}
