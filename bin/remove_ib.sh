#!/usr/bin/env bash
###############################################################################
# remove_ib.sh
#
# БЕЗВОЗВРАТНО удаляет каталог файловой ИБ (IB_PATH). Операция разрушающая,
# поэтому несколько предохранителей:
#   1) удаляется только путь строго внутри $HOME_1C/IB/ (не сам IB, не DUMP/,
#      без ".."); иначе отказ — удалите вручную, если путь задан осознанно;
#   2) в каталоге должен быть файл 1Cv8.1CD (признак файловой ИБ);
#   3) нужно ввести имя ИБ в ответ на запрос; ключ -y/--yes пропускает запрос
#      (для автоматизации).
# Запись об ИБ в списке баз стартера платформы и выгрузки в DUMP_DIR НЕ
# затрагиваются: запись удалите в стартере вручную.
#
# Использование: bin/remove_ib.sh [-y|--yes]
# Переменные (bin/.env): IB_NAME, IB_PATH=$HOME_1C/IB/$IB_NAME
# Лог:                   var/log/remove_ib.log (ДОПИСЫВАЕТСЯ, с датой: журнал
#                        разрушающих операций, в отличие от логов платформы)
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

ASSUME_YES=0
case "${1:-}" in
    "")       ;;
    -y|--yes) ASSUME_YES=1 ;;
    *)        echo "Использование: bin/remove_ib.sh [-y|--yes]"; exit 1 ;;
esac

LOG_PATH="$PROJECT_ROOT/var/log/remove_ib.log"
mkdir -p "$(dirname "$LOG_PATH")"

# Предохранитель 1: путь строго внутри $HOME_1C/IB/ (шаблон /?* требует хотя бы
# один символ после IB/, поэтому сам $HOME_1C/IB/ не проходит). Порядок веток
# важен: сначала запреты, потом разрешение.
case "$IB_PATH" in
    *..*)
        echo "❌ Отказ: IB_PATH содержит '..': $IB_PATH"; exit 1 ;;
    "$HOME_1C"/IB/DUMP|"$HOME_1C"/IB/DUMP/*)
        echo "❌ Отказ: IB_PATH указывает в каталог выгрузок: $IB_PATH"; exit 1 ;;
    "$HOME_1C"/IB/?*)
        ;;
    *)
        echo "❌ Отказ: IB_PATH ($IB_PATH) должен быть каталогом ИБ строго внутри"
        echo "   $HOME_1C/IB/ — если путь задан осознанно, удалите ИБ вручную."
        exit 1 ;;
esac

if [[ ! -e "$IB_PATH" ]]; then
    echo "ℹ️  ИБ не найдена, удалять нечего: $IB_PATH"
    exit 0
fi

# Предохранитель 2: это действительно файловая ИБ.
[[ -f "$IB_PATH/$IB_MARKER" ]] || {
    echo "❌ Отказ: в $IB_PATH нет файла $IB_MARKER — это не похоже на файловую ИБ."
    exit 1
}

# Предохранитель 3: подтверждение именем ИБ.
if (( ASSUME_YES == 0 )); then
    echo "⚠️  Будет БЕЗВОЗВРАТНО удалена ИБ: $IB_PATH ($(du -sh "$IB_PATH" | cut -f1))"
    read -r -p "Для подтверждения введите имя ИБ ($IB_NAME): " answer || answer=""
    if [[ "$answer" != "$IB_NAME" ]]; then
        echo "Отменено."
        printf '%s remove_ib: отменено, ИБ не удалена: %s\n' "$(date '+%F %T')" "$IB_PATH" >> "$LOG_PATH"
        exit 1
    fi
fi

# "--" — конец опций: путь, начинающийся с "-", не будет принят за ключ rm.
rm -rf -- "$IB_PATH"
printf '%s remove_ib: удалена ИБ %s\n' "$(date '+%F %T')" "$IB_PATH" >> "$LOG_PATH"

echo "✅ ИБ удалена: $IB_PATH (журнал: $LOG_PATH)"
echo "ℹ️  Запись об ИБ в списке баз стартера платформы удалите вручную."
