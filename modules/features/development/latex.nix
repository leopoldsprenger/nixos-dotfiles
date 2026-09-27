{...}: {
  flake.nixosModules.latex = {pkgs, ...}: {
    home-manager.users.leo = {
      home.packages = with pkgs; [
        # Optimized layout containing common macros, XeTeX, and language modules
        texlive.combined.scheme-full
      ];
    };
  };
}
