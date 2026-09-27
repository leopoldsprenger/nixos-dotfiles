{...}: {
  flake.nixosModules.zathura = {
    config,
    pkgs,
    ...
  }: {
    home-manager.users.leo = {
      home.packages = with pkgs; [
        zathura
        xdotool
      ];

      # Explicitly use the nested Home Manager lib evaluation path
      home.file.".config/zathura/zathurarc".source =
        config.home-manager.users.leo.lib.file.mkOutOfStoreSymlink "/home/leo/.config/zathura/noctaliarc";
    };
  };
}
