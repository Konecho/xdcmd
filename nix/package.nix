{
  lib,
  python3Packages,
  chafa,
  src ? ../.,
  version ? "0.1.0",
}:
python3Packages.buildPythonApplication {
  pname = "xdcmd";
  inherit version src;

  # 上游没有 pyproject.toml / setup.py，直接安装源码即可。
  format = "other";

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    requests
    prompt-toolkit
    wcwidth
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/xdcmd
    cp -r main.py xdnmb $out/share/xdcmd/

    makeWrapper ${python3Packages.python.interpreter} $out/bin/xdcmd \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --add-flags $out/share/xdcmd/main.py

    substituteInPlace $out/share/xdcmd/xdnmb/util.py \
      --replace-fail "'chafa'" "'${chafa}/bin/chafa'"

    runHook postInstall
  '';

  meta = with lib; {
    description = "X 岛匿名版命令行客户端";
    homepage = "https://nmbxd.com/t/50750950";
    license = licenses.agpl3Only;
    platforms = platforms.all;
    mainProgram = "xdcmd";
  };
}
