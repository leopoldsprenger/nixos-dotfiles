# modules/features/keys.nix
#
# Declarative git credentials via sops-nix.
#
#   resources/secrets/github.yaml -> one SSH key, reused on every machine
#     (NixOS or not) that needs to push to private GitHub repos.
#   resources/secrets/gitlab.yaml -> one SSH key, reused on every NixOS
#     machine that needs to push to private GitLab repos.
#
# Both files are ciphertext (safe to commit). sops-nix decrypts them at
# system activation time straight to /run/secrets/<name> - a tmpfs, never
# the Nix store - owned by `leo`, mode 0400. `programs.ssh` is then just
# told where to find them; it never has to manage the secret files
# itself, which sidesteps the home-manager-activation-order issues that
# come from trying to symlink secrets directly into ~/.ssh.
#
# See README.md, section "Secrets (sops-nix)", for the one-time setup
# (generating the age key + the two SSH keys) and for how to add another
# machine as a recipient later.
{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.ssh = {...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    # The private half of THIS machine's age keypair. Deliberately not
    # generated or managed by Nix - see README.md "Set up your sops
    # decryption key". It has to already exist at this path before the
    # first activation (i.e. before `nixos-install`), or decryption
    # below has nothing to decrypt with.
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # Fail loudly instead of silently minting a new (unauthorized, and
    # therefore useless) key if the file above is missing.
    sops.age.generateKey = false;

    # We authenticate with an explicit age key rather than one derived
    # from the host's SSH host key, so decryption works from the very
    # first activation - no dependency on openssh having already
    # generated host keys.
    sops.age.sshKeyPaths = [];

    sops.secrets = {
      "github-ssh-key" = {
        sopsFile = "${self}/resources/secrets/github.yaml";
        key = "ssh_key";
        owner = "leo";
        mode = "0400";
      };
      "gitlab-ssh-key" = {
        sopsFile = "${self}/resources/secrets/gitlab.yaml";
        key = "ssh_key";
        owner = "leo";
        mode = "0400";
      };
    };

    # Point git's ssh at the decrypted keys by host. Plain extraConfig
    # rather than the structured matchBlocks/settings options, since
    # that part of the home-manager ssh module has been churning lately
    # and raw ssh_config syntax isn't going anywhere.
    home-manager.users.leo.programs.ssh = {
      enable = true;
      extraConfig = ''
        Host github.com
          User git
          IdentitiesOnly yes
          IdentityFile /run/secrets/github-ssh-key

        Host gitlab.com
          User git
          IdentitiesOnly yes
          IdentityFile /run/secrets/gitlab-ssh-key
      '';
    };
  };
}
