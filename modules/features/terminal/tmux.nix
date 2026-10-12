{...}: {
  flake.nixosModules.tmux = {
    home-manager.users.leo.programs.tmux = {
      enable = true;

      clock24 = true;
      keyMode = "vi";
      mouse = true;
      newSession = true;
      terminal = "tmux-256color";
      baseIndex = 1;

      shortcut = "b";

      extraConfig = ''
        # bar position
        set -g status-position bottom
        set -g status-justify left

        # set absolute transparency terminal overrides
        set -as terminal-overrides ",*:Setulc=\\E[58::2::%%p1%%d::%%p2%%d::%%p3%%d::m"

        # initial baseline configuration on boot
        if-shell "test -f ~/.config/tmux/themes/noctalia.conf" "source-file ~/.config/tmux/themes/noctalia.conf"
        set -g status-style "bg=terminal,fg=#{@noctalia_on_surface}"
        set -g status-left ""
        set -g status-right ""

        # dynamic reload
        set-hook -g client-attached {
          if-shell "test -f ~/.config/tmux/themes/noctalia.conf" "source-file ~/.config/tmux/themes/noctalia.conf"
          set -g status-style "bg=terminal,fg=#{@noctalia_on_surface}"
          set -g status-left ""
          set -g status-right ""
          refresh-client -S
        }

        # window pill colors
        setw -g window-status-format "#[fg=#{@noctalia_surface_container_highest},bg=terminal]#[fg=#{@noctalia_on_surface_variant},bg=#{@noctalia_surface_container_highest}]#I:#W#[fg=#{@noctalia_surface_container_highest},bg=terminal] "
        setw -g window-status-current-format "#[fg=#{@noctalia_primary},bg=terminal]#[fg=#{@noctalia_on_primary},bg=#{@noctalia_primary},bold]#I:#W#[fg=#{@noctalia_primary},bg=terminal] "

        # binds
        bind -n C-Left select-pane -L
        bind -n C-Right select-pane -R
        bind -n C-Up select-pane -U
        bind -n C-Down select-pane -D
      '';
    };
  };
}
