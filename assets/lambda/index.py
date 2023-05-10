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

    content = repo.get_contents(path="", ref=branch)

    paths = [c.path for c in content]

    return {"statusCode": 200, "body": json.dumps(paths)}


if __name__ == "__main__":
    print(handler({"pathParameters": {"branch": "content-dev"}}, {}))
