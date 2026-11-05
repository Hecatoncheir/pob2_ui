#!/bin/sh
set -eu
package=$1
bundle=$2
old_pid=$3
case "$bundle" in *.app) ;; *) exit 2 ;; esac
case "$old_pid" in *[!0-9]*|'') exit 2 ;; esac
parent=$(dirname "$bundle")
test -w "$parent"
mount=$(mktemp -d "${TMPDIR:-/tmp}/pob2-update.XXXXXX")
stage=$(mktemp -d "$parent/.pob2-stage.XXXXXX")
backup="$bundle.previous"
swapped=0
confirmed=0
cleanup() {
  /usr/bin/hdiutil detach "$mount" -quiet 2>/dev/null || true
  if [ "$swapped" = 1 ] && [ "$confirmed" = 0 ] && [ -d "$backup" ]; then
    mv "$bundle" "$stage/failed.app" || true
    mv "$backup" "$bundle"
    /usr/bin/open "$bundle"
  fi
}
trap cleanup EXIT
/usr/bin/hdiutil attach "$package" -readonly -nobrowse -mountpoint "$mount" -quiet
source="$mount/PoB II.app"
identifier=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$source/Contents/Info.plist")
[ "$identifier" = 'dev.hecatoncheir.pob2Ui' ]
/usr/bin/codesign --verify --deep --strict "$source"
old_team=$(/usr/bin/codesign -dv "$bundle" 2>&1 | sed -n 's/^TeamIdentifier=//p')
new_team=$(/usr/bin/codesign -dv "$source" 2>&1 | sed -n 's/^TeamIdentifier=//p')
if [ -n "$old_team" ] && [ "$old_team" != 'not set' ]; then [ "$old_team" = "$new_team" ]; fi
/usr/bin/ditto "$source" "$stage/new.app"
/usr/bin/codesign --verify --deep --strict "$stage/new.app"
attempts=0
while kill -0 "$old_pid" 2>/dev/null; do
  attempts=$((attempts + 1)); [ "$attempts" -lt 60 ]; sleep 1
done
if [ -e "$backup" ]; then mv "$backup" "$stage/older.app"; fi
mv "$bundle" "$backup"
swapped=1
mv "$stage/new.app" "$bundle"
token=$(/usr/bin/openssl rand -hex 16)
data="${POB2_UI_HOME:-$HOME/Library/Application Support/pob2_ui}"
mkdir -p "$data/updates"
health="$data/updates/health-$token.ready"
nohup "$bundle/Contents/MacOS/PoB II" --pob-update-token "$token" > "$data/updates/macos.log" 2>&1 < /dev/null &
new_pid=$!
attempts=0
while [ "$attempts" -lt 30 ]; do
  if [ -f "$health" ]; then confirmed=1; break; fi
  kill -0 "$new_pid" 2>/dev/null || break
  attempts=$((attempts + 1)); sleep 1
done
if [ "$confirmed" = 0 ]; then kill "$new_pid" 2>/dev/null || true; exit 1; fi
exit 0
