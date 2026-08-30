{...}: {
  flake.nixosModules.cleanup = {
    # Enable automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Optimize the Nix store by hardlinking duplicate files automatically
    nix.settings.auto-optimise-store = true;
  };
}
