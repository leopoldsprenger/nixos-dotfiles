{...}: {
  flake.nixosModules.latex = {pkgs, ...}: {
    home-manager.users.leo = {
      home.packages = with pkgs; [
        texliveFull
      ];
    };
  };
}
