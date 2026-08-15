{inputs, ...}: {
  flake.nixosModules.home-manager = {
    imports = [inputs.home-manager.nixosModules.home-manager];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";

    home-manager.users.leo = {
      # TODO: maybe change this once on bare metal
      dconf.enable = true;
      home.stateVersion = "26.05";
    };
  };
}
