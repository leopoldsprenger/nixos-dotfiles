{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.leoNiri;
    };
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.leoNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        # Startet die Noctalia-Shell direkt beim Booten
        spawn-at-startup = [
          (lib.getExe self'.packages.noctaliaConfig)
        ];

        prefer-no-csd = true;

        hotkey-overlay = {
          skip-at-startup = true;
        };

        # Ermöglicht X11-Apps die Ausführung unter Wayland via Xwayland-Satellite
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        # Visuelles Layout für ein sauberes Desktop-Gefühl
        layout = {
          gaps = 6; # Leicht vergrößerte Abstände für einen luftigeren Look

          # Schmale, moderne Fensterrahmen passend zur Noctalia-Ästhetik
          border = {
            width = 2;
            active-color = "#74c7ecb3"; # Transluzentes Pastellblau (z. B. Catppuccin-Stil)
            inactive-color = "#31324466"; # Stark transparente, dunkle Inaktivitätsgrenze
          };

          # Verhindert, dass Rahmen hinter transparenten Fenstern durchscheinen
          focus-ring.off = {};
        };

        # Tastenkombinationen
        binds = {
          # TODO: remove flag once on bare metal
          "Mod+Q".spawn-sh = "env LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty}";
          "Mod+W".close-window = {};
          "Mod+Shift+E".quit = {};
          "Mod+Space".spawn-sh = "${lib.getExe self'.packages.noctaliaConfig} ipc call launcher toggle";
          "Mod+B".spawn-sh = "${lib.getExe pkgs.firefox}";
        };

        # Globale Fensterregeln (Wichtig: Als Liste definiert)
        window-rules = [
          {
            matches = [{}]; # Trifft auf alle Fenster zu
            opacity = 0.93; # Leicht verringerte Transparenz für bessere Lesbarkeit

            # Erzwingt perfekt gerundete Fensterecken passend zur Shell
            geometry-corner-radius = 12;
            clip-to-geometry = true;
          }
        ];

        # Monitor-Einstellungen
        outputs = {
          "Virtual-1" = {
            mode = "3840x2160@60.000";
            scale = 1.8;
          };

          "Unknown-1" = {off = {};};
        };

        input = {
          keyboard = {
            repeat-delay = 200;
            repeat-rate = 35;
          };
          focus-follows-mouse = {};
        };
      };
    };
  };
}
