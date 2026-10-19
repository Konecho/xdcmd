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

    # 兼容旧的 `nix build .#defaultPackage` 用法。
    defaultPackage = forAllSystems (pkgs: self.packages.${pkgs.system}.default);

    devShells = forAllSystems (pkgs: let
      python = pkgs.python3.withPackages (p:
        with p; [
          pygments
          python-lsp-server
          black
          pytest
          # 运行时依赖
          beautifulsoup4
          requests
          prompt-toolkit
          wcwidth
        ]);
    in {
      default = pkgs.mkShell {
        packages = [
          python
          pkgs.chafa
        ];
      };
    });

    formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
  };
}
