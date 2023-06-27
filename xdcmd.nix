{
  lib,
  fetchFromGitHub,
  python3Packages,
  chafa,
  imagemagickBig,
}:
python3Packages.buildPythonApplication {
  pname = "xdcmd";
  version = "4f27c3f";
  format = "other";
  src = fetchFromGitHub {
    owner = "TransparentLC";
    repo = "xdcmd";
    rev = "9f1fcb619fa150b74eff98be1b9a74a474c4667d";
    sha256 = "sha256-A2GoNgGryV6bvkWDllAEM9V+VSw0XqJ1gtIR6EqlRtg=";
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
      --add-flags $out/share/main.py \
      --set MAGICK_HOME "${imagemagickBig}/lib"
    substituteInPlace $out/share/xdnmb/util.py \
      --replace "'chafa'" "'${chafa}/bin/chafa'"
  '';
  meta = with lib; {
    description = "X 岛匿名版命令行客户端";
    homepage = "https://nmbxd.com/t/50750950";
    license = licenses.agpl3;
    platforms = platforms.all;
    mainProgram = "xdcmd";
  };
}
