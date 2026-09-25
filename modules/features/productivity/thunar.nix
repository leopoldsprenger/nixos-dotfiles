{...}: {
  flake.nixosModules.thunar = {pkgs, ...}: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    services.gvfs.enable = true;
    services.tumbler.enable = true;
    environment.pathsToLink = ["/share/icons"];

    home-manager.users.leo = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs; [
        papirus-icon-theme
        papirus-folders
      ];

      xdg.configFile."gtk-3.0/bookmarks".text = ''
        file:///home/leo/Downloads Downloads
        file:///home/leo/projects Projects
      '';

      gtk = {
        enable = true;
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
      };

      # Noctalia v5 *user templates* live in [theme.templates.user.<id>] inside
      # any *.toml under ~/.config/noctalia/ (all such files are merged
      # alphabetically -- this is the documented, dotfiles-friendly way to add
      # one, distinct from the old v4 `user-templates.toml` / [templates.*]
      # schema, which v5 never reads). Relative input_path/output_path resolve
      # against ~/.config/noctalia; for a user template {{ config_dir }} in
      # post_hook is also ~/.config/noctalia -- hence the full relative path
      # below rather than a bare "apply.sh".
      xdg.configFile."noctalia/papirus-icons-user-template.toml".text = ''
        [theme.templates.user.papirus-icons]
        input_path = "templates/papirus-icons/colors"
        output_path = "templates/papirus-icons/colors-final"
        post_hook = "bash '{{ config_dir }}/templates/papirus-icons/apply.sh'"
      '';

      # The input template: just the live accent hex. apply.sh below carries
      # its own closest-color table, so nothing else needs to be in here.
      xdg.configFile."noctalia/templates/papirus-icons/colors".text = ''
        {{ colors.source_color.default.hex }}
      '';

      # Runs on every theme change once Noctalia writes a new colors-final.
      xdg.configFile."noctalia/templates/papirus-icons/apply.sh" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          export PATH="${pkgs.papirus-folders}/bin:${pkgs.gtk3}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:$PATH"

          LIVE_COLORS="/home/leo/.config/noctalia/templates/papirus-icons/colors-final"
          HEX_COLOR=$(grep -oE '#[0-9a-fA-F]{6}' "$LIVE_COLORS" 2>/dev/null | head -n 1 || true)
          [ -z "$HEX_COLOR" ] && HEX_COLOR="#ee923a" # orange fallback

          hex_to_rgb() {
            local hex="''${1#\#}"
            echo "$((16#''${hex:0:2})) $((16#''${hex:2:2})) $((16#''${hex:4:2}))"
          }
          read -r r1 g1 b1 <<< "$(hex_to_rgb "$HEX_COLOR")"

          COLORS_LIST=(
            "adwaita:#93c0ea" "black:#4f4f4f" "blue:#5294e2" "bluegrey:#607d8b"
            "breeze:#57b8ec" "brown:#ae8e6c" "carmine:#a30002" "cyan:#00bcd4"
            "darkcyan:#45abb7" "deeporange:#eb6637" "green:#87b158" "grey:#8e8e8f"
            "indigo:#5c6bc0" "magenta:#ca71df" "nordic:#81a1c1" "orange:#ee923a"
            "palebrown:#d1bfae" "paleorange:#eeca8f" "pink:#f06292" "red:#e25252"
            "teal:#16a085" "violet:#7e57c2" "white:#e4e4e4" "yaru:#676767" "yellow:#f9bd30"
          )
          MIN_DIST=999999
          MATCHING_COLOR="orange"
          for item in "''${COLORS_LIST[@]}"; do
            color_name="''${item%%:*}"
            color_hex="''${item#*:}"
            read -r r2 g2 b2 <<< "$(hex_to_rgb "$color_hex")"
            DIST=$(( (r1 - r2)**2 + (g1 - g2)**2 + (b1 - b2)**2 ))
            if [ "$DIST" -lt "$MIN_DIST" ]; then
              MIN_DIST=$DIST
              MATCHING_COLOR="$color_name"
            fi
          done

          echo "Noctalia Hex $HEX_COLOR mapped to Papirus-Dark variant: $MATCHING_COLOR"
          papirus-folders -C "$MATCHING_COLOR" --theme Papirus-Dark
          gtk-update-icon-cache -f -t "/home/leo/.local/share/icons/Papirus-Dark" || true
        '';
      };

      # papirus-folders ln -sf's inside the theme dir on every color change --
      # impossible against the read-only Nix store, and upstream's own bootstrap
      # only knows /usr/share/icons (doesn't exist on NixOS). Seed a real
      # writable copy once; everything after this is mutated live, not by Nix.
      home.activation.seedWritablePapirusDark = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ICON_DIR="/home/leo/.local/share/icons/Papirus-Dark"
        if [ ! -d "$ICON_DIR" ] || [ -L "$ICON_DIR" ]; then
          rm -rf "$ICON_DIR"
          mkdir -p "/home/leo/.local/share/icons"
          cp -r "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark" "$ICON_DIR"
          chmod -R u+w "$ICON_DIR"
        fi
      '';
    };
  };
}
