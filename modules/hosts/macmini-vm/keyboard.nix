{self, ...}: {
  flake.nixosModules.macminiKeyboard = {...}: {
    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };

    console.keyMap = "de";
  };
}
