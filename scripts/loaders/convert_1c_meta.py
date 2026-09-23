#!/usr/bin/env python3
# -*- coding: utf-8 -*-
###############################################################################
# convert_1c_meta.py
#
# Разбор Configuration.xml (после pull.sh) в сводку по составу метаданных.
#
# Version:          1.0
# Author:           Claude Sonnet 4.5
# Created at:       2026-09-05
# Last updated at:  2026-09-05
###############################################################################
"""Читает src/1c/Configuration.xml и печатает сводку по объектам метаданных."""

import sys
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict, Any, Optional


def find_configuration_xml() -> Optional[Path]:
    """Configuration.xml лежит прямо в src/1c/ (без вложенной Configuration/)."""
    candidate = Path("src/1c/Configuration.xml")
    return candidate if candidate.exists() else None


def parse_metadata(xml_path: Path) -> Optional[Dict[str, Any]]:
    try:
        tree = ET.parse(xml_path)
        root = tree.getroot()
        result: Dict[str, Any] = {
            "name": root.get("name", "Unknown"),
            "objects": {},
        }
        for child in root:
            tag = child.tag.split("}")[-1] if "}" in child.tag else child.tag
            result["objects"].setdefault(tag, []).append(child.get("name", ""))
        return result
    except ET.ParseError as e:
        print(f"❌ Ошибка парсинга XML: {e}", file=sys.stderr)
        return None


def main() -> None:
    config_path = find_configuration_xml()
    if not config_path:
        print("❌ src/1c/Configuration.xml не найден. Сначала выполните ./bin/pull.sh",
              file=sys.stderr)
        sys.exit(1)

    metadata = parse_metadata(config_path)
    if not metadata:
        sys.exit(1)

    total = sum(len(v) for v in metadata["objects"].values())
    print(f"📋 Конфигурация: {metadata['name']}")
    for obj_type, objects in metadata["objects"].items():
        if objects:
            print(f"  • {obj_type}: {len(objects)}")
    print(f"📈 Всего объектов: {total}")

    out_path = Path("var/tmp/metadata.json")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"💾 Сохранено: {out_path}")


if __name__ == "__main__":
    main()
