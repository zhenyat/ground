#!/usr/bin/env bash
###############################################################################
# pull.sh
#
# Выгружает конфигурацию из рабочей ИБ в файловый дамп src/1c через
# batch-режим Конфигуратора (/DumpConfigToFiles). См. пояснение "почему не
# ibcmd" в push.sh — та же логика.
#
# Version: 2.4.2
# Author: Claude Sonnet 4.5
# Created at: 2026-09-05
# Last updated at: 2026-09-23 (ZT)
###############################################################################
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# shellcheck source=/dev/null
source "$SCRIPT_DIR/.env" 2>/dev/null || {
    echo "❌ Не найден bin/.env — скопируйте bin/.env.example и заполните пути"
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
    /Out "$LOG_PATH"

echo "✅ pull завершён, лог: $LOG_PATH — просмотрите git diff перед коммитом"
