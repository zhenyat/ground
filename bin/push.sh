#!/usr/bin/env bash
###############################################################################
# push.sh
#
# Загружает конфигурацию из src/1c (файлового дампа) в рабочую ИБ через
# batch-режим Конфигуратора (/LoadConfigFromFiles + /UpdateDBCfg).
#
# ПОЧЕМУ НЕ ibcmd: ibcmd — административная утилита уровня сервера/кластера;
# на учебной версии её функции автоматизации, похоже, урезаны лицензионно.
# Batch-режим Конфигуратора — это тот же исполняемый файл, что открывается
# по клику мышью, просто без GUI — работает на любой редакции одинаково.
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

SRC_PATH="$PROJECT_ROOT/src/1c"
LOG_PATH="$PROJECT_ROOT/var/log/push.log"
mkdir -p "$(dirname "$LOG_PATH")"

echo "📤 push: $SRC_PATH -> $IB_PATH"

# ВНИМАНИЕ: набор флагов /LoadConfigFromFiles + /UpdateDBCfg — стандартный,
# документированный на ИТС, но НЕ прогнан лично на 8.5.1.1529 — при первой
# ошибке пришлите содержимое $LOG_PATH, поправим конкретные флаги (например,
# может понадобиться /DisableStartupDialogs или явный -Extension).
"$DESIGNER_BIN" DESIGNER \
    /F"$IB_PATH" \
    ${IB_USER:+/N"$IB_USER"} \
    ${IB_PASSWORD:+/P"$IB_PASSWORD"} \
    /DisableStartupDialogs \
    /LoadConfigFromFiles "$SRC_PATH" \
    /UpdateDBCfg \
    /Out "$LOG_PATH" || {
    # Конфигуратор пишет диагностику только в файл /Out, а не в консоль —
    # поэтому при ошибке показываем лог сами (set -e иначе завершил бы скрипт молча).
    echo "❌ Конфигуратор завершился с ошибкой, лог: $LOG_PATH"
    cat "$LOG_PATH" 2>/dev/null
    exit 1
}

echo "✅ push завершён, лог: $LOG_PATH"
