{
  description = "Caddy with Cloudflare plugin and expanded module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        attrs system pkgs);
  in {
    # nix build
    packages = perSystem (system: pkgs: {
      caddy = pkgs.callPackage ./nix {};
      default = self.packages.${system}.caddy;
    });

    # Default module
    nixosModules.default = import ./modules inputs;

    # nix develop
    devShells = perSystem (_: pkgs: {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          go
        ];
      };
    });

    formatter = perSystem (_: pkgs: pkgs.alejandra);
  };
}
