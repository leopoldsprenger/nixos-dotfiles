{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.ssh = {...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.age.generateKey = false;
    sops.age.sshKeyPaths = [];

    sops.secrets = {
      "github-ssh-key" = {
        sopsFile = "${self}/resources/secrets/github.yaml";
        key = "ssh_key";
        owner = "leo";
        path = "/home/leo/.ssh/github_ed25519";
      };
      "gitlab-ssh-key" = {
        sopsFile = "${self}/resources/secrets/gitlab.yaml";
        key = "ssh_key";
        owner = "leo";
        path = "/home/leo/.ssh/gitlab_ed25519";
      };
    };

    home-manager.users.leo.programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "github.com" = {
          user = "git";
          identitiesOnly = true;
          identityFile = "~/.ssh/github_ed25519";
        };
        "gitlab.com gitlab.hpi.de" = {
          user = "git";
          identitiesOnly = true;
          identityFile = "~/.ssh/gitlab_ed25519";
        };
      };
    };
  };
}
