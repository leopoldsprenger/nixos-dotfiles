{self, ...}: {
  flake.nixosModules.ly = {
    config,
    pkgs,
    ...
  }: {
    # 1. Keep Xserver enabled to preserve your correct screen resolution
    services.xserver.enable = true;
    services.greetd.enable = false;

    # 2. Inject systemd modifications to replace the TTY backdrop with dark charcoal gray
    systemd.services.display-manager = {
      # \e]P01E1E2E defines color0 (Background) -> #1E1E2E (Catppuccin Mocha Dark Charcoal/Gray)
      # \e]P7CDD6F4 defines color7 (Foreground Text) -> #CDD6F4 (Soft Light Lavender/White)
      # \ec clears the screen and commits the visual styles
      serviceConfig.ExecStartPre = [
        "${pkgs.coreutils}/bin/printf '\\e]P01E1E2E\\e]P7CDD6F4\\ec'"
      ];
    };

    # 3. Configure Ly settings for a clean layout and background state persistence
    services.displayManager = {
      ly = {
        enable = true;
        settings = {
          vi_mode = true;
          vi_default_mode = "normal";

          # --- UI CLEANUP ---
          hide_key_hints = true; # Hides hotkey footnotes at the base
          initial_info_text = ""; # Empties the top banner lines
          box_title = ""; # Strips away box title decorations
          animate = false; # Removes performance animations

          # --- COLOR & PERSISTENCE ---
          # Ensures that logging out doesn't wipe your custom charcoal color environment
          term_reset_cmd = "${pkgs.coreutils}/bin/printf '\\e]P01E1E2E\\e]P7CDD6F4\\ec'";
        };
      };

      # 4. Build the file package and satisfy the NixOS type checker for MangoWM
      sessionPackages = [
        ((pkgs.runCommand "mango-custom-session" {} ''
            mkdir -p $out/share/wayland-sessions
            cat << 'EOF' > $out/share/wayland-sessions/mango.desktop
            [Desktop Entry]
            Name=Mango
            Comment=Launch MangoWM
            Exec=${config.programs.mango.package}/bin/mango -c /etc/mango/config.conf
            Type=Application
            EOF
          '')
          // {providedSessions = ["mango"];})
      ];
    };

    programs.mango.addLoginEntry = false;
  };
}
