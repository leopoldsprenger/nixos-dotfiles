{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.leoNiri;
      };
    };

  perSystem =
    { pkgs, lib, self', ... }:
    {
      # This bakes a config.kdl from the settings below directly into a
      # wrapped niri package - no separate KDL file to hand-maintain.
      # Add more here as you customize; see:
      # https://birdeehub.github.io/nix-wrapper-modules/niri.html
      packages.leoNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          # Launch noctalia (the bar/launcher/notifications/etc. shell) as
          # soon as niri starts.
          spawn-at-startup = [
            (lib.getExe self'.packages.noctaliaConfig)
          ];

          # Lets plain X11 apps run under niri.
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          layout.gaps = 8;

          binds = {
            "Mod+Q".spawn-sh = "env LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty}";
            "Mod+W".close-window = { };
            "Mod+Shift+E".quit = { };
            "Mod+Space".spawn-sh = "${lib.getExe self'.packages.noctaliaConfig} ipc call launcher toggle";
            "Mod+B".spawn-sh = "${lib.getExe pkgs.firefox}";
          };

          outputs = {
            "Virtual-1" = {
              mode = "1920x1080@60.000";
              scale = 1.0;
            };

            "Unknown-1" = { off = { }; };
          };
        };
      };
    };
}
