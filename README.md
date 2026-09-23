# Ground

## 📋 Описание проекта
<!-- Краткое описание проекта -->

## 🛠 Требования
- 1С:Предприятие 8.5 (учебная версия)
- OneScript (для Vanessa-ADD)
- Python 3.14+ (для scripts/loaders)
- Git

## 📁 Структура проекта

```
Ground/
├── src/1c/                  # ИСТОЧНИК ИСТИНЫ — дамп конфигурации
│   ├── Configuration.xml
│   ├── Catalogs/
│   ├── Documents/
│   ├── CommonModules/
│   └── ...
├── bin/                     # стабильные скрипты: push.sh, pull.sh
│   └── .env                 # локальные пути (IB, Vanessa-ADD) — НЕ в git
├── scripts/                 # расходный материал для отладки, не трогая src/
│   ├── epf/                 # внешние обработки
│   ├── loaders/              # python: загрузка seed-данных в ИБ
│   └── oscript/
├── data/seed/                 # начальные данные — по объекту метаданных
│   ├── catalogs/
│   ├── documents/
│   └── ...
├── tests/
│   ├── features/               # .feature-сценарии Vanessa-ADD (Gherkin)
│   │   └── step_definitions/
│   └── fixtures/
├── docs/
│   ├── notes/                    # md-конспекты, логи общения с AI
│   ├── diagrams/                  # html/png-схемы
│   └── reference/                  # официальная документация (не в git, см. LINKS.md)
├── var/{log,tmp}/                    # runtime-артефакты, не в git
├── .gitignore
├── .gitattributes
└── README.md
```

Инфобаза для разработки хранится ВНЕ репозитория: `~/IB/ground`.
Путь параметризован в `bin/.env` (создаётся из `bin/.env.example`).

## 🚀 Быстрый старт

```bash
cp bin/.env.example bin/.env
# отредактируйте bin/.env: путь к ИБ и к бинарнику Конфигуратора (DESIGNER_BIN)

# 1) создайте пустую ИБ вручную через Конфигуратор (разовое действие для
#    каждой новой ИБ — этот шаг сознательно не автоматизирован)
# 2) создайте первый объект метаданных руками в Конфигураторе
# 3) заберите его в src/1c:
./bin/pull.sh
# 4) правьте .bsl в VS Code, затем накатите обратно в ИБ:
./bin/push.sh
```

## 📚 Документация
- [Конспекты](docs/notes/)
- [Схемы](docs/diagrams/)
- [Ссылки на официальную документацию](docs/reference/LINKS.md)

## 📝 Лицензия
<!-- Учебный проект -->
