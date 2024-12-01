{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
  let
    lib = import ./lib { inherit inputs; };
    inherit (lib) forAllSystems mapHomes mkSystem;

    overlay = final: _prev: import ./pkgs { pkgs = final; };

    legacyPackages = forAllSystems (system:
      import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      }
    );
  in
  {
    inherit legacyPackages;

    nixosConfigurations = let
      system = "x86_64-linux";
      pkgs = legacyPackages.${system};
    in
    {
      boson = mkSystem { hostname = "boson"; users = [ "jamiez" ]; inherit pkgs; };
      neutrino = mkSystem { hostname = "neutrino"; users = [ "jamiez" ]; inherit pkgs; };
    };

    homeConfigurations = mapHomes;

    devShells = forAllSystems (system:
      import ./shells { pkgs = legacyPackages.${system}; }
    );

    packages = forAllSystems (system:
      import ./pkgs { pkgs = legacyPackages.${system}; }
    );

    images.lepotato = let
      nixosConf = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          (
            { config, lib, pkgs, ... }: {
              imports = [
                "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
              ];
              sdImage = {
                compressImage = false;
                populateFirmwareCommands = "";
                postBuildCommands = ''
                  dd if=${pkgs.ubootLibreTechCC}/u-boot.gxl.sd.bin of=$img conv=fsync,notrunc bs=512 seek=1 skip=1
                  dd if=${pkgs.ubootLibreTechCC}/u-boot.gxl.sd.bin of=$img conv=fsync,notrunc bs=1 count=444
                '';
              };
              nixpkgs = {
                config.allowUnfree = true;
                localSystem.system = "x86_64-linux";
                crossSystem.system = "aarch64-linux";
              };
              system.stateVersion = "22.05";
            }
          )
        ];
      };
    in nixosConf.config.system.build.sdImage;
  };
}