{...}: {
  flake.nixosModules.development = {
    config,
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      git
      uv
      gh
    ];

    environment.localBinInPath = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        glib
      ];
    };
  };
}
