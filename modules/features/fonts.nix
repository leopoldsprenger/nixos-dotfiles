{ inputs, ... }: {
  flake.nixosModules.fonts = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.modules.fonts.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable custom fonts (JetBrains Mono Nerd Font) for user leo.";
    };

    config = lib.mkIf config.modules.fonts.enable {
      # Targetiert gezielt nur das Home-Manager-Profil des Nutzers 'leo'
      home-manager.users.leo = {
        # Installiert die JetBrains Mono Nerd Font im User-Profil
        home.packages = [
          pkgs.nerd-fonts.jetbrains-mono
        ];

        # Aktiviert das automatische Entdecken von Schriftarten im Home-Manager
        fonts.fontconfig.enable = true;
      };
    };
  };
}

