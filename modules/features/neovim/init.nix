{ inputs, lib, ... }: {
  flake.nixosModules.neovim = { config, pkgs, ... }: {
    imports = [ 
      inputs.nvf.nixosModules.default
    ] ++ (
      let
        targetDirs = [
          ./_config
          ./_plugins
        ];

        getNixFiles = dir: let
          dirContents = builtins.readDir dir;
          
          validFiles = lib.filterAttrs (name: type:
            ((type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix") || 
             (type == "directory"))
          ) dirContents;
        in
          map (name: dir + "/${name}") (builtins.attrNames validFiles);

      in
        lib.concatMap getNixFiles targetDirs
    );

    programs.nvf = {
      enable = true;
    };
  };
}
