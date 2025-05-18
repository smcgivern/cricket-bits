{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem(
    system:
    let pkgs = import nixpkgs { inherit system; };
    in {
      devShells.default = pkgs.mkShellNoCC {
        buildInputs = with pkgs; [ cargo ruby_3_2 rustc sqlite ];
      };
    }
  );
}
