# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  xdcmd = {
    pname = "xdcmd";
    version = "9a9d090eb8b4294fe37c4e1bb1d442c2dabd60c7";
    src = fetchgit {
      url = "https://github.com/TransparentLC/xdcmd.git";
      rev = "9a9d090eb8b4294fe37c4e1bb1d442c2dabd60c7";
      fetchSubmodules = false;
      deepClone = false;
      leaveDotGit = false;
      sha256 = "sha256-6NgjlLhron66bpfmX7wxRQ+KgY3Dz9U4mixdJQ7i9OE=";
    };
    date = "2024-12-21";
  };
}
