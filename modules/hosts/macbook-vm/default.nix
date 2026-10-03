{
  self,
  inputs,
  ...
}: let
  hostModule = {
    imports = [
      self.nixosModules.common
      self.nixosModules.macbookDisplay
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
    nixosModules.macbook-vm = hostModule;

    nixosConfigurations.macbook-vm = inputs.nixpkgs.lib.nixosSystem {
      modules = [hostModule];
    };
  };
}
