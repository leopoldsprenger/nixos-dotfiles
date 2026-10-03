{...}: {
  flake.nixosModules.keyboard = {pkgs, ...}: let
    fcitx5-cycle-layouts = pkgs.writeShellScriptBin "fcitx5-cycle-layouts" ''
      FCITX_REMOTE="/run/current-system/sw/bin/fcitx5-remote"

      case "$($FCITX_REMOTE -n)" in
        keyboard-us)
          $FCITX_REMOTE -s keyboard-de
          ;;
        keyboard-de)
          $FCITX_REMOTE -s mozc
          ;;
        mozc)
          $FCITX_REMOTE -s keyboard-us
          ;;
        *)
          $FCITX_REMOTE -s keyboard-us
          ;;
      esac
    '';
  in {
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    console.keyMap = "us";

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";

      fcitx5 = {
        waylandFrontend = true;
        ignoreUserConfig = true;

        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];

        settings = {
          globalOptions = {
            Behavior = {
              ActiveByDefault = true;
              ShareInputState = "All";
              ShowInputMethodInformation = false;
            };
          };

          addons = {
            classicui.globalSection.Theme = "default-dark";
          };

          inputMethod = {
            GroupOrder."0" = "Default";

            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "us";
              DefaultIM = "keyboard-us";
            };

            "Groups/0/Items/0".Name = "keyboard-us";
            "Groups/0/Items/1".Name = "keyboard-de";
            "Groups/0/Items/2".Name = "mozc";
          };
        };
      };
    };

    environment.systemPackages = [
      fcitx5-cycle-layouts
    ];

    environment.variables = {
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULE = "wayland;fcitx";
    };
  };
}
