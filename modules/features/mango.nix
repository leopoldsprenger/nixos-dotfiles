{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.mango = {
    pkgs,
    lib,
    ...
  }: let
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

      # Dwindle Layout Setting
      dwindle_smart_split=0
      dwindle_drop_simple_split=1
      dwindle_manual_split=0
      tagrule=id:*,layout_name:dwindle

      # --- Aesthetics & Global Glaze Blur ---
      gappih=6
      gappiv=6
      gappoh=6
      gappov=6
      borderpx=2
      focuscolor=0x74c7ecb3
      bordercolor=0x31324466
      border_radius=16

      # blur settings
      blur=1
      blur_optimized=1

      # MangoWM Äquivalent zu deinem niri blur { } block:
      blur_params_num_passes=4       # passes 4
      blur_params_radius=3           # offset 3.0 (Mango nutzt Integer-Radien)
      blur_params_noise=0.02         # noise 0.02
      blur_params_saturation=1.5     # saturation 1.5

      # Standard-Deckkraft (Falls keine spezifische Regel greift)
      focused_opacity=0.93
      unfocused_opacity=0.93

      # --- App-Specific Glaze/Xray Mirror Rules ---
      # Firefox Picture-in-Picture: Erzwinge Floating
      windowrule=isfloating:1,appid:firefox,title:^Picture-in-Picture$

      # Volle Deckkraft für Haupt-Browser-Fenster
      windowrule=focused_opacity:1.0,unfocused_opacity:1.0,appid:firefox

      # Terminals & Editoren (JellyCat-Opacity: 0.75)
      windowrule=focused_opacity:0.75,unfocused_opacity:0.75,appid:kitty

      # Noctalia UI (JellyCat-Opacity: 0.75 + Floating-Maße)
      windowrule=isfloating:1,focused_opacity:0.75,unfocused_opacity:0.75,width:1080,height:920,appid:dev\.noctalia\.Noctalia

      # --- Startup ---
      exec-once=${lib.getExe noctalia}

      # --- Keybinds ---
      bind=SUPER,Q,spawn_shell,LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty}
      bind=SUPER,W,killclient
      bind=Super,Space,spawn,${lib.getExe noctalia} msg panel-toggle launcher
      bind=SUPER,B,spawn,${lib.getExe pkgs.firefox}
      bind=SUPER,E,spawn_shell,LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty} -- yazi

      bind=SUPER,M,spawn,${lib.getExe noctalia} msg panel-toggle wallpaper
      bind=SUPER+SHIFT,M,spawn,${lib.getExe noctalia} msg panel-toggle noctalia/wallhaven:browser
      bind=SUPER,comma,spawn,${lib.getExe noctalia} msg settings-open
      bind=SUPER,P,spawn,${lib.getExe noctalia} msg panel-toggle session
      bind=SUPER,C,spawn,${lib.getExe noctalia} msg panel-toggle clipboard

      bind=SUPER,Left,focusdir,left
      bind=SUPER,Right,focusdir,right
      bind=SUPER,Up,focusdir,up
      bind=SUPER,Down,focusdir,down
      bind=SUPER,H,focusdir,left
      bind=SUPER,L,focusdir,right
      bind=SUPER,K,focusdir,up
      bind=SUPER,J,focusdir,down

      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Right,exchange_client,right
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down
      bind=SUPER+SHIFT,H,exchange_client,left
      bind=SUPER+SHIFT,L,exchange_client,right
      bind=SUPER+SHIFT,K,exchange_client,up
      bind=SUPER+SHIFT,J,exchange_client,down

      bind=SUPER+SHIFT,T,setlayout,dwindle
      bind=SUPER+SHIFT,S,setlayout,scroller
      bind=SUPER,N,switch_layout

      # --- Tag / Workspace Keybinds ---
      bind=SUPER,1,view,1
      bind=SUPER,2,view,2
      bind=SUPER,3,view,3
      bind=SUPER,4,view,4
      bind=SUPER,5,view,5
      bind=SUPER,6,view,6
      bind=SUPER,7,view,7
      bind=SUPER,8,view,8
      bind=SUPER,9,view,9

      bind=SUPER+SHIFT,1,tag,1
      bind=SUPER+SHIFT,2,tag,2
      bind=SUPER+SHIFT,3,tag,3
      bind=SUPER+SHIFT,4,tag,4
      bind=SUPER+SHIFT,5,tag,5
      bind=SUPER+SHIFT,6,tag,6
      bind=SUPER+SHIFT,7,tag,7
      bind=SUPER+SHIFT,8,tag,8
      bind=SUPER+SHIFT,9,tag,9

      # apply noctalia theme
      source=~/.config/mango/noctalia.conf
    '';
  in {
    imports = [inputs.mango.nixosModules.mango];

    programs.mango.enable = true;
    programs.dconf.enable = true;

    environment.etc."mango/config.conf".source = mangoConfig;

    home-manager.users.leo = {
      dconf.enable = true;
      xdg.configFile."mango/config.conf".source = mangoConfig;
    };
  };
}
