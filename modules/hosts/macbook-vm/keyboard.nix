{self, ...}: {
  flake.nixosModules.macbookKeyboard = {...}: {
    services.xserver.xkb = {
      layout = "de";
      variant = "";
    };

    console.keyMap = "de";
  };
}
