import json
import os
from pathlib import Path

src = Path("_sources/generated.json").open()
ver = json.load(src)["xdcmd"]["version"]

env_file = Path(os.getenv("GITHUB_ENV"))
if env_file.exists():
    env_file.open("a").write(f'COMMIT_MSG="auto update: {ver}"')
