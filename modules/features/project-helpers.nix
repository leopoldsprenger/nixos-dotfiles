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
      hash = "sha256-ho9B/6rB2bShU7fcMUcZDApWbRaGnwY7JbuQrarjiSo=";
    };

    mkproj = pkgs.writeShellScriptBin "mkproj" ''
      export PATH="${lib.makeBinPath [pkgs.python3]}:$PATH"
      export PATH="$PATH:/run/current-system/sw/bin:/etc/profiles/per-user/leo/bin"
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
