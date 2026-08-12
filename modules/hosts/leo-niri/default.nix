{ self, inputs, ... }:
{
  flake.nixosConfigurations.leo-niri = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.leo-niri-configuration
    ];
  };
}
