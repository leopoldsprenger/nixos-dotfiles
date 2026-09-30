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

    # Built from the repo's own nix/package.nix rather than duplicated here,
    # so it stays in sync with upstream and picks up withGtk4 for free.
    stride-package = pkgs.callPackage "${inputs.stride-src}/nix/package.nix" {
      inherit (cfg) withGtk4;
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

      withGtk4 = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Build with GTK4 support, so `stride --quick-capture` opens a
          small floating GTK4 window instead of falling back to the
          ncurses dialog in a terminal. See the "Quick capture" section
          of the project's README for the mangowm window rule/bind that
          goes with this.
        '';
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

      enableSyncTimer = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Run `stride --sync` automatically on a systemd user timer, every
          `syncInterval`. Set to false to sync manually only (e.g.
          `systemctl --user start stride-sync.service`, or `stride --sync`
          by hand) -- useful if you'd rather control exactly when it
          touches the network.
        '';
      };

      syncInterval = lib.mkOption {
        type = lib.types.str;
        default = "10m";
        description = ''
          How often the systemd user timer runs `stride --sync`, as a
          systemd time span (e.g. "5m", "10min", "1h"). Only takes effect
          when enableSyncTimer is true.
        '';
      };
    };

    config = {
      programs.stride = {
        enable = true;
        withGtk4 = true;
        enableSyncTimer = true;
        mirrorRemote = "git@github.com:leopoldsprenger/stride-data.git";
        mirrorEncryptionKeyFile = config.sops.secrets.stride-data-key.path;
        syncInterval = "10m";
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
          home.packages = [cfg.package];

          # Managed by home-manager activation -- edits here will be overwritten.
          home.activation.setupStrideConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
            mkdir -p "$HOME/.local/share/stride"

            cat <<EOF > "$HOME/.local/share/stride/config"
            mirror_remote=${cfg.mirrorRemote}
            EOF

            KEY_FILE="${toString cfg.mirrorEncryptionKeyFile}"
            if [ -f "$KEY_FILE" ]; then
              echo "mirror_encryption_key=$(cat "$KEY_FILE")" >> "$HOME/.local/share/stride/config"
            fi

            chmod 600 "$HOME/.local/share/stride/config"
          '';

          systemd.user.services.stride-sync = lib.mkIf (pkgs.stdenv.isLinux && cfg.enableSyncTimer) {
            Unit.Description = "Sync Stride's data to its git mirror";
            Service = {
              Type = "oneshot";
              ExecStart = "${cfg.package}/bin/stride --sync";
            };
          };

          systemd.user.timers.stride-sync = lib.mkIf (pkgs.stdenv.isLinux && cfg.enableSyncTimer) {
            Unit.Description = "Periodic trigger for stride-sync.service";
            Timer = {
              OnStartupSec = "2m";
              OnUnitActiveSec = cfg.syncInterval;
              Persistent = true;
            };
            Install.WantedBy = ["timers.target"];
          };
        })
      ];
    };
  };
}
