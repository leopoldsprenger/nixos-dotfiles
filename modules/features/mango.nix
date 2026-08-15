{ self, inputs, ... }: {
  flake.nixosModules.mango = { pkgs, lib, ... }:
    let
      noctalia = self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaConfig;

      # Built once, at eval time, as a real Nix store path — no runtime
      # file-discovery, no dependency on home-manager activation order.
      mangoConfig = pkgs.writeText "mango-config.conf" ''
        # --- Monitor ---
        # custom:1 forces the exact mode instead of an autodetected
        # fallback (this is what was giving the wrong resolution/flip).
        monitorrule=name:Virtual-1,width:3840,height:2160,refresh:60,x:0,y:0,scale:1.8,custom:1,rr:0

        # --- Input ---
        repeat_rate=35
        repeat_delay=200

        # --- Aesthetics (matches the old niri config) ---
        gappih=6
        gappiv=6
        gappoh=6
        gappov=6
        borderpx=2
        focuscolor=0x74c7ecb3
        bordercolor=0x31324466
        border_radius=12
        focused_opacity=0.93
        unfocused_opacity=0.93

        # --- Startup ---
        exec-once=${lib.getExe noctalia}

        # --- Keybinds ---
        bind=SUPER,Q,spawn_shell,LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty}
        bind=SUPER,W,killclient
        bind=SUPER+SHIFT,E,quit
        bind=SUPER,space,spawn,${lib.getExe noctalia} ipc call launcher toggle
        bind=SUPER,B,spawn,${lib.getExe pkgs.firefox}
      '';
    in
    {
      imports = [ inputs.mango.nixosModules.mango ];

      programs.mango.enable = true;

      # Populates the *real* /etc/mango/config.conf (system activation,
      # not per-user), so both the explicit `-c` launch below AND mango's
      # own documented fallback path resolve to a working file.
      environment.etc."mango/config.conf".source = mangoConfig;

      # Optional convenience copy for manually running `mango` from a TTY
      # without `-c`. Not required for the greetd session to work.
      home-manager.users.leo = { ... }: {
        xdg.configFile."mango/config.conf".source = mangoConfig;
      };
    };
}
