#!/usr/bin/env python3
import argparse
import os.path
from typing import Optional
from typing import Sequence


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--tools",
        nargs="+",
        help="List of tools with a version file",
    )

    args = parser.parse_args(argv)

    returncode = 0
    try:
        with open(".tool-versions", "r") as asdf_versions_file:
            asdf_versions: Dict = {
                x.split(" ")[0]: x.split(" ")[1].rstrip()
                for x in asdf_versions_file.readlines()
            }
    except FileNotFoundError:
        returncode = 1
        print(".tool-versions file not found")
    except Exception as e:
        returncode = 1
        print(f"Exception getting tools from .tool-version {e}")

    for tool in args.tools:
        if tool not in asdf_versions:
            returncode = 0
            print(f"{tool} not duplicated in .tool-versions")
            continue
        try:
            with open(f".{tool}-version", "r") as tool_version_file:
                tool_version = tool_version_file.read().rstrip()
                if tool_version != asdf_versions[tool]:
                    returncode = 1
                    print(
                        f"version mismatch for {tool} "
                        f".{tool}-version specifies version {tool_version} "
                        f"but .tools-versions specifies {asdf_versions[tool]}"
                    )
        except FileNotFoundError:
            returncode = 1
            print(f".{tool}-version file not found")
        except Exception as e:
            returncode = 1
            print(f"Exception checking {tool} {e}")
            raise

    return returncode


if __name__ == "__main__":  # pragma: no cover
    exit(main())
