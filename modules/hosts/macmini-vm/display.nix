{self, ...}: {
  flake.nixosModules.macminiDisplay = {
    pkgs,
    lib,
    config,
    ...
  }: {
    environment.etc."mango/config.conf".text = lib.mkForce ''
      # --- Global Mango Configuration File Inherit ---
      ${config.internal.mangoRawConfig}

      # --- MacMini Panel Layout Override ---
      monitorrule=name:Virtual-1,width:3840,height:2160,refresh:60,x:0,y:0,scale:1.8,custom:1,rr:0
    '';

    home-manager.users.leo.xdg.configFile."mango/config.conf".text = lib.mkForce ''
      # --- Global Mango Configuration File Inherit ---
      ${config.internal.mangoRawConfig}

      # --- MacMini Panel Layout Override ---
      monitorrule=name:Virtual-1,width:3840,height:2160,refresh:60,x:0,y:0,scale:1.8,custom:1,rr:0
    '';
  };
}
