{ ... }: {
  flake.nixosModules.git = {
    home-manager.users.leo.programs.git = {
      enable = true;
      userName = "Leopold Sprenger";
      userEmail = "186564656+leopoldsprenger@users.noreply.github.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}
