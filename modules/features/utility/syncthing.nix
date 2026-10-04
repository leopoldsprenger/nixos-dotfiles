{...}: {
  flake.nixosModules.syncthing = {
    services.syncthing = {
      enable = true;

      user = "leo";
      group = "users";

      dataDir = "/home/leo";

      settings = {
        options = {
          relaysEnabled = true;
          globalAnnounceEnabled = true;
          localAnnounceEnabled = true;
        };
      };
    };
  };
}
