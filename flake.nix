{
  description = "Jon's OpenCode config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [pkgs.nodejs];
          shellHook = ''
            export PATH="$PWD/node_modules/.bin:$PATH"
            npm i opencode-ai
            echo "Run: opencode"
          '';
        };
      }
    );
}
