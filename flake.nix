{
  description = "Formulyx development environment flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Library paths for Common Lisp CFFI
      lispLibs = [
        "${pkgs.gmp}/lib"          # Required by sb-gmp (big number arithmetic)
        "${pkgs.mpfr}/lib"         # Required by sb-mpfr (precise floating point)
        "${pkgs.openssl.out}/lib"  # Required by clog/cl+ssl (cryptography/HTTPS)
        "${pkgs.sqlite.out}/lib"   # Required by mito/cl-dbi (database access)
      ];
      lispLibPath = builtins.concatStringsSep ":" lispLibs;
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Common Lisp
          sbcl
          clasp-common-lisp

          # C Libraries (for CFFI)
          gmp       # Required by sb-gmp
          mpfr      # Required by sb-mpfr
          openssl   # Required by cl+ssl (via clog)
          sqlite    # Required by sqlite wrapper (via cl-dbi)
        ];
        shellHook = ''
          export LD_LIBRARY_PATH="${lispLibPath}:$LD_LIBRARY_PATH"
          echo "Formulyx development environment loaded"
          echo "C libraries available: gmp, mpfr, openssl, sqlite"
        '';
      };
    };
}
