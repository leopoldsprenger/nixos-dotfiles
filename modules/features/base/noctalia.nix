{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.noctalia = {pkgs, ...}: {
    services.upower.enable = true;
    hardware.bluetooth.enable = true;
    networking.networkmanager.enable = true;

    # Reference the package from self.packages using the host platform
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaConfig
    ];

    home-manager.users.leo = {...}: {
      xdg.configFile."noctalia/settings.toml".source = ./noctalia.toml;
    };
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # Define it here so mango.nix and other modules can find it
    packages.noctaliaConfig = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      package = inputs.noctalia.packages.${system}.default;
      settings = builtins.fromTOML (builtins.readFile ./noctalia.toml);
    };
  };
}
