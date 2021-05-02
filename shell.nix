{ pkgsRef ? "489433ba48788b304f7055b3448c0bbec4c7114b"
, pkgs ? import (fetchTarball "https://github.com/nixos/nixpkgs/archive/${pkgsRef}.tar.gz") { }
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.docker
    pkgs.fluxcd
    pkgs.google-cloud-sdk
    pkgs.terraform_0_14
  ];

  shellHook = ''
    alias terra="terraform -chdir=terraform"
  '';
}
