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

    # Use the repository's own package definition so it stays in sync
    # with upstream.
    stride-package = pkgs.callPackage "${inputs.stride-src}/nix/package.nix" {
      withGtk4 = true;
    };

    finalPackage =
      if
        cfg.interface
        == "tui"
        && cfg.gui.theme == "auto"
        && cfg.gui.accent == null
        && !cfg.gui.decorations
      then cfg.package
      else
        cfg.package.override {
          defaultInterface = cfg.interface;
          guiTheme = cfg.gui.theme;
          guiAccent = cfg.gui.accent;
          guiDecorations = cfg.gui.decorations;
        };

    syncFlag =
      {
        both = "--sync";
        pull = "--pull";
        push = "--push";
      }.${
        cfg.syncDirection
      };
  in {
    options.programs.stride = {
      enable = lib.mkEnableOption "Stride, a terminal task manager";

      package = lib.mkOption {
        type = lib.types.package;
        default = stride-package;
        defaultText = lib.literalExpression "<stride-package>";
        description = "The stride package to install.";
      };

      interface = lib.mkOption {
        type = lib.types.enum ["tui" "gui"];
        default = "tui";
        example = "gui";
        description = ''
          Which front end a bare `stride` opens: the terminal app ("tui")
          or the GTK4 app ("gui").
        '';
      };

      gui = {
        theme = lib.mkOption {
          type = lib.types.enum ["auto" "light" "dark"];
          default = "auto";
          description = "GUI colour scheme.";
        };

        accent = lib.mkOption {
          type = lib.types.nullOr (lib.types.strMatching "#[0-9a-fA-F]{6}");
          default = null;
          example = "#bb9af7";
          description = "Accent colour for check marks and selection.";
        };

        decorations = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether the GUI window asks for a titlebar.";
        };
      };

      mirrorRemote = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "git@github.com:you/stride-data.git";
        description = ''
          SSH URL of the git repository Stride mirrors your data to,
          for backup and syncing between devices.
        '';
      };

      mirrorEncryptionKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to the decrypted sops file containing the Stride
          mirror encryption key.
        '';
      };

      enableSyncTimer = lib.mkOption {
        type = lib.types.bool;
        default = cfg.mirrorRemote != null;
        defaultText = lib.literalExpression "mirrorRemote != null";
        description = ''
          Whether to install the systemd user timer that periodically
          runs Stride synchronization.
        '';
      };

      syncInterval = lib.mkOption {
        type = lib.types.str;
        default = "10m";
        description = ''
          How often the systemd user timer runs Stride synchronization.
        '';
      };

      syncDirection = lib.mkOption {
        type = lib.types.enum ["both" "pull" "push"];
        default = "both";
        description = ''
          What the periodic timer does:
          "both" pulls remote changes and then pushes local changes,
          "pull" only pulls, and "push" only pushes.
        '';
      };
    };

    config = {
      programs.stride = {
        enable = true;
        package = stride-package;

        interface = "gui";

        gui = {
          theme = "auto";
          accent = null;
          decorations = false;
        };

        mirrorRemote = "git@github.com:leopoldsprenger/stride-data.git";
        mirrorEncryptionKeyFile = config.sops.secrets.stride-data-key.path;

        enableSyncTimer = true;
        syncInterval = "10m";
        syncDirection = "both";
      };

      sops.secrets.stride-data-key = {
        sopsFile = "${self}/resources/secrets/stride.yaml";
        key = "mirror_encryption_key";
        owner = "leo";
      };

      home-manager.sharedModules = lib.mkIf cfg.enable [
        ({
          config,
          pkgs,
          lib,
          ...
        }: {
          home.packages = [finalPackage];

          # Managed by home-manager activation.
          home.activation.setupStrideConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
            mkdir -p "$HOME/.local/share/stride"

            cat <<EOF > "$HOME/.local/share/stride/config"
            # Managed by home-manager (programs.stride) -- edits here will be overwritten.
            mirror_remote=${cfg.mirrorRemote}
            EOF

            KEY_FILE="${toString cfg.mirrorEncryptionKeyFile}"

            if [ -f "$KEY_FILE" ]; then
              KEY="$(cat "$KEY_FILE")"

              if ! printf '%s' "$KEY" | grep -Eq '^[0-9a-fA-F]{64}$'; then
                echo "error: Stride encryption key must be exactly 64 hexadecimal characters" >&2
                exit 1
              fi

              printf 'mirror_encryption_key=%s\n' "$KEY" \
                >> "$HOME/.local/share/stride/config"
            fi

            chmod 600 "$HOME/.local/share/stride/config"
          '';

          systemd.user.services.stride-sync =
            lib.mkIf (
              pkgs.stdenv.hostPlatform.isLinux
              && cfg.enableSyncTimer
              && cfg.mirrorRemote != null
            ) {
              Unit.Description = "Sync Stride's data to its git mirror";

              Service = {
                Type = "oneshot";
                ExecStart = "${finalPackage}/bin/stride ${syncFlag}";
              };
            };

          systemd.user.timers.stride-sync =
            lib.mkIf (
              pkgs.stdenv.hostPlatform.isLinux
              && cfg.enableSyncTimer
              && cfg.mirrorRemote != null
            ) {
              Unit.Description = "Periodic trigger for stride-sync.service";

              Timer = {
                OnStartupSec = "2m";
                OnUnitActiveSec = cfg.syncInterval;
                Persistent = true;
              };

              Install.WantedBy = ["timers.target"];
            };

          systemd.user.startServices = lib.mkDefault "sd-switch";
        })
      ];
    };
  };
}
