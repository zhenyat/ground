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
# Version:          2.4.2
# Author:           Claude Sonnet 4.5
# Created at:       2026-09-05
# Last updated at:  2026-09-23
###############################################################################
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/.env" 2>/dev/null || {
    echo "❌ Не найден bin/.env — скопируйте bin/.env.example и заполните пути"
    exit 1
}

SRC_PATH="$PROJECT_ROOT/src/1c"
LOG_PATH="$PROJECT_ROOT/var/log/push.log"
mkdir -p "$(dirname "$LOG_PATH")"

echo "📤 push: $SRC_PATH -> $IB_PATH"

# ВНИМАНИЕ: набор флагов /LoadConfigFromFiles + /UpdateDBCfg — стандартный,
# документированный на ИТС, но НЕ прогнан лично на 8.5.1.1150 — при первой
# ошибке пришлите содержимое $LOG_PATH, поправим конкретные флаги (например,
# может понадобиться /DisableStartupDialogs или явный -Extension).
"$DESIGNER_BIN" DESIGNER \
    /F"$IB_PATH" \
    ${IB_USER:+/N"$IB_USER"} \
    ${IB_PASSWORD:+/P"$IB_PASSWORD"} \
    /DisableStartupDialogs \
    /LoadConfigFromFiles "$SRC_PATH" \
    /UpdateDBCfg \
    /Out "$LOG_PATH"

echo "✅ push завершён, лог: $LOG_PATH"
