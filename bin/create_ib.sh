#!/usr/bin/env bash
###############################################################################
# create_ib.sh
#
# Создаёт пустую ФАЙЛОВУЮ информационную базу в IB_PATH из командной строки
# (режим CREATEINFOBASE платформы) — без ручной работы в Конфигураторе.
#
# Переменные (bin/.env): IB_NAME, IB_PATH=$HOME_1C/IB/$IB_NAME, DESIGNER_BIN
# Лог:                   var/log/create_ib.log (перезаписывается)
#
# ВАЖНО (язык конфигурации): он фиксируется при ПЕРВОМ обращении Конфигуратора
# к новой ИБ; без параметра /L ru это будет English (наблюдение на 8.5.1.1529).
# Поэтому после create_ib.sh выполните разовую ручную настройку языка
# (README, «Быстрый старт», шаг 3) и только потом pull.sh / dump_ib.sh.
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

LOG_PATH="$PROJECT_ROOT/var/log/create_ib.log"
mkdir -p "$(dirname "$LOG_PATH")" "$(dirname "$IB_PATH")"

# Повторное создание поверх существующей ИБ не нужно и опасно — отказываемся.
if [[ -e "$IB_PATH/$IB_MARKER" ]]; then
    echo "❌ ИБ уже существует: $IB_PATH"
    echo "   Чтобы создать заново, сначала удалите её: bin/remove_ib.sh"
    exit 1
fi

echo "🗄  create_ib: $IB_PATH"

# File="..." — строка соединения файловой ИБ: ключ и путь идут ОДНИМ аргументом.
# /Out — лог платформы в файл (на консоль Конфигуратор диагностику не пишет).
"$DESIGNER_BIN" CREATEINFOBASE File="$IB_PATH" /Out "$LOG_PATH" || {
    echo "❌ Не удалось создать ИБ, лог: $LOG_PATH"
    cat "$LOG_PATH" 2>/dev/null
    exit 1
}

# Платформа вернула успех — убеждаемся, что файл базы действительно появился.
[[ -f "$IB_PATH/$IB_MARKER" ]] || {
    echo "⚠️  Платформа сообщила об успехе, но $IB_MARKER в $IB_PATH не найден."
    echo "   Проверьте каталог и лог: $LOG_PATH"
    exit 1
}

echo "✅ ИБ создана: $IB_PATH (лог: $LOG_PATH)"
echo "➡️  Далее — разовая ручная настройка языка (README, шаг 3), затем bin/pull.sh"
