import json
import os
from pathlib import Path

src = Path("_sources/generated.json").open()
ver = json.load(src)["xdcmd"]["version"]
env_file = Path(os.getenv("GITHUB_ENV"))
# env_file = Path("GITHUB_ENV") # for test

old_ver = os.environ.get("OLD_VERSION")
if old_ver is None:
    env_file.open("a").write(f'OLD_VERSION="{ver}"')
elif old_ver != ver:
    env_file.open("a").write(f'COMMIT_MSG="auto update: {ver}"')
