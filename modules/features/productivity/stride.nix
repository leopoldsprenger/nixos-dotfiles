{inputs, ...}: {
  flake.nixosModules.stride = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.programs.stride;

    # 1. Das Paket wird inline exakt nach Ihrem Rezept gebaut
    stride-package = pkgs.callPackage ({
      lib,
      stdenv,
      cmake,
      pkg-config,
      ncurses,
      sqlite,
      git,
      makeWrapper,
    }:
      stdenv.mkDerivation {
        pname = "stride";
        version = "0.1.0";

        # Nutzt das unveränderte Quellcode-Repository aus den Flake-Inputs
        src = inputs.stride-src;

        nativeBuildInputs = [cmake pkg-config makeWrapper];
        buildInputs = [ncurses sqlite];

        # Fügt Git zur Laufzeit der PATH-Umgebung hinzu
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
        syncInterval = "10m";
      };

      # Klinkt sich nahtlos in Home-Manager für alle User ein, wenn enable aktiv ist
      home-manager.sharedModules = lib.mkIf cfg.enable [
        ({
          config,
          pkgs,
          ...
        }: {
          # Installiert das generierte Paket im User-Profil
          home.packages = [cfg.package];

          # ERZEUGT DIE STRIDE KONFIGURATIONSDATEI (Verhindert den Prompt!)
          home.file.".local/share/stride/config".text = lib.mkIf (cfg.mirrorRemote != null) ''
            # Managed by home-manager (programs.stride.mirrorRemote) -- edits here will be overwritten.
            mirror_remote=${cfg.mirrorRemote}
          '';

          # Erstellt den systemd-Dienst für den automatischen Sync im Hintergrund
          systemd.user.services.stride-sync = lib.mkIf pkgs.stdenv.isLinux {
            Unit = {
              Description = "Sync Stride's data to its git mirror";
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${cfg.package}/bin/stride --sync";
            };
          };

          # Startet den Dienst im definierten Intervall (Korrigierte Syntax)
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
