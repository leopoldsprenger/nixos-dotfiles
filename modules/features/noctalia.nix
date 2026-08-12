{ self, inputs, ...}: {
  flake.nixosModules.noctalia = 
    { pkgs, ...}: {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.noctaliaConfig
      ];
    };

  perSystem =
    { pkgs, ...}: {
      packages.noctaliaConfig = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
      };
    };
}
