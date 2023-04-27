{
  description = "X 岛匿名版命令行客户端";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      defaultPackage = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; }; in
        pkgs.callPackage ./xdcmd.nix { });
    };
}
