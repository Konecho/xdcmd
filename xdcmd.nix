{
  lib,
  fetchFromGitHub,
  python3Packages,
  chafa,
  source,
}:
python3Packages.buildPythonApplication {
  inherit (source) pname src version;

  format = "other";

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    requests
    prompt-toolkit
    wcwidth
  ];
  installPhase = ''
    mkdir -p $out/share
    mv xdnmb main.py $out/share
    makeWrapper ${python3Packages.python.interpreter} $out/bin/xdcmd \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --add-flags $out/share/main.py
    substituteInPlace $out/share/xdnmb/util.py \
      --replace "'chafa'" "'${chafa}/bin/chafa'"
  '';
  meta = with lib; {
    description = "X 岛匿名版命令行客户端";
    homepage = "https://nmbxd.com/t/50750950";
    license = licenses.agpl3Only;
    platforms = platforms.all;
    mainProgram = "xdcmd";
  };
}
