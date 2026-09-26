{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.stride = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.stride;

    # 1. Das Paket wird inline exakt nach Ihrem Rezept gebaut (Inklusive OpenSSL)
    stride-package = pkgs.callPackage ({
      lib,
      stdenv,
      cmake,
      pkg-config,
      ncurses,
      sqlite,
      openssl,
      git,
      makeWrapper,
    }:
      stdenv.mkDerivation {
        pname = "stride";
        version = "0.1.0";

        # Nutzt das unveränderte Quellcode-Repository aus den Flake-Inputs
        src = inputs.stride-src;

        nativeBuildInputs = [cmake pkg-config makeWrapper];
        buildInputs = [ncurses sqlite openssl];

        postFixup = ''
          wrapProgram "$out/bin/stride" --prefix PATH : "${lib.makeBinPath [git]}"
        '';

        meta = {
          description = "A terminal task manager with a Things-3-inspired TUI and git-mirrored, multi-device storage";
          license = lib.licenses.mit;
          platforms = lib.platforms.unix;
          mainProgram = "stride";
        };
      }) {};
  in {
    # 2. Definition der systemweiten Optionen (NixOS-Ebene)
    options.programs.stride = {
      enable = lib.mkEnableOption "Stride, a terminal task manager";

      package = lib.mkOption {
        type = lib.types.package;
        default = stride-package;
        defaultText = lib.literalExpression "<stride-package>";
        description = "The stride package to install.";
      };

      mirrorRemote = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "git@github.com:you/stride-data.git";
        description = ''
          SSH URL of the git repository Stride mirrors your data to, for
          backup and for syncing between devices.
        '';
      };

      mirrorEncryptionKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to the decrypted sops file containing the encryption key.";
      };

      syncInterval = lib.mkOption {
        type = lib.types.str;
        default = "10m";
        description = ''
          How often the systemd user timer runs `stride --sync`, as a
          systemd time span (e.g. "5m", "10min", "1h").
        '';
      };
    };

    # 3. Logik und DEKLARATION an einem Ort
    config = {
      # --- HIER FINDET DIE KONFIGURATION STATT ---
      programs.stride = {
        enable = true;
        mirrorRemote = "git@github.com:leopoldsprenger/stride-data.git";
        mirrorEncryptionKeyFile = config.sops.secrets.stride-data-key.path;
        syncInterval = "10m";
      };

      # Registriert das sops-Geheimnis mit echtem absolute-path-Typ aus ${self}
      sops.secrets.stride-data-key = {
        sopsFile = "${self}/resources/secrets/stride.yaml"; # <-- Remove the \ here
        key = "mirror_encryption_key";
        owner = "leo";
      };

      # Klinkt sich nahtlos in Home-Manager für alle User ein, wenn enable aktiv ist
      home-manager.sharedModules = lib.mkIf cfg.enable [
        ({
          config, # Das ist die Home-Manager-Konfiguration des Users
          pkgs,
          lib, # Das innere lib-Argument enthält die Home-Manager-Erweiterungen (lib.hm)
          ...
        }: {
          # Installiert das generierte Paket im User-Profil
          home.packages = [cfg.package];

          # ERZEUGT DIE STRIDE KONFIGURATIONSDATEI VIA SCRIPT (Verhindert Nix-Store-Leaks)
          home.activation.setupStrideConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
                        mkdir -p "$HOME/.local/share/stride"

                        # Basis-Konfiguration generieren
                        cat <<EOF > "$HOME/.local/share/stride/config"
            # Managed by home-manager activation script -- edits here will be overwritten.
            mirror_remote=${cfg.mirrorRemote}
            EOF

                        # Hängt den geheimen Schlüssel aus dem sops-Verzeichnis sicher an, falls vorhanden
                        KEY_FILE="${toString cfg.mirrorEncryptionKeyFile}"
                        if [ -f "$KEY_FILE" ]; then
                          SECRET_KEY=$(cat "$KEY_FILE")
                          echo "mirror_encryption_key=$SECRET_KEY" >> "$HOME/.local/share/stride/config"
                        fi

                        chmod 600 "$HOME/.local/share/stride/config"
          '';

          # Erstellt den systemd-Dienst für den automatischen Sync im Hintergrund
          systemd.user.services.stride-sync = lib.mkIf pkgs.stdenv.isLinux {
            Unit = {
              Description = "Sync Stride's data to its git mirror";
            };
            Service = {
              Type = "oneshot";
              ExecStart = "\${cfg.package}/bin/stride --sync";
            };
          };

          # Startet den Dienst im definierten Intervall
          systemd.user.timers.stride-sync = lib.mkIf pkgs.stdenv.isLinux {
            Unit = {
              Description = "Periodic trigger for stride-sync.service";
            };
            Timer = {
              OnStartupSec = "2m";
              OnUnitActiveSec = cfg.syncInterval;
              Persistent = true;
            };
            Install = {
              WantedBy = ["timers.target"];
            };
          };
        })
      ];
    };
  };
}
