#!/usr/bin/env python3

import os
import re
import sys


def main():
    if len(sys.argv) != 3:
        print("Usage: bin/render-cloud-run-service TEMPLATE OUTPUT", file=sys.stderr)
        return 1

    template_path = sys.argv[1]
    output_path = sys.argv[2]
    with open(template_path, encoding="utf-8") as template_file:
        rendered = template_file.read()

    replacements = {
        "IMAGE": f"asia.gcr.io/{os.environ['PROJECT_ID']}/{os.environ['REPO_NAME']}:{os.environ['COMMIT_SHA']}",
        "SERVICE_NAME": os.environ["_SERVICE_NAME"],
        "CLOUD_SQL_HOST": os.environ["_CLOUD_SQL_HOST"],
        "APP_HOST_NAME": os.environ["_APP_HOST_NAME"],
        "CLOUD_RUN_HOST_NAME": os.environ["_CLOUD_RUN_HOST_NAME"],
        "DB_NAME": os.environ["_DB_NAME"],
        "DB_USER": os.environ["_DB_USER"],
        "GCS_BUCKET": os.environ["_GCS_BUCKET"],
        "BASIC_AUTH_USER": os.environ["_BASIC_AUTH_USER"],
        "COMMIT_SHA": os.environ["COMMIT_SHA"],
        "BUILD_ID": os.environ["BUILD_ID"],
        "TRIGGER_ID": os.environ["_TRIGGER_ID"],
    }

    for key, value in replacements.items():
        rendered = rendered.replace(f"__{key}__", value)

    placeholders = sorted(set(re.findall(r"__[A-Z0-9_]+__", rendered)))
    if placeholders:
        print(f"Unresolved placeholders: {', '.join(placeholders)}", file=sys.stderr)
        return 1

    with open(output_path, "w", encoding="utf-8") as output_file:
        output_file.write(rendered)

    return 0


if __name__ == "__main__":
    sys.exit(main())
