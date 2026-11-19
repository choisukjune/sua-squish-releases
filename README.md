# 수아의 스퀴시 만들기 · 설치 파일

둘째 딸 수아의 생일을 기념해서 만든 종이 스퀴시 도안 앱의 설치 파일만 두는 곳입니다. 소스는 여기 없습니다.

모양(직육면체·정육면체·우유팩·원통·컵·삼각기둥·납작 스퀴시)을 고르고, 면마다 그림·색·글자를 넣으면 자르는 선·접는 선·풀칠 날개가 들어간 A4 도안이 나옵니다. 사진이나 그림을 주면 Claude Code가 어울리는 도안을 골라 꾸며 주기도 합니다.

## 설치

터미널을 열고 한 줄을 붙여 넣으면 됩니다.

```sh
curl -fsSL https://raw.githubusercontent.com/choisukjune/sua-squish-releases/main/install.sh | sh
```

최신 판을 받아 해시를 확인하고 `/Applications/SuaSquish.app`에 넣은 뒤 앱을 엽니다. Finder와 Dock에는 "수아의 스퀴시 만들기"로 보입니다. `/Applications`에 쓸 수 없으면 `~/Applications`에 넣습니다.

- macOS, Apple Silicon(M1 이후) 맥 전용입니다.
- 「클로드에게 도안 부탁하기」를 쓰려면 [Claude Code](https://claude.ai/install.sh)가 설치돼 있고 로그인돼 있어야 합니다. 설치 중에 Claude Code가 없으면 지금 깔지 물어봅니다. 없어도 나머지 기능은 모두 됩니다.

## 업데이트

앱을 끄고(⌘Q) 설치 한 줄을 다시 실행하면 같은 자리에 새 판이 덮어 깔립니다.

다른 폴더에 깔아 두었다면 그 폴더를 알려 주세요.

```sh
curl -fsSL https://raw.githubusercontent.com/choisukjune/sua-squish-releases/main/install.sh | SQUISH_INSTALL_DIR="$HOME/원하는/폴더" sh
```

지금 판 확인:

```sh
defaults read /Applications/SuaSquish.app/Contents/Info CFBundleShortVersionString
```

## DMG를 브라우저로 받았다면

[릴리스](https://github.com/choisukjune/sua-squish-releases/releases/latest)에서 `SuaSquish-mac-arm64.dmg`를 받아 열고, 앱을 Applications로 끌어 넣습니다. 공증하지 않은 앱이라 처음 열 때 「확인할 수 없는 개발자」로 막히는데, 아래 한 줄로 격리 표시를 지우면 열립니다. 설치 한 줄로 깔면 이 과정이 필요 없습니다.

```sh
xattr -dr com.apple.quarantine /Applications/SuaSquish.app
```

## 지우기

```sh
rm -rf /Applications/SuaSquish.app
```
