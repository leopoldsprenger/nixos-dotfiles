{
  self,
  inputs,
  ...
}: let
  hostModule = {
    imports = [
      self.nixosModules.common
      self.nixosModules.macminiDisplay
      ./hardware-configuration.nix
    ];

    networking.hostName = "macbook-vm";
    networking.networkmanager.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  };
in {
  flake = {
    nixosModules.macmini-vm = hostModule;

    nixosConfigurations.macmini-vm = inputs.nixpkgs.lib.nixosSystem {
      modules = [hostModule];
    };
  };
}
