{ self, ... }:
{
  flake.nixosModules.leo-niri-configuration =
    { config, pkgs, lib, ... }:
    {
      imports = [
        # Replace this file with the one nixos-generate-config makes for
        # your machine - see the README.
        ./hardware-configuration.nix

        # Provides programs.niri, configured declaratively.
        self.nixosModules.niri
        self.nixosModules.noctalia
        self.nixosModules.home-manager
        self.nixosModules.git
        self.nixosModules.cursor
      ];

      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      # Modern convention: set the system here rather than passing
      # `system = ...` to nixosSystem in default.nix.
      nixpkgs.hostPlatform = "aarch64-linux";

      # --- Boot ---
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # --- Networking ---
      networking.hostName = "leo-niri"; # change freely, purely cosmetic
      networking.networkmanager.enable = true;

      # --- Locale ---
      time.timeZone = "Europe/Berlin"; # change to your timezone
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "us"; # TTY keymap; niri's keyboard layout is set in modules/features/niri.nix

      # Swap in RAM instead of a swap partition - one less thing to
      # partition, works well for a minimal install.
      zramSwap.enable = true;

      # --- User ---
      users.users.leo = {
        isNormalUser = true;
        description = "Leo";
        extraGroups = [ "wheel" "networkmanager" "video" "input" ];
        # Temporary password so you can log in immediately after install.
        # Change it on first boot with: passwd
        initialPassword = "changeme";
      };

      security.polkit.enable = true;

      # --- Login straight into niri ---
      # initial_session skips any login prompt and boots directly into the
      # niri+noctalia desktop as leo. If you'd rather have a login prompt
      # (e.g. this isn't a single-user personal machine), delete
      # `initial_session` and greetd will fall back to a tuigreet-style
      # prompt using `default_session`.
      services.greetd = {
        enable = true;
        settings = {
          initial_session = {
            command = "${config.programs.niri.package}/bin/niri-session";
            user = "leo";
          };
          default_session = {
            command = "${config.programs.niri.package}/bin/niri-session";
            user = "leo";
          };
        };
      };

      environment.systemPackages = with pkgs; [
        vim
        nano
        alacritty # terminal, bound to Mod+Return in niri
        xwayland-satellite # lets X11-only apps run under niri
      ];

      # Keep this at the value it was on first install - it is not a
      # "current version" knob, it just pins on-disk data formats.
      system.stateVersion = "26.05";
    };
}
