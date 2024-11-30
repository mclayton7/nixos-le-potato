# save as sd-image.nix somewhere
{ ... }: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
  ];
  sdImage = {
    compressImage = false;
    populateFirmwareCommands = "";
    postBuildCommands = ''
      dd if=${pkgs.ubootLibreTechCC}/u-boot.gxl.sd.bin of=$img conv=fsync,notrunc bs=512 seek=1 skip=1
    '';
  };
  nixpkgs = {
    config.allowUnfree = true;
    localSystem.system = "x86_64-linux";
    crossSystem.system = "aarch64-linux";
  };
  system.stateVersion = "22.05";
}
