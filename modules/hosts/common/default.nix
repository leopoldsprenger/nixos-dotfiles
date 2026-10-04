{self, ...}: {
  flake.nixosModules.common = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.home-manager
      self.nixosModules.fonts
      self.nixosModules.keyboard
      self.nixosModules.mango
      self.nixosModules.noctalia
      self.nixosModules.display-manager
      self.nixosModules.git
      self.nixosModules.ssh
      self.nixosModules.cursor
      self.nixosModules.kitty
      self.nixosModules.clipboard
      self.nixosModules.neovim
      self.nixosModules.shell
      self.nixosModules.terminal-apps
      self.nixosModules.gtk
      self.nixosModules.qt
      self.nixosModules.firefox
      self.nixosModules.ensure-project-dirs
      self.nixosModules.project-helpers
      self.nixosModules.thunar
      self.nixosModules.cleanup
      self.nixosModules.development
      self.nixosModules.stride
      self.nixosModules.latex
      self.nixosModules.zathura
      self.nixosModules.obsidian
      self.nixosModules.syncthing
    ];

    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.hostPlatform = "aarch64-linux";

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";

    zramSwap.enable = true;

    users.users.leo = {
      isNormalUser = true;
      description = "Leo";
      extraGroups = ["wheel" "networkmanager" "video" "input"];
      initialPassword = "changeme";
    };

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      vim
      nano
      xwayland-satellite
      zip
      unzip
      tree
    ];

    system.stateVersion = "26.05";
  };
}
