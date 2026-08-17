{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.neovim = {
    config,
    pkgs,
    ...
  }: {
    imports =
      [
        inputs.nvf.nixosModules.default

        ./_config/options.nix
        ./_config/keybinds.nix
        ./_config/autocmds.nix
      ]
      ++ (
        let
          targetDirs = [
            ./_plugins
          ];

          getNixFiles = dir: let
            dirContents = builtins.readDir dir;

            validFiles =
              lib.filterAttrs (
                name: type: ((type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
                  || (type == "directory"))
              )
              dirContents;
          in
            map (name: dir + "/${name}") (builtins.attrNames validFiles);
        in
          lib.concatMap getNixFiles targetDirs
      );

    programs.nvf = {
      enable = true;
      defaultEditor = true;
    };
  };
}
