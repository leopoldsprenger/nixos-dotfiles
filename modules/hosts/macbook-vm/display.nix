{self, ...}: {
  flake.nixosModules.macbookDisplay = {
    pkgs,
    lib,
    config, # Added config parameter
    ...
  }: {
    # We force overwrite the global text configuration
    environment.etc."mango/config.conf".text = lib.mkForce ''
      # --- Global Mango Configuration File Inherit ---
      ${config.internal.mangoRawConfig}

      # --- MacBook Panel Layout Override ---
      monitorrule=name:Virtual-1,width:2560,height:1600,refresh:60,x:0,y:0,scale:1.6,custom:1,rr:0
    '';

    # Also update home-manager text configuration so it maps perfectly
    home-manager.users.leo.xdg.configFile."mango/config.conf".text = lib.mkForce ''
      # --- Global Mango Configuration File Inherit ---
      ${config.internal.mangoRawConfig}

      # --- MacBook Panel Layout Override ---
      monitorrule=name:Virtual-1,width:2560,height:1600,refresh:60,x:0,y:0,scale:1.6,custom:1,rr:0
    '';
  };
}
