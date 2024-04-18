#!/bin/bash

readonly CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly HUGO_CACHE_DIR="$HOME/.cache"

readonly FIXIT_VER="0.3.2"
readonly FIXIT_PATH="$CUR_DIR/.cache/FixIt"

readonly HUGO_VER="0.122.0"
readonly HUGO_PATH=hugo

readonly HUGO_SOURCE="$CUR_DIR/mysite"

go_status() {
  [ "$1" -eq 0 ] && echo "okay" || echo "failed"
}

go_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --install_hugo    Install the hugo extended deb"
  echo "  --install_fixit   Install the hugo theme - FixIt"
  echo "  --run             Run the hugo blog"
  echo "  --hugo            Mock hugo cmd"
  echo "    e.g."
  echo "    [*] hugo new documentation"
  echo "      ./go.sh --hugo new documentation/xxx.md"
  echo "    [*] hugo new posts"
  echo "      ./go.sh --hugo new posts/xxx.md"
  echo "    [*] hugo"
  echo "      ./go.sh --hugo"
  echo ""
  echo "  --help, -h        Show this help message"
}

go_install_hugo() {
  if [ -x "$(command -v hugo)" ]; then
    read -p "Hugo is already installed. Do you want to force reinstall? (y/n): " choice
    case "$choice" in
      y|Y )
        FORCE_INSTALL=true
  echo ""
  echo "  --help, -h        Show this help message"
}

go_install_hugo() {
  if [ -x "$(command -v hugo)" ]; then
    read -p "Hugo is already installed. Do you want to force reinstall? (y/n): " choice
    case "$choice" in
      y|Y )
        FORCE_INSTALL=true
        ;;
      n|N )
        return
        ;;
      * )
        echo "Invalid choice. Exiting."
        exit 1
        ;;
    esac
  fi

  LATEST_URL=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep -o "https://.*hugo_extended.*linux-amd64.deb")
  if [ -z "$LATEST_URL" ]; then
    echo "Failed to fetch latest Hugo version URL."
    exit 1
  fi

  STABLE_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VER}/hugo_extended_${HUGO_VER}_linux-amd64.deb"
  if [ "$STABLE_URL" != "$LATEST_URL" ]; then
    read -p "Hugo has new version. Do you want to force update to latest version? (y/n): " choice
    case "$choice" in
      y|Y)
        USE_LATEST_HUGO=true
        ;;
      n|N)
        USE_LATEST_HUGO=false
        LATEST_URL=$STABLE_URL
        ;;
      * )
        echo "Invalid choice. Exiting"
        exit 1
        ;;
    esac
  fi

  ARCHIVE_FILE="$HUGO_CACHE_DIR/$(basename $LATEST_URL)"
  if ! [ -f "$ARCHIVE_FILE" ]; then
    echo -n "Downloading Hugo deb: "
    wget "$LATEST_URL" -qO "$ARCHIVE_FILE"
    go_status $?
  fi

  echo -n "Install Hugo deb:"
  sudo dpkg -i "$ARCHIVE_FILE"
  go_status $?
}

go_install_fixit() {
  if [ -L "$FIXIT_PATH" -a -e "$FIXIT_PATH" ]; then
    read -p "FixIt is already installed. Do you want to force reinstall? (y/n): " choice
    case "$choice" in
      y|Y )
        FORCE_INSTALL=true
        ;;
      n|N )
        return
        ;;
      * )
        echo "Invalid choice. Exiting."
        exit 1
        ;;
    esac
  fi

  LATEST_URL=https://github.com/hugo-fixit/FixIt/archive/refs/tags/v${FIXIT_VER}.zip

  ARCHIVE_FILE="$HUGO_CACHE_DIR/$(basename $LATEST_URL)"
  if ! [ -f "$ARCHIVE_FILE" ]; then
    echo -n "Downloading Hugo theme - FixIt: "
    wget "$LATEST_URL" -qO "$ARCHIVE_FILE"
    go_status $?
  fi

  echo -n "Uncompress Hugo theme - FixIt: "
  unzip -q -o -d"$HUGO_CACHE_DIR/" $ARCHIVE_FILE
  go_status $?

  rm -rf $FIXIT_PATH
  mkdir -p $(dirname $FIXIT_PATH)
  ln -s "$HUGO_CACHE_DIR/FixIt-$FIXIT_VER" "$FIXIT_PATH"
}

go_run_hugo() {
  rm -rf "$HUGO_SOURCE/public"

  hugo server -D \
    --source "$HUGO_SOURCE" \
    --themesDir $(dirname $FIXIT_PATH) \
    --disableFastRender
}

go_hugo() {
  hugo "$@" \
    --source "$HUGO_SOURCE" \
    --themesDir $(dirname $FIXIT_PATH)
}

main() {
  case "$1" in
    --install_hugo)
      go_install_hugo
      ;;
    --install_fixit)
      go_install_fixit
      ;;
    --help|-h)
      go_usage
      ;;
    --sync)
      go_sync
      ;;
    --run)
      go_run_hugo
      ;;
    --hugo)
      shift 1
      go_hugo "$@"
      ;;
    *)
      echo "Unknown option: $1"
      go_usage
      exit 1
      ;;
  esac
}

main "$@"
