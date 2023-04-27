{ lib
, python3
, fetchFromGitHub
, chafa
, imagemagickBig
, glib
}:
let
  chafa-py = python3.pkgs.buildPythonPackage
    rec {
      pname = "chafa-py";
      version = "1.1.1";
      format = "pyproject";
      src = python3.pkgs.fetchPypi {
        pname = "chafa.py";
        inherit version;
        hash = "sha256-yqNMsmtSOKeqE7rceScW/AEmsYVQ+qYNLy0IIHnU09A=";
        extension = "tar.gz";
      };
      nativeBuildInputs = [
        python3.pkgs.hatchling
      ];
      propagatedBuildInputs = [
        chafa
        imagemagickBig
      ];
    };
in
python3.pkgs.buildPythonPackage rec {
  pname = "xdcmd";
  version = "4f27c3f";
  format = "other";
  src = fetchFromGitHub {
    owner = "TransparentLC";
    repo = "xdcmd";
    rev = "4f27c3f7762d3bc9df8038d5d4df3bc2a13fb2d6";
    sha256 = "sha256-aYLQc3QD6QzZEvQSPDtKzTAOAaM/JNB6hBr6cvK8xgY=";
  };
  pythonPath = with python3.pkgs; [
    beautifulsoup4
    requests
    prompt-toolkit
    wcwidth

    chafa-py
  ];
  propagatedBuildInputs = [
    chafa
  ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    sed '1i\#!/usr/bin/python3' main.py >> xdcmd
    chmod +x xdcmd

    mv xdnmb xdcmd $out/share
    wrapPythonProgramsIn $out/share "$pythonPath"
    wrapProgram $out/share/xdcmd \
      --prefix LD_LIBRARY_PATH ":" "${chafa}/lib:${glib.out}/lib"\
      --set MAGICK_HOME "${imagemagickBig}/lib"
    ln -s $out/share/xdcmd $out/bin
  '';
  meta = with lib; {
    description = "X 岛匿名版命令行客户端";
    homepage = https://nmbxd.com/t/50750950;
    license = licenses.agpl3;
    platforms = platforms.all;
    mainProgram = "xdcmd";
  };
}
