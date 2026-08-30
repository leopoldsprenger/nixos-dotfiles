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
      self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaConfig
    ];

    home-manager.users.leo = {config, ...}: {
      home.file.".local/state/noctalia/settings.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/features/noctalia.toml";
    };
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages.noctaliaConfig = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;

      package = inputs.noctalia.packages.${system}.default;
      settings = builtins.fromTOML (builtins.readFile ./noctalia.toml);
    };
  };
}
