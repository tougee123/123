#!/bin/bash
set -euo pipefail

ROOT_DIR="${GITHUB_WORKSPACE:-$(pwd)}"
PROJECT_DIR_DEFAULT="CmdCode_20260317"
ZIP_FILE_DEFAULT="CmdCode_20260317_fixed.zip"

PROJECT_DIR="${1:-$PROJECT_DIR_DEFAULT}"
ZIP_FILE="${2:-$ZIP_FILE_DEFAULT}"

resolve_project_dir() {
  if [ -d "$ROOT_DIR/$PROJECT_DIR" ]; then
    printf '%s\n' "$ROOT_DIR/$PROJECT_DIR"
    return 0
  fi

  if [ -f "$ROOT_DIR/$ZIP_FILE" ]; then
    local unzip_dir
    unzip_dir="$(mktemp -d "${RUNNER_TEMP:-/tmp}/cmdcode-ci.XXXXXX")"
    unzip -q "$ROOT_DIR/$ZIP_FILE" -d "$unzip_dir"
    local detected
    detected="$(find "$unzip_dir" -maxdepth 2 -type d -name '*.xcodeproj' -exec dirname {} \; | head -n 1)"
    if [ -n "$detected" ]; then
      printf '%s\n' "$detected"
      return 0
    fi
  fi

  echo "Unable to find project directory '$PROJECT_DIR' or zip '$ZIP_FILE'." >&2
  exit 1
}

PROJECT_PATH="$(resolve_project_dir)"
BUILD_DIR="$ROOT_DIR/build-ci"
ARCHIVE_PATH="$BUILD_DIR/CmdCode-ios12.xcarchive"
PAYLOAD_DIR="$BUILD_DIR/Payload"
IPA_PATH="$BUILD_DIR/CmdCode-ios12-unsigned.ipa"

echo "Using project path: $PROJECT_PATH"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$PROJECT_PATH"

if [ -f "Podfile" ]; then
  pod install
fi

WORKSPACE_PATH="CmdCode.xcworkspace"
PROJECT_PATH_FILE="CmdCode.xcodeproj"
SCHEME="CmdCode"

if [ -d "$WORKSPACE_PATH" ]; then
  XCODE_TARGET_ARGS=(-workspace "$WORKSPACE_PATH")
else
  XCODE_TARGET_ARGS=(-project "$PROJECT_PATH_FILE")
fi

xcodebuild \
  "${XCODE_TARGET_ARGS[@]}" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -derivedDataPath "$BUILD_DIR/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  clean archive

mkdir -p "$PAYLOAD_DIR"
cp -R "$ARCHIVE_PATH/Products/Applications/CmdCode.app" "$PAYLOAD_DIR/"

(
  cd "$BUILD_DIR"
  zip -qry "$(basename "$IPA_PATH")" Payload
)

echo "MinimumOSVersion:"
/usr/libexec/PlistBuddy -c 'Print :MinimumOSVersion' "$PAYLOAD_DIR/CmdCode.app/Info.plist"

echo "IPA created at: $IPA_PATH"
