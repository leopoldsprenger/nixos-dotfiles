{inputs, ...}: {
  flake.nixosModules.shell = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.modules.shell.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable custom Zsh and shell environment configuration.";
    };

    config = lib.mkIf config.modules.shell.enable {
      environment.systemPackages = with pkgs; [
        eza
        bat
        fzf
        zsh-fzf-tab
        oh-my-posh
      ];

      # Set Zsh as the default login shell for all users
      users.defaultUserShell = pkgs.zsh;

      # Enable zoxide with automatic Zsh shell integration
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;

        shellInit = "zsh-newuser-install() { :; }";

        histSize = 5000;
        histFile = "$HOME/.zsh_history";

        shellAliases = {
          ls = "eza --icons=auto --group-directories-first";
          ll = "eza -lah --icons=auto --group-directories-first";
          cat = "bat";
        };

        interactiveShellInit = ''
          path=("$HOME/.local/bin" "$HOME/bin" $path)

          export UV_PYTHON_PREFERENCE=only-system

          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

          setopt HIST_IGNORE_ALL_DUPS
          setopt HIST_IGNORE_SPACE
          setopt SHARE_HISTORY

          bindkey -e
          bindkey '^p' history-search-backward
          bindkey '^n' history-search-forward

          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:complete:(cd|__zoxide_z):*' fzf-preview 'eza --icons --tree --level=2 $realpath'

          eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${pkgs.writeText "ohmyposh.toml" ''
            version = 4
            enable_cursor_positioning = true
            final_space = true
            console_title_template = '{{ .Shell }} in {{ .Folder }}'

            [palette]
              blue = '#82aaff'
              cyan = '#7dcfff'
              grey = '#636da6'
              magenta = '#c099ff'
              red = '#ff757f'

            [[blocks]]
              type = 'prompt'
              alignment = 'left'

              [[blocks.segments]]
                type = 'path'
                style = 'plain'
                background = 'transparent'
                foreground = 'p:blue'
                template = '{{ .Folder }}'

                [blocks.segments.properties]
                  style = 'folder'

              [[blocks.segments]]
                type = 'git'
                style = 'plain'
                foreground = 'p:grey'
                background = 'transparent'
                template = ' git:(<p:cyan>{{ .HEAD }}</>){{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }}{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}'

                [blocks.segments.properties]
                  branch_icon = ""
                  commit_icon = "@"
                  fetch_status = true

              [[blocks.segments]]
                type = 'text'
                style = 'plain'
                foreground_templates = [
                  "{{if gt .Code 0}}p:red{{end}}",
                  "{{if eq .Code 0}}p:magenta{{end}}",
                ]
                background = 'transparent'
                template = ' >'

            [[blocks]]
              type = 'rprompt'
              overflow = 'hidden'

              [[blocks.segments]]
                type = 'executiontime'
                style = 'plain'
                foreground = 'yellow'
                background = 'transparent'
                template = '{{ .FormattedMs }}'

                [blocks.segments.properties]
                  threshold = 5000

            [secondary_prompt]
              foreground = 'p:magenta'
              background = 'transparent'
              template = ' >> '
          ''})"
        '';
      };
    };
  };
}
