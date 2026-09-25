{ ... }: {
  flake.nixosModules.clipboard = { pkgs, ... }: {
    home-manager.users.leo = {
      home.packages = with pkgs; [
        wl-clipboard
      ];
    };
  };
}

