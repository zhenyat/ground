#!/usr/bin/env python3
# -*- coding: utf-8 -*-
###############################################################################
# convert_1c_meta.py
#
# Разбор Configuration.xml (после pull.sh) в сводку по составу метаданных.
#
# Version: 3.2
# Author:  Claude Sonnet 4.5 / Claude Sonnet 5.5
# Created: 2026-09-05
# Last updated: 2026-10-16
###############################################################################
"""Читает src/1c/Configuration.xml и печатает сводку по объектам метаданных.

Формат выгрузки платформы 8.5 (проверено на 8.5.1.1529, version="2.21"):

  MetaDataObject                 корень; namespace .../8.3/MDClasses
    Configuration                единственный потомок корня
      Properties
        Name                     имя конфигурации (ТЕКСТ тега, не атрибут!)
        CompatibilityMode, DefaultLanguage, ...
      ChildObjects               объекты верхнего уровня:
        <Language>Русский</Language>   тег = ВИД объекта, ТЕКСТ = его ИМЯ
        <Catalog>Номенклатура</Catalog>

Файл записан платформой в UTF-8 с BOM и CRLF — ElementTree читает такое как есть.
"""

import sys
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Dict, Any, List, Optional

# Корень проекта определяем от расположения САМОГО скрипта
# (scripts/loaders/convert_1c_meta.py -> parents[2]), а не от текущей папки:
# скрипт работает, откуда бы его ни запустили.
PROJECT_ROOT = Path(__file__).resolve().parents[2]


def find_configuration_xml() -> Optional[Path]:
    """Configuration.xml лежит прямо в src/1c/ (без вложенной Configuration/)."""
    candidate = PROJECT_ROOT / "src" / "1c" / "Configuration.xml"
    return candidate if candidate.exists() else None


def local_name(tag: str) -> str:
    """'{namespace}Catalog' -> 'Catalog'."""
    return tag.rsplit("}", 1)[-1]


def parse_metadata(xml_path: Path) -> Optional[Dict[str, Any]]:
    try:
        root = ET.parse(xml_path).getroot()
    except ET.ParseError as e:
        print(f"❌ Ошибка парсинга XML: {e}", file=sys.stderr)
        return None

    # "{*}" — подстановочный namespace (Python 3.8+): не привязываемся к
    # конкретной версии схемы выгрузки.
    cfg = root.find("{*}Configuration")
    if cfg is None:
        print("❌ В Configuration.xml нет элемента <Configuration> — "
              "формат выгрузки неожиданный", file=sys.stderr)
        return None

    props = cfg.find("{*}Properties")

    def prop(name: str) -> str:
        return (props.findtext("{*}" + name) or "").strip() if props is not None else ""

    objects: Dict[str, List[str]] = {}
    child_objects = cfg.find("{*}ChildObjects")
    if child_objects is not None:
        for child in child_objects:
            objects.setdefault(local_name(child.tag), []).append((child.text or "").strip())

    return {
        "name": prop("Name") or "Unknown",
        "format_version": root.get("version", ""),
        "compatibility_mode": prop("CompatibilityMode"),
        "default_language": prop("DefaultLanguage"),
        "objects": objects,
    }


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
    print(f"🔖 Формат выгрузки: {metadata['format_version']} | "
          f"режим совместимости: {metadata['compatibility_mode']} | "
          f"язык по умолчанию: {metadata['default_language']}")
    for obj_type in sorted(metadata["objects"]):
        names = metadata["objects"][obj_type]
        print(f"  • {obj_type}: {len(names)}")
    print(f"📈 Всего объектов: {total}")

    out_path = PROJECT_ROOT / "var" / "tmp" / "metadata.json"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"💾 Сохранено: {out_path.relative_to(PROJECT_ROOT)}")


if __name__ == "__main__":
    main()
