#!/bin/sh
set -eu
version='@VERSION@'
prefix="$HOME/.local/opt/pob2-ui"
wait_pid=''
relaunch=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --prefix) prefix=$2; shift 2 ;;
    --wait-pid) wait_pid=$2; shift 2 ;;
    --relaunch) relaunch=1; shift ;;
    *) echo 'Неизвестный параметр установщика' >&2; exit 2 ;;
  esac
done
case "$prefix" in /*) ;; *) echo 'Нужен абсолютный каталог установки' >&2; exit 2 ;; esac
case "$prefix" in *'"'*|*'\'*|*'%'*|*'
'*) echo 'Недопустимые символы в каталоге установки' >&2; exit 2 ;; esac
[ ! -L "$prefix" ] || { echo 'Каталог установки не должен быть ссылкой' >&2; exit 1; }
mkdir -p "$prefix"
prefix=$(cd "$prefix" && pwd -P)
marker='{"schema":1,"id":"dev.hecatoncheir.pob2Ui","kind":"linux-run"}'
if [ -e "$prefix/pob2-install.json" ]; then
  [ "$(cat "$prefix/pob2-install.json")" = "$marker" ] || { echo 'Каталог занят другим приложением' >&2; exit 1; }
elif [ -n "$(ls -A "$prefix")" ]; then
  echo 'Для первой установки выберите пустой каталог' >&2; exit 1
fi
mkdir "$prefix/.install-lock" || { echo 'Уже выполняется установка' >&2; exit 1; }
trap 'rmdir "$prefix/.install-lock"' EXIT
printf '%s\n' "$marker" > "$prefix/pob2-install.json"
for name in versions pending-version pending-version.tmp pob2-ui; do
  [ ! -L "$prefix/$name" ] || { echo 'Обнаружена ссылка в каталоге установки' >&2; exit 1; }
done
mkdir -p "$prefix/versions"
stage=$(mktemp -d "$prefix/versions/.stage-XXXXXX")
line=$(awk '/^__POB2_PAYLOAD__$/ {print NR + 1; exit}' "$0")
tail -n +"$line" "$0" | tar -xz -C "$stage"
test -x "$stage/bundle/pob2_ui"
test -x "$stage/pob2-ui"
if [ ! -e "$prefix/versions/$version" ]; then mv "$stage/bundle" "$prefix/versions/$version"; fi
cp "$stage/pob2-ui" "$prefix/pob2-ui.new"
chmod 755 "$prefix/pob2-ui.new"
mv -f "$prefix/pob2-ui.new" "$prefix/pob2-ui"
printf '%s' "$version" > "$prefix/pending-version.tmp"
mv -f "$prefix/pending-version.tmp" "$prefix/pending-version"
applications="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$applications"
cat > "$applications/pob2-ui.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=PoB II
Comment=Мастерская сборок Path of Exile 2
Exec="$prefix/pob2-ui"
Icon=$prefix/versions/$version/data/flutter_assets/docs/assets/brand/app-icon.svg
Terminal=false
Categories=Game;Utility;
EOF
chmod 644 "$applications/pob2-ui.desktop"
if [ -n "$wait_pid" ]; then
  case "$wait_pid" in *[!0-9]*|'') exit 2 ;; esac
  attempts=0
  while kill -0 "$wait_pid" 2>/dev/null; do
    attempts=$((attempts + 1))
    [ "$attempts" -lt 60 ] || { echo 'Приложение не завершилось' >&2; exit 1; }
    sleep 1
  done
fi
echo "PoB II $version установлен: $prefix"
if [ "$relaunch" = 1 ]; then nohup "$prefix/pob2-ui" > "$prefix/launcher.log" 2>&1 < /dev/null & fi
exit 0
__POB2_PAYLOAD__
