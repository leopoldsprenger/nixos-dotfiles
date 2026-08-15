{ self, inputs, ... }: {
  flake.nixosModules.noctalia = 
    { pkgs, ... }: {
      # Noctalia v5 Hardware-Abhängigkeiten im System aktivieren
      services.upower.enable = true;
      hardware.bluetooth.enable = true;
      networking.networkmanager.enable = true;

      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaConfig
      ];
    };

  perSystem =
    { pkgs, system, ... }: {
      packages.noctaliaConfig = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;

        # Zwingt den Wrapper, die neue v5 Binary aus deinem Flake-Input zu nutzen
        package = inputs.noctalia.packages.${system}.default;

        # wrapper-modules übersetzt dieses Nix-Attributset automatisch in die korrekte TOML-Struktur
        settings = builtins.fromTOML (builtins.readFile ./noctalia.toml);
      };
    };
}

