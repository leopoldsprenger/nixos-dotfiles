{
  flake.nixosModules.ensure-project-dirs = {
    config,
    pkgs,
    lib,
    ...
  }: let
    projectFolders = [
      "prototypes"
      "research"
      "automation"
      "school"
      "products"
      "infrastructure"
      "competition"
    ];
  in {
    home-manager.users.leo = {lib, ...}: {
      home.activation = {
        createProjectFolders = lib.hm.dag.entryAfter ["writeBoundary"] (
          lib.concatMapStringsSep "\n" (name: ''
            $DRY_RUN_CMD mkdir -p "$HOME/projects/${name}"
          '')
          projectFolders
        );
      };
    };
  };
}
