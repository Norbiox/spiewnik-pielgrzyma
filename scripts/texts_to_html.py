#!/usr/bin/env python3
import json
import csv
from typing import Any
from html import escape

def read_csv_to_dict(file_path: str) -> list[dict[str, Any]]:
    data = []
    with open(file_path, "r", encoding="utf-8") as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:
            data.append(dict(row))
    return data

def read_json_to_dict(file_path: str) -> dict[str, Any]:
    with open(file_path, "r", encoding="utf-8") as json_file:
        data = json.load(json_file)
    return data

def generate_html(hymns_info: list[dict], hymns_texts: dict) -> str:
    html = """<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Śpiewnik Pielgrzyma</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #333;
            border-bottom: 2px solid #333;
            padding-bottom: 10px;
        }
        h2 {
            color: #444;
            border-bottom: 1px solid #777;
            padding-bottom: 5px;
            margin-top: 30px;
        }
        h3 {
            color: #555;
            margin-top: 20px;
        }
        .hymn-title {
            font-weight: bold;
            color: #333;
            margin-top: 15px;
        }
        .hymn-text {
            margin-bottom: 20px;
        }
        .hymn-text p {
            white-space: pre-line;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <h1>Śpiewnik Pielgrzyma</h1>
"""

    last_group = None
    last_subgroup = None

    for hymn in hymns_info:
        # Add group header if changed
        if last_group != hymn["group_name"]:
            html += f'    <h2>{escape(hymn["group_name"])}</h2>\n'
            last_group = hymn["group_name"]
            last_subgroup = None

        # Add subgroup header if changed
        if last_subgroup != hymn["subgroup_name"]:
            html += f'    <h3>{escape(hymn["subgroup_name"])}</h3>\n'
            last_subgroup = hymn["subgroup_name"]

        # Add hymn content
        html += f'    <div class="hymn-title">{escape(hymn["number"])}. {escape(hymn["title"])}</div>\n'
        html += '    <div class="hymn-text">'
        
        # Convert verses to paragraphs
        if hymn["number"] not in hymns_texts:
            continue
        for verse in hymns_texts[hymn["number"]]:
            html += f'        <p>{escape(verse)}</p>\n'
        
        html += '    </div>\n'

    # Close HTML document
    html += """</body>
</html>"""
    
    return html

if __name__ == "__main__":
    hymns_info = read_csv_to_dict("./assets/hymns.csv")
    hymns_texts = read_json_to_dict("./assets/hymns_texts.json")
    
    html_content = generate_html(hymns_info, hymns_texts)
    
    with open("./assets/hymns.html", "w", encoding="utf-8") as html_file:
        html_file.write(html_content)
    print("HTML file generated successfully!")
