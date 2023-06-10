{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/";
    utils.url = "github:numtide/flake-utils/";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }: let
    out = system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      inherit (pkgs) poetry2nix;

      python = pkgs.python311;
      overrides = pyfinal: pyprev: rec {};
      poetryEnv = pkgs.poetry2nix.mkPoetryEnv {
        inherit python;
        projectDir = ./.;
        preferWheels = true;
        overrides = poetry2nix.overrides.withDefaults overrides;
      };
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          alejandra
          poetry
          poetryEnv
        ];
        PYTHONBREAKPOINT = "ipdb.set_trace";
        shellHook = ''
          set -o allexport
          source .env
          set +o allexport
        '';
      };
    };
  in
    utils.lib.eachDefaultSystem out;
}
