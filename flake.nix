{
  description = "A dwm status bar written in Nim";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachSystem [ system.x86_64-linux system.aarch64-linux ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nimx11 = pkgs.nimPackages.buildNimPackage rec {
          name = "x11";
          src = fetchTarball {
            url = "https://github.com/nim-lang/x11/archive/master.tar.gz";
            sha256 = "0h770z36g2pk49pm5l1hmk9bi7a58w8csd7wqxcwy0bi41g74x6r";
          };
        };
      in
      {
        packages.nimblocks = pkgs.nimPackages.buildNimPackage rec {
          name = "nimblocks";
          nimBinOnly = true;
          src = fetchTarball {
            url = "https://github.com/usdogu/nimblocks/archive/main.tar.gz";
            sha256 = "10q3xikw9gm7zcl9f4akcpwc6dlipl0dig876nandyw83zdfiz0g";
          };
          buildInputs = [ nimx11 pkgs.xorg.libX11 ];
        };

        defaultPackage = self.packages.${system}.nimblocks;
        devShell = pkgs.mkShell { buildInputs = [ pkgs.xorg.libX11 pkgs.nim nimx11 ]; };
      });
}
