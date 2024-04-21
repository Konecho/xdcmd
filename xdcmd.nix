{
  lib,
  fetchFromGitHub,
  python3Packages,
  chafa,
}:
python3Packages.buildPythonApplication {
  pname = "xdcmd";
  version = "84f159d";
  format = "other";
  src = fetchFromGitHub {
    owner = "TransparentLC";
    repo = "xdcmd";
    rev = "84f159decebd34ef8e9cba02d5100f7d4cc32baf";
    sha256 = "sha256-zh8XAns6CDHl1AkaWACQAxn2oTslvB35yqbJDeZvTfU=";
  };
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
