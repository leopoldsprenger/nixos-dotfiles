{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.noctalia = {pkgs, ...}: {
    services.upower.enable = true;
    hardware.bluetooth.enable = true;
    networking.networkmanager.enable = true;

    environment.systemPackages = [
      (inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = builtins.fromTOML (builtins.readFile ./noctalia.toml);
      })
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
    packages.default = inputs.noctalia.packages.${system}.default;
  };
}
