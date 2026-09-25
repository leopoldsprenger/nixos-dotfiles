{inputs, ...}: {
  flake.nixosModules.terminal-apps = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.modules.terminal-apps.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable terminal tools (yazi and btop) for user leo.";
    };

    config = lib.mkIf config.modules.terminal-apps.enable {
      home-manager.users.leo = {
        programs.yazi = {
          enable = true;
          enableZshIntegration = true;
          settings = {
            theme = {
              flavor = "noctalia";
            };
          };
        };

        programs.btop = {
          enable = true;
          settings = {
            theme_background = false;
            color_theme = "/home/leo/.config/btop/themes/noctalia.theme";
          };
        };

        programs.fastfetch = {
          enable = true;
          settings = {
            include = ["themes/noctalia.jsonc"];

            # This is the exact out-of-the-box default module profile
            modules = [
              "title"
              "separator"
              "os"
              "host"
              "kernel"
              "uptime"
              "packages"
              "shell"
              "display"
              "de"
              "wm"
              "wmtheme"
              "theme"
              "icons"
              "font"
              "cursor"
              "terminal"
              "terminalfont"
              "cpu"
              "gpu"
              "memory"
              "swap"
              "disk"
              "localip"
              "battery"
              "poweradapter"
              "locale"
              "break"
              "colors"
            ];
          };
        };
      };
    };
  };
}
