import csv
import logging
import sys
from argparse import ArgumentParser, Namespace
from pathlib import Path
from typing import Any, Optional
import xml.etree.ElementTree as ET


def parse_xml(filename: str) -> Optional[ET.Element]:
    try:
        tree: ET.ElementTree = ET.parse(filename)
        return tree.getroot()
    except ET.ParseError as e:
        logging.warning(f"Failed to parse {filename}", exc_info=e)
        return None


def collect_from_folder(directory: Path) -> tuple[set, set, set]:
    sources: set = set()
    targets: set = set()
    connections: set = set()

    xml_files: list[Path] = [path for path in directory.iterdir() if path.is_file() and path.suffix.upper() == ".XML"]

    for xml_file in xml_files:
        root: Optional[ET.Element] = parse_xml(xml_file.as_posix())

        if root is None:
            continue

        for elem in root.iter("SOURCE"):
            sources.add(
                (
                    elem.get("DATABASETYPE", ""),
                    elem.get("DBDNAME", ""),
                    elem.get("NAME", ""),
                )
            )

        for elem in root.iter("TARGET"):
            targets.add(
                (
                    elem.get("DATABASETYPE", ""),
                    elem.get("NAME", ""),
                )
            )

        for elem in root.iter("CONNECTIONREFERENCE"):
            connections.add(
                (
                    elem.get("CONNECTIONNAME", ""),
                    elem.get("CONNECTIONSUBTYPE", ""),
                    elem.get("CONNECTIONTYPE", ""),
                    elem.get("VARIABLE", ""),
                )
            )

    return sources, targets, connections


def write_csv(filepath: Path, fieldnames: list[str], rows: list[Any]) -> None:
    with filepath.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"Written: {filepath} ({len(rows)} rows)")


def get_argument_parser() -> ArgumentParser:
    parser: ArgumentParser = ArgumentParser(
        description="Extract Informatica XML metadata (SOURCE, TARGET, CONNECTIONREFERENCE) to CSV files"
    )
    parser.add_argument("dir", help="Root folder containing project subfolders")
    parser.add_argument("--output", default="output", help="Output folder for CSV files (default: output/)")
    return parser


def main() -> None:
    args: Namespace = get_argument_parser().parse_args()
    source: Path = Path(args.dir)

    if not source.is_dir():
        logging.error(f"Source directory {source} must be a directory")
        sys.exit(1)

    dest: Path = Path(args.output)
    dest.mkdir(parents=True, exist_ok=True)

    all_sources: list = []
    all_targets: list = []
    all_connections: list = []

    subfolders: list[Path] = sorted(path for path in source.iterdir() if path.is_dir())

    if not subfolders:
        logging.warning(f"No subfolders found within '{source}'")
        sys.exit(0)

    for subfolder in subfolders:
        directory: str = subfolder.name
        logging.info(f"Processing subfolder {directory} within {source}")
        sources, targets, connections = collect_from_folder(subfolder)

        for row in sorted(sources):
            all_sources.append({"folder": directory, "DATABASETYPE": row[0], "DBDNAME": row[1], "NAME": row[2]})

        for row in sorted(targets):
            all_targets.append({"folder": directory, "DATABASETYPE": row[0], "NAME": row[1]})

        for row in sorted(connections):
            all_connections.append(
                {
                    "folder": directory,
                    "CONNECTIONNAME": row[0],
                    "CONNECTIONSUBTYPE": row[1],
                    "CONNECTIONTYPE": row[2],
                    "VARIABLE": row[3],
                }
            )

    write_csv(dest / "sources.csv", ["folder", "DATABASETYPE", "DBDNAME", "NAME"], all_sources)
    write_csv(dest / "targets.csv", ["folder", "DATABASETYPE", "NAME"], all_targets)
    write_csv(
        dest / "connections.csv",
        ["folder", "CONNECTIONNAME", "CONNECTIONSUBTYPE", "CONNECTIONTYPE", "VARIABLE"],
        all_connections,
    )


if __name__ == "__main__":
    main()
