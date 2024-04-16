#!/bin/bash

readonly FIXIT_VER="0.3.2"
readonly HUGO_CACHE_DIR="$HOME/.cache"
readonly CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

go_status() {
  [ "$1" -eq 0 ] && echo "okay" || echo "failed"
}

go_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --install_hugo    Install the hugo extended deb"
  echo "  --install_fixit   Install the hugo theme - FixIt"
  echo "  --run             Run the hugo blog"
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
  FIXIT_SRC="$CUR_DIR/.cache/FixIt"

  if [ -L "$FIXIT_SRC" -a -e "$FIXIT_SRC" ]; then
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

  rm -rf $FIXIT_SRC
  ln -s "$HUGO_CACHE_DIR/FixIt-$FIXIT_VER" "$FIXIT_SRC"
}

go_run_hugo() {
  HUGO_SOURCE="$CUR_DIR/mysite"

  rm -rf "$HUGO_SOURCE/public"

  hugo server -D \
    --source "$HUGO_SOURCE" \
    --bind 127.0.0.1 \
    --port 1313
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
    *)
      echo "Unknown option: $1"
      go_usage
      exit 1
      ;;
  esac
}

main "$@"
