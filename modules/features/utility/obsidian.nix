{...}: {
  flake.nixosModules.obsidian = {
    config,
    pkgs,
    ...
  }: {
    nixpkgs.config.allowUnfree = true;

    home-manager.users.leo = {
      programs.obsidian = {
        enable = true;
        vaults.notes = {
          target = "obsidian";
          # Use 'settings' here instead of 'defaultSettings'
          settings.app = {
            alwaysUpdateLinks = true;
            spellcheck = true;
          };
        };
      };
    };
  };
}
