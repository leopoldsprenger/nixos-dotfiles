{ ... }: {
  flake.nixosModules.kitty = {
    home-manager.users.leo.programs.kitty = {
      enable = true;
      
      settings = {
        # Fonts
        font_family      = "JetBrains Mono";
        bold_font        = "auto";
        italic_font      = "auto";
        bold_italic_font = "auto";
        font_size        = "11.0";
        line_height      = "1.3";

        # Cursor
        cursor                 = "#81a1c1";
        cursor_text_color      = "#1e1e30";
        cursor_shape           = "block";
        cursor_beam_thickness  = "1.5";
        cursor_blink_interval  = "0.5";

        # Window and tab appearance
        window_padding_width    = 0;
        window_margin_width     = 0;
        tab_bar_edge            = "bottom";
        tab_bar_style           = "fade";
        tab_fade                = "0.3 0.6 0.8";
        active_tab_background   = "#81a1c1";
        active_tab_foreground   = "#1e1e30";
        inactive_tab_background = "#262639";
        inactive_tab_foreground = "#9099a8";
        tab_title_template      = "{index}:{title}";
        hide_window_decorations = "yes";

        # Performance
        sync_to_monitor      = true;
        enable_audio_bell    = false;
        visual_bell_duration = "0.1";

        # Advanced
        allow_hyperlinks  = true;
        shell_integration = "enabled";
        clipboard_control = "write-clipboard read-clipboard write-primary read-primary";
      };
    };
  };
}
