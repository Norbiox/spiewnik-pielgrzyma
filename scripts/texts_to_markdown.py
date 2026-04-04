#!/usr/bin/env python3
import json
import csv
from typing import Any


def read_csv_to_dict(file_path: str) -> list[dict[str, Any]]:
    data = []
    with open(file_path, "r", encoding="utf-8") as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            data.append(dict(row))
    return data


def read_json_to_dict(file_path: str) -> list[dict[str, Any]]:
    with open(file_path, "r", encoding="utf-8") as json_file:
        data = json.load(json_file)
    return data


if __name__ == "__main__":
    hymns_info = read_csv_to_dict("./assets/hymns.csv")
    hymns_texts = read_json_to_dict("./assets/hymns_texts.json")

    markdown = """# Śpiewnik Pielgrzyma
    """

    last_group = None
    last_subgroup = None

    for hymn in hymns_info:
        if last_group != hymn["group_name"]:
            markdown += f"\n## {hymn['group_name']}\n"
            last_group = hymn["group_name"]
            last_subgroup = None

        if last_subgroup != hymn["subgroup_name"]:
            markdown += f"\n### {hymn['subgroup_name']}\n"
            last_subgroup = hymn["subgroup_name"]

        markdown += f"\n#### {hymn['number']}. {hymn['title']}\n"

        for line in hymns_texts[hymn["number"]]:
            markdown += f"{line}\n"

    with open("./assets/hymns.md", "w", encoding="utf-8") as md_file:
        md_file.write(markdown)
