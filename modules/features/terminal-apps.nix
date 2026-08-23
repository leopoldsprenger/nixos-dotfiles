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
      };
    };
  };
}
