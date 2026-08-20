{inputs, ...}: {
  flake.nixosModules.project-helpers = {
    config,
    pkgs,
    lib,
    ...
  }: let
    termtoolsSrc = pkgs.fetchFromGitHub {
      owner = "leopoldsprenger";
      repo = "termtools";
      rev = "main";
      hash = "sha256-mDOBpG0DrCkUKlDoewYanVthnI1uC+wa7wzsUvaeGTs=";
    };

    mkproj = pkgs.writeShellScriptBin "mkproj" ''
      exec ${pkgs.bash}/bin/bash "${termtoolsSrc}/create-new-project.sh" "$@"
    '';

    projects = pkgs.writeShellScriptBin "projects" ''
      exec ${pkgs.bash}/bin/bash "${termtoolsSrc}/open-project.sh" "$@"
    '';
  in {
    config = {
      home-manager.users.leo = {
        home.packages = [
          mkproj
          projects
        ];
      };
    };
  };
}
