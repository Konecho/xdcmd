{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = inputs: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];
    forAllSystems = f:
      inputs.nixpkgs.lib.genAttrs systems
      (system: f inputs.nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          (python3.withPackages (
            p:
              with p; [
                pygments
                python-lsp-server
                black
                pytest
                # deps
                beautifulsoup4
                requests
                prompt-toolkit
                wcwidth
              ]
          ))
          chafa
        ];
      };
    });
    defaultPackage = forAllSystems (pkgs: let
      source = (import ./_sources/generated.nix) {
        inherit
          (pkgs)
          fetchgit
          fetchurl
          fetchFromGitHub
          dockerTools
          ;
      };
    in
      pkgs.callPackage ./xdcmd.nix {source = source.xdcmd;});
  };
}
