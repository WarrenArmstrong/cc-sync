import itertools as it
import json
import logging
import re
from typing import Any

from github import Github

logger = logging.getLogger()
logger.setLevel(logging.INFO)

branch_pattern = re.compile(r"^content-[a-zA-Z0-9]*$")


def handler(event: dict[str, Any], context: dict[str, Any]) -> dict[str, Any]:
    branch = event["pathParameters"]["branch"]

    if not branch_pattern.match(branch):
        return {
            "statusCode": 400,
            "body": f'"{branch}" is an invalid branch name. Must follow this pattern: "{branch_pattern.pattern}"',
        }

    g = Github()

    repo = g.get_repo("WarrenArmstrong/cc-sync")

    contents = _get_contents(repo=repo, path="", ref=branch)

    paths = [c.path for c in contents]

    return {"statusCode": 200, "body": ",".join(paths)}


def _get_contents(repo: Any, path: str, ref: str) -> list[Any]:
    contents = repo.get_contents(path=path, ref=ref)

    return it.chain.from_iterable(
        [_get_contents(repo, c.path, ref) if c.type == "dir" else [c] for c in contents]
    )


if __name__ == "__main__":
    print(handler({"pathParameters": {"branch": "content-dev"}}, {}))
