#!/usr/bin/env bash
###############################################################################
# dump_ib.sh
#
# Выгружает конфигурацию ИБ в файлы (/DumpConfigToFiles) в DUMP_DIR — каталог
# ВНЕ репозитория: для разбора структуры и экспериментов. В отличие от pull.sh,
# который кладёт выгрузку в src/1c (источник истины под git), эта процедура
# репозиторий не затрагивает.
#
# Переменные (bin/.env): IB_NAME, IB_PATH, DUMP_DIR=$HOME_1C/IB/DUMP/$IB_NAME,
#                        DESIGNER_BIN, IB_USER, IB_PASSWORD
# Лог:                   var/log/dump_ib.log (перезаписывается)
#
# Каталог DUMP_DIR НЕ очищается: файлы объектов, удалённых в ИБ, останутся от
# прежней выгрузки. Для чистой выгрузки удалите каталог вручную.
#
# Version:  4.0.0
# Author: Claude Sonnet 5.5
# Created: 2026-10-19
# Last updated: 2026-10-21
###############################################################################
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# HOME_1C — глобальная переменная среды (export в ~/.zshrc). Проверяем её ДО
# чтения .env: пустая HOME_1C превратила бы IB_PATH в "/IB/<имя>" — путь в
# корне файловой системы (для remove_ib.sh это было бы опасно).
: "${HOME_1C:?HOME_1C не задана. Добавьте в ~/.zshrc: export HOME_1C=\$HOME/1C}"

case "$HOME_1C" in
    /*) ;;
    *)  echo "❌ HOME_1C должна быть абсолютным путём, сейчас: $HOME_1C"; exit 1 ;;
esac

[[ -f "$SCRIPT_DIR/.env" ]] || {
    echo "❌ Не найден bin/.env — скопируйте bin/.env.example и заполните пути"
    exit 1
}
# Без 2>/dev/null: ошибки синтаксиса .env должны быть видны.
# shellcheck source=/dev/null
source "$SCRIPT_DIR/.env"

: "${IB_NAME:?IB_NAME не задан в bin/.env}"
: "${IB_PATH:?IB_PATH не задан в bin/.env}"

# Файл-маркер файловой ИБ: платформа хранит данные в 1Cv8.1CD.
IB_MARKER="1Cv8.1CD"

: "${DESIGNER_BIN:?DESIGNER_BIN не задан в bin/.env}"
[[ -x "$DESIGNER_BIN" ]] || {
    echo "❌ DESIGNER_BIN не найден или не исполняемый: $DESIGNER_BIN"
    exit 1
}
: "${DUMP_DIR:?DUMP_DIR не задан в bin/.env}"

[[ -f "$IB_PATH/$IB_MARKER" ]] || {
    echo "❌ ИБ не найдена: $IB_PATH"
    echo "   Создайте её: bin/create_ib.sh"
    exit 1
}

LOG_PATH="$PROJECT_ROOT/var/log/dump_ib.log"
mkdir -p "$(dirname "$LOG_PATH")" "$DUMP_DIR"

if [[ -n "$(ls -A "$DUMP_DIR" 2>/dev/null)" ]]; then
    echo "⚠️  Каталог выгрузки не пуст: $DUMP_DIR"
    echo "   Старые файлы не удаляются (объекты, удалённые в ИБ, останутся)."
fi

echo "📦 dump_ib: $IB_PATH -> $DUMP_DIR"

# Набор аргументов — тот же, что в push.sh/pull.sh: /F"..." без пробела,
# /DisableStartupDialogs, опциональные /N и /P (пусто — аргумент не передаётся).
"$DESIGNER_BIN" DESIGNER \
    /F"$IB_PATH" \
    ${IB_USER:+/N"$IB_USER"} \
    ${IB_PASSWORD:+/P"$IB_PASSWORD"} \
    /DisableStartupDialogs \
    /DumpConfigToFiles "$DUMP_DIR" \
    /Out "$LOG_PATH" || {
    # Конфигуратор пишет диагностику только в файл /Out — показываем лог сами
    # (set -e иначе завершил бы скрипт молча).
    echo "❌ Конфигуратор завершился с ошибкой, лог: $LOG_PATH"
    cat "$LOG_PATH" 2>/dev/null
    exit 1
}

echo "✅ dump завершён, лог: $LOG_PATH"
echo "   Содержимое $DUMP_DIR:"
ls -1 "$DUMP_DIR" | sed 's/^/     /'
