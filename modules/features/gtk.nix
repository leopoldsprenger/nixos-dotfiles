{inputs, ...}: {
  flake.nixosModules.gtk = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home-manager.users.leo = {
      home.packages = with pkgs; [
        adw-gtk3
        nwg-look
      ];

      home.file = {
        # Lokale User-Templates für Noctalia registrieren
        ".config/noctalia/user-templates.toml".text = lib.mkAfter ''
          [templates.gtk3]
          input_path = "/usr/share/noctalia/assets/templates/gtk/noctalia.css"
          output_path = "~/.config/gtk-3.0/noctalia.css"
          post_hook = "bash /usr/share/noctalia/assets/templates/gtk/apply.sh dark"

          [templates.gtk4]
          input_path = "/usr/share/noctalia/assets/templates/gtk/noctalia.css"
          output_path = "~/.config/gtk-4.0/noctalia.css"
          post_hook = "bash /usr/share/noctalia/assets/templates/gtk/apply.sh dark"
        '';

        # FÜR GTK3 (Klassische Apps wie galculator):
        # adw-gtk3 benötigt den Import im übergeordneten Theme-Ordner, um CSS-Variablen korrekt anzuwenden
        ".config/gtk-3.0/gtk.css".text = ''
          @import url("noctalia.css");

          /* Fix für ältere GTK3-Apps, die Farb-Klassen ignorieren */
          @import url("${pkgs.adw-gtk3}/share/themes/adw-gtk3-dark/gtk-3.0/gtk.css");
        '';

        # FÜR GTK4 (Moderne Apps wie Baobab):
        ".config/gtk-4.0/gtk.css".text = ''
          @import url("noctalia.css");
        '';
      };

      # Native Home-Manager Verwaltung für GTK nutzen statt reinem dconf
      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "adw-gtk3-dark";
          color-scheme = "prefer-dark";
        };
      };
    };
  };
}
