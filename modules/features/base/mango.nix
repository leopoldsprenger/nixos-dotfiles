{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.mango = {
    pkgs,
    lib,
    config,
    ...
  }: let
    noctalia = self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaConfig;

    rawMangoConfigText = ''
      # --- Input ---
      repeat_rate=50
      repeat_delay=300

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
      borderpx=1
      focuscolor=0x74c7ecb3
      bordercolor=0x31324466
      border_radius=15

      # Hide cursor
      cursor_hide_timeout=3
      cursor_hide_on_keypress=1

      # Blur settings
      blur=1
      blur_optimized=1
      blur_params_num_passes=6
      blur_params_radius=3
      blur_params_noise=0.08
      blur_params_saturation=3

      # Standard opacity
      focused_opacity=0.93
      unfocused_opacity=0.93

      # Strip borders from all apps by default
      windowrule=isnoborder:1,appid:.*

      # --- App-Specific Glaze/Xray Mirror Rules ---

      # Firefox Picture-in-Picture
      windowrule=isfloating:1,appid:firefox,title:^Picture-in-Picture$

      # Firefox main windows
      windowrule=focused_opacity:1.0,unfocused_opacity:1.0,appid:firefox

      # Terminals & editors
      windowrule=focused_opacity:0.75,unfocused_opacity:0.75,appid:kitty

      # Noctalia UI
      windowrule=isfloating:1,focused_opacity:0.75,unfocused_opacity:0.75,isnoborder:0,width:1080,height:920,appid:dev\.noctalia\.Noctalia

      windowrule=isfloating:1,appid:^stride-quick-capture$

      # --- Startup ---

      # Noctalia is started by Mango.
      exec-once=${lib.getExe noctalia}

      # Fcitx5 is started by the NixOS input-method module.
      # Do not start pkgs.fcitx5 manually here.

      # --- Keybinds ---

      bind=SUPER,Q,spawn_shell,LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty}
      bind=SUPER,W,killclient
      bind=SUPER,Space,spawn,${lib.getExe noctalia} msg panel-toggle launcher
      bind=SUPER,B,spawn,${lib.getExe pkgs.firefox}
      bind=SUPER,E,spawn_shell,LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty} -- yazi
      bind=SUPER,T,spawn_shell,LIBGL_ALWAYS_SOFTWARE=1 ${lib.getExe pkgs.kitty} -- stride
      bind=SUPER+SHIFT,T,spawn,stride --quick-capture

      bind=SUPER,M,spawn,${lib.getExe noctalia} msg panel-toggle wallpaper
      bind=SUPER+SHIFT,M,spawn,${lib.getExe noctalia} msg panel-toggle noctalia/wallhaven:browser
      bind=SUPER,comma,spawn,${lib.getExe noctalia} msg settings-open
      bind=SUPER,P,spawn,${lib.getExe noctalia} msg panel-toggle session
      bind=SUPER,L,spawn,${lib.getExe noctalia} msg session lock

      bind=SUPER+SHIFT,C,spawn,${lib.getExe noctalia} msg panel-toggle clipboard
      bind=SUPER,F,spawn,${lib.getExe noctalia} msg panel-toggle nightwatch75/file-search:panel
      bind=SUPER,X,spawn,${lib.getExe noctalia} msg panel-toggle control-center network
      bind=SUPER,Z,spawn,${lib.getExe noctalia} msg panel-toggle control-center bluetooth
      bind=SUPER,C,spawn,${lib.getExe noctalia} msg panel-toggle control-center calendar

      # --- Keyboard Layout / Input Method ---
      #
      # Super+Shift+I:
      #
      #   English QWERTY
      #       ↓
      #   German QWERTZ
      #       ↓
      #   Japanese / Mozc
      #       ↓
      #   English QWERTY
      #
      bind=SUPER+SHIFT,I,spawn,/run/current-system/sw/bin/fcitx5-cycle-layouts

      # --- Screenshots ---

      bind=SUPER+SHIFT,R,spawn,${lib.getExe noctalia} msg screenshot-fullscreen
      bind=SUPER,R,spawn,${lib.getExe noctalia} msg screenshot-region

      # --- Window Navigation ---

      bind=SUPER,Left,focusdir,left
      bind=SUPER,Right,focusdir,right
      bind=SUPER,Up,focusdir,up
      bind=SUPER,Down,focusdir,down

      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Right,exchange_client,right
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down

      # --- Layouts ---

      bind=SUPER+SHIFT,T,setlayout,dwindle
      bind=SUPER+SHIFT,S,setlayout,scroller
      bind=SUPER,N,switch_layout

      # --- Tag / Workspace Keybinds ---

      tag_num=5

      bind=SUPER,1,view,1
      bind=SUPER,2,view,2
      bind=SUPER,3,view,3
      bind=SUPER,4,view,4
      bind=SUPER,5,view,5

      bind=SUPER+SHIFT,1,tag,1
      bind=SUPER+SHIFT,2,tag,2
      bind=SUPER+SHIFT,3,tag,3
      bind=SUPER+SHIFT,4,tag,4
      bind=SUPER+SHIFT,5,tag,5

      # --- Animations ---

      animations=1
      layer_animations=1

      animation_duration_move=180
      animation_duration_open=160
      animation_duration_tag=140
      animation_duration_close=120
      animation_duration_focus=100

      # --- Noctalia Theme ---

      source=~/.config/mango/noctalia.conf
    '';

    mangoConfig = pkgs.writeText "mango-config.conf" rawMangoConfigText;
  in {
    imports = [
      inputs.mango.nixosModules.mango
    ];

    # Expose the raw configuration to other modules.
    #
    # display.nix currently consumes this as:
    #   config.internal.mangoRawConfig
    #
    options.internal.mangoRawConfig = lib.mkOption {
      type = lib.types.str;
      default = rawMangoConfigText;
      description = "Raw MangoWM configuration shared with other modules.";
    };

    config = {
      programs.mango.enable = true;
      programs.dconf.enable = true;

      # System-level Mango configuration.
      environment.etc."mango/config.conf".source = mangoConfig;

      # Home Manager Mango configuration.
      home-manager.users.leo = {
        dconf.enable = true;

        xdg.configFile."mango/config.conf".source = mangoConfig;
      };
    };
  };
}
