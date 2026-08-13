{ ... }: {
  flake.nixosModules.git = {
    home-manager.users.leo.programs.git = {
      enable = true;
      settings = {
        user.name = "Leopold Sprenger";
        user.email = "186564656+leopoldsprenger@users.noreply.github.com";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}
