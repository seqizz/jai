{
  description = "jai - lightweight jail for AI CLIs on modern linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Build toolchain
          gcc14
          autoconf
          automake

          # Man page generation
          pandoc

          # For running tests
          bash

          # Helpful for development
          pkg-config
          clang-tools # clangd, clang-format etc.
          bear         # generate compile_commands.json
        ];

        shellHook = ''
          export CXX=g++
          echo "jai dev shell ready. Run ./autogen.sh && ./configure && make"
        '';
      };
    };
}
