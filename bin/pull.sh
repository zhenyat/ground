#!/usr/bin/env bash
###############################################################################
# pull.sh
#
# Выгружает конфигурацию из рабочей ИБ в файловый дамп src/1c через
# batch-режим Конфигуратора (/DumpConfigToFiles). См. пояснение "почему не
# ibcmd" в push.sh — та же логика.
#
# Version:  3.1
# Author: Claude Sonnet 4.5 / Claude Sonnet 5.5
# Created: 2026-09-05
# Last updated: 2026-10-15
###############################################################################
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

[[ -f "$SCRIPT_DIR/.env" ]] || {
    echo "❌ Не найден bin/.env — скопируйте bin/.env.example и заполните пути"
    exit 1
}
# Без 2>/dev/null: синтаксические ошибки в .env должны быть видны, а не
# маскироваться под "файл не найден".
# shellcheck source=/dev/null
source "$SCRIPT_DIR/.env"

# Проверка обязательных переменных из .env. Конструкция  : "${VAR:?сообщение}"
# — bash-идиома: если VAR не задана или пуста, скрипт завершается с понятным
# сообщением (иначе пустой "$DESIGNER_BIN" дал бы невнятное "command not found").
: "${IB_PATH:?IB_PATH не задан в bin/.env}"
: "${DESIGNER_BIN:?DESIGNER_BIN не задан в bin/.env}"
[[ -x "$DESIGNER_BIN" ]] || {
    echo "❌ DESIGNER_BIN не найден или не исполняемый: $DESIGNER_BIN"
    exit 1
}

DEST_PATH="$PROJECT_ROOT/src/1c"
LOG_PATH="$PROJECT_ROOT/var/log/pull.log"
mkdir -p "$DEST_PATH" "$(dirname "$LOG_PATH")"

echo "📥 pull: $IB_PATH -> $DEST_PATH"

# См. предупреждение в push.sh — тот же статус "стандартно, но не проверено".
"$DESIGNER_BIN" DESIGNER \
    /F"$IB_PATH" \
    ${IB_USER:+/N"$IB_USER"} \
    ${IB_PASSWORD:+/P"$IB_PASSWORD"} \
    /DisableStartupDialogs \
    /DumpConfigToFiles "$DEST_PATH" \
    /Out "$LOG_PATH" || {
    # Конфигуратор пишет диагностику только в файл /Out, а не в консоль —
    # поэтому при ошибке показываем лог сами (set -e иначе завершил бы скрипт молча).
    echo "❌ Конфигуратор завершился с ошибкой, лог: $LOG_PATH"
    cat "$LOG_PATH" 2>/dev/null
    exit 1
}

echo "✅ pull завершён, лог: $LOG_PATH — просмотрите git diff перед коммитом"
