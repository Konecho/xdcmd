{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "i686-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
    ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems
      (system: f nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: let
      xdcmd = pkgs.callPackage ./nix/package.nix {src = self;};
    in {
      inherit xdcmd;
      default = xdcmd;
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = [
          pkgs.uv
          pkgs.python3
          pkgs.chafa
          pkgs.git
        ];
        env = {
          # 使用 shell 中的 Python，不让 uv 另外下载解释器。
          UV_PYTHON_PREFERENCE = "only-system";
        };
      };
    });

    formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
  };
}
