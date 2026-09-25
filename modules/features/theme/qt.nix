{inputs, ...}: {
  flake.nixosModules.qt = {
    config,
    pkgs,
    lib,
    ...
  }: {
    # REPARIERT TERMINAL & MANGO: Setzt die Variable systemweit auf NixOS-Ebene.
    # Das gilt für ALLE Shells, Terminals und WM-Prozesse ab dem Boot.
    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };

    home-manager.users.leo = let
      # Funktion zur dynamischen Generierung der Konfig inklusive des richtigen Pfads
      makeQtctSettings = version: {
        Appearance = {
          ColorScheme = "noctalia";
          custom_palette = true;
          style = "Fusion";
          color_scheme_path = "/home/leo/.config/${version}/colors/noctalia.conf";
        };
        Settings = {
          StandardDialogs = "GTK3";
        };
      };
    in {
      home.packages = with pkgs; [
        kdePackages.qt6ct # Konfigurationswerkzeug für Qt6
        libsForQt5.qt5ct # Konfigurationswerkzeug für Qt5
        kdePackages.qqc2-desktop-style # Essentiell für QML/KColorScheme-Kompatibilität
      ];

      # 1. Native Home-Manager Qt-Steuerung
      qt = {
        enable = true;
        platformTheme.name = "qtct"; # Konfiguriert Qt5 und Qt6 parallel
        style.name = "fusion"; # Erzwingt den Fusion-Stil nativ
      };

      # Erzwingt die Variable auch innerhalb der User-Session (Home-Manager Absicherung)
      home.sessionVariables = {
        QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
      };

      systemd.user.sessionVariables = {
        QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
      };

      # 2. Registrierung der Qt-Templates in Noctalia
      home.file = {
        ".config/noctalia/user-templates.toml".text = lib.mkAfter ''
          [templates.qt6ct]
          input_path = "~/.config/noctalia/templates/noctalia.colors"
          output_path = "~/.config/qt6ct/colors/noctalia.conf"

          [templates.qt5ct]
          input_path = "~/.config/noctalia/templates/noctalia.colors"
          output_path = "~/.config/qt5ct/colors/noctalia.conf"
        '';

        # Registrierung des Dynamic Runtime Hooks für Noctalia unter MangoWM
        ".config/noctalia/config.toml".text = lib.mkAfter ''
          [hooks]
          # Erzwingt das sofortige Neuladen aller Qt-Fenster zur Laufzeit via USR1-Signal
          theme_mode_changed = "pkill -USR1 -f qt6ct || true"
        '';
      };

      # 3. Standard-Auswahl ohne doppelte Sektionen generieren
      xdg.configFile = {
        "qt6ct/qt6ct.conf".text = (lib.generators.toINI {}) (makeQtctSettings "qt6ct");
        "qt5ct/qt5ct.conf".text = (lib.generators.toINI {}) (makeQtctSettings "qt5ct");
      };
    };
  };
}
