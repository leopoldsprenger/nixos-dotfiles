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

      programs.bat = {
        enable = true;
        settings = {
          theme = "ansi";
          style = "numbers,changes,header";
        };
      };

      programs.starship = {
        enable = true;

        # Standard layout configuration structure with color attributes removed
        settings = {
          # Fixes the empty top line / newline issue
          add_newline = false;

          # Exact layout configuration sequence
          format = "$directory$git_branch$git_status$character";
          right_format = "$cmd_duration";

          directory = {
            truncation_length = 1;
            fish_style_pwd_dir_length = 0;
            format = "[$path]($style)";
          };

          git_branch = {
            format = " git:\\([$symbol$branch](cyan)\\)";
            symbol = "";
          };

          git_status = {
            format = "([$all_status$ahead_behind]($style))";
            conflicted = "=";
            ahead = "⇡";
            behind = "⇣";
            diverged = "⇕";
            untracked = "";
            stashed = "";
            modified = "*";
            staged = "*";
            renamed = "";
            deleted = "";
          };

          character = {
            success_symbol = "[ ❯](bold green)";
            error_symbol = "[ ❯](bold red)";
          };

          continuation_prompt = "[ ❯❯ ](bold green)";

          cmd_duration = {
            min_time = 5000;
            format = "[$duration](yellow)";
          };
        };
      };

      # Your Cleaned Zsh Shell Module
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;

        shellInit = "zsh-newuser-install() { :; }";

        histSize = 5000;
        histFile = "/home/leo/.zsh_history";

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

          # Standard healthy directory workspace mapping for session states
          export STARSHIP_CACHE="$HOME/.cache/starship"

          # Native profile invocation path matching Nix configurations
          export STARSHIP_CONFIG="/etc/xdg/starship.toml"

          # Initialize the Starship prompt shell hook natively
          eval "$(starship init zsh)"
        '';
      };
    };
  };
}
