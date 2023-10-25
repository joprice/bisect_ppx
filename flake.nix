{
  description = "bisect_ppx";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs = {
      url = "github:nix-ocaml/nix-overlays";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages."${system}".appendOverlays [
        (self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages_5_1.overrideScope'
            (oself: osuper:
              with oself;
              {
                # This removes the patch that reverts https://github.com/reasonml/reason/pull/2530, 
                # as tests do not pass with the current version used in the overlays.
                # See also https://github.com/reasonml/reason-react/pull/792#issuecomment-1741868181 
                reason = osuper.reason.overrideAttrs (o: {
                  patches = [ ];
                });
              }
            );
        })
      ];
      inherit (pkgs) ocamlPackages;
    in
    with ocamlPackages;
    rec {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          ocamlPackages.melange
          ppxlib
          uri
          js_of_ocaml-compiler
        ];
        nativeBuildInputs = [
          findlib
          ocaml
          ocaml-lsp
          reason
          dune_3
          ocamlformat
        ];
        OCAMLRUNPARAM = "b";
      };
    }));
}
