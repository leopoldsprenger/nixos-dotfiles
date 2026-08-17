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
      extraConfig = ''
        Host github.com
          User git
          IdentitiesOnly yes
          IdentityFile ~/.ssh/github_ed25519

        Host gitlab.com gitlab.hpi.de
          User git
          IdentitiesOnly yes
          IdentityFile ~/.ssh/gitlab_ed25519
      '';
    };
  };
}
