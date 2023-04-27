# xdcmd-nix

* nix:
clone本仓库，`cd <仓库所在目录>`，
`nix-build`，然后运行`result/bin/xdcmd`
* nix with flake:
  * clone本仓库，运行`nix run <仓库所在目录>`；
  * 或直接`nix run <本仓库github地址>`
* 附加参数需要这样`nix run <xxx> -- -h`
