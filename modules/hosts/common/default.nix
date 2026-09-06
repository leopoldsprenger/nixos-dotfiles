{self, ...}: {
  flake.nixosModules.common = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.home-manager
      self.nixosModules.fonts
      self.nixosModules.mango
      self.nixosModules.noctalia
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
    ];

    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.hostPlatform = "aarch64-linux";

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";
    console.keyMap = "us";

    zramSwap.enable = true;

    users.users.leo = {
      isNormalUser = true;
      description = "Leo";
      extraGroups = ["wheel" "networkmanager" "video" "input"];
      initialPassword = "changeme";
    };

    security.polkit.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${config.programs.mango.package}/bin/mango -c /etc/mango/config.conf";
          user = "leo";
        };
        default_session = {
          command = "${config.programs.mango.package}/bin/mango -c /etc/mango/config.conf";
          user = "leo";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      vim
      nano
      alacritty
      xwayland-satellite
      zip
      unzip
    ];

    system.stateVersion = "26.05";
  };
}
