#!/bin/sh
# 수아의 스퀴시 만들기 설치 — curl -fsSL https://raw.githubusercontent.com/choisukjune/sua-squish-releases/main/install.sh | sh
#
# 브라우저로 받은 DMG 는 격리 표시가 붙어서, 공증하지 않은 앱이 처음 열 때
# 「Apple 이 확인할 수 없습니다」에 막힌다. curl 로 받은 파일엔 그 표시가 붙지 않는다.
#
# 하는 일: 최신 릴리스 DMG 받기 → 해시 대조 → 응용 프로그램 폴더에 넣기 → Claude Code 확인 → 열기.
# 손잡이: SQUISH_INSTALL_DIR(넣을 폴더) · SQUISH_NO_OPEN=1(열지 않기) · SQUISH_NO_PROMPT=1(묻지 않기)
set -eu

REL="https://github.com/choisukjune/sua-squish-releases/releases/latest/download"
DMG="SuaSquish-mac-arm64.dmg"
DEST="${SQUISH_INSTALL_DIR:-/Applications}"

say() { printf '  %s\n' "$*"; }
die() { printf '  ✘ %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "macOS 전용입니다."
[ "$(uname -m)" = "arm64" ] || die "Apple Silicon(M1 이후) 맥 전용입니다."

# 쓸 수 없으면 내 계정의 응용 프로그램 폴더로 (sudo 를 묻지 않는다)
if [ ! -w "$DEST" ]; then
  DEST="$HOME/Applications"
  mkdir -p "$DEST"
fi
APP="$DEST/SuaSquish.app"

if pgrep -f "$APP/Contents/MacOS/SuaSquish" >/dev/null 2>&1; then
  die "수아의 스퀴시 만들기가 켜져 있어요. 끄고(⌘Q) 다시 실행해 주세요."
fi

TMP=$(mktemp -d "${TMPDIR:-/tmp}/squish-install.XXXXXX")
MNT=""
cleanup() {
  [ -n "$MNT" ] && hdiutil detach -quiet "$MNT" >/dev/null 2>&1 || true
  rm -rf "$TMP"
}
trap cleanup EXIT INT TERM

printf '\n  수아의 스퀴시 만들기 설치\n\n'

say "받는 중…"
curl -fL --progress-bar -o "$TMP/$DMG" "$REL/$DMG" || die "DMG 를 받지 못했습니다."
curl -fsSL -o "$TMP/$DMG.sha256" "$REL/$DMG.sha256" || die "해시 파일을 받지 못했습니다."

want=$(cut -d' ' -f1 < "$TMP/$DMG.sha256")
got=$(shasum -a 256 "$TMP/$DMG" | cut -d' ' -f1)
[ "$want" = "$got" ] || die "받은 파일의 해시가 맞지 않습니다. 다시 시도해 주세요."
say "해시 확인 ✓"

MNT=$(hdiutil attach -nobrowse -readonly -noautoopen "$TMP/$DMG" | awk -F'\t' '/\/Volumes\// {print $NF; exit}')
[ -n "$MNT" ] && [ -d "$MNT/SuaSquish.app" ] || die "DMG 를 열지 못했습니다."

say "$DEST 에 넣는 중…"
rm -rf "$APP"
ditto "$MNT/SuaSquish.app" "$APP"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

ver=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist" 2>/dev/null || echo '')
say "설치했습니다: 수아의 스퀴시 만들기 ${ver} · $APP"

# Claude Code: 앱이 찾는 방식(로그인 셸)과 같게 찾는다. 없으면 원할 때만 공식 설치기를 돌린다.
CC_URL="https://claude.ai/install.sh"
cc=$(/bin/zsh -lic 'printf "__C=%s\n" "$(command -v claude)"' 2>/dev/null | sed -n 's/^__C=//p' | tail -n1 || true)
if [ -n "$cc" ]; then
  say "Claude Code 확인 ✓"
else
  printf '\n'
  say "Claude Code 가 없어요. 없어도 도안 고르기·꾸미기·인쇄는 모두 됩니다."
  say "「클로드에게 도안 부탁하기」를 쓰려면 Claude Code 가 필요해요."
  ans=""
  # 파이프로 들어온 스크립트라 답은 터미널에서 직접 받는다
  if [ "${SQUISH_NO_PROMPT:-}" != "1" ] && ( : < /dev/tty ) 2>/dev/null; then
    printf '  지금 설치할까요? 공식 설치 프로그램(%s)을 실행합니다 [y/N] ' "$CC_URL"
    read -r ans < /dev/tty || ans=""
  fi
  case "$ans" in
    y|Y|yes|YES)
      if curl -fsSL "$CC_URL" | bash; then
        say "Claude Code 를 설치했어요. 터미널에서 claude 를 한 번 실행해 로그인해 주세요."
      else
        say "Claude Code 를 설치하지 못했어요. 나중에: curl -fsSL $CC_URL | bash"
      fi ;;
    *)
      say "나중에 설치하려면: curl -fsSL $CC_URL | bash" ;;
  esac
  printf '\n'
fi

if [ "${SQUISH_NO_OPEN:-}" != "1" ]; then
  open "$APP"
  say "앱을 엽니다."
fi
printf '\n'
