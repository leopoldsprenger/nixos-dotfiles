{ ... }: {
  flake.nixosModules.cursor = { pkgs, ... }: let
    cursorTheme = "Bibata-Modern-Ice";
    cursorSize = 16;
    cursorPackage = pkgs.bibata-cursors;
  in {
    home-manager.users.leo = {
      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        x11.enable = true;
        package = cursorPackage;
        name = cursorTheme;
        size = cursorSize;
      };

      gtk = {
        enable = true;
        cursorTheme = {
          name = cursorTheme;
          package = cursorPackage;
          size = cursorSize;
        };
      };
    };
  };
}

