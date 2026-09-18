#!/usr/bin/env bash
#
# build-deb.sh — package Amharic Keyboard (Flutter app + IBus engine)
# as an installable .deb for Ubuntu.
#
# Usage: ./packaging/build-deb.sh [version]
#   e.g. ./packaging/build-deb.sh 0.1.0
#
set -euo pipefail

APP_NAME="amharic-keyboard"
APP_VERSION="${1:-0.1.0}"
ARCH="amd64"
MAINTAINER="Mazengia Tesfa <you@example.com>"
ENGINE_COMPONENT_NAME="amharic_phonetic"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_DIR="$PROJECT_ROOT/build/linux/x64/release/bundle"
STAGE_DIR="$PROJECT_ROOT/packaging/stage"
DEB_OUT="$PROJECT_ROOT/packaging/${APP_NAME}_${APP_VERSION}_${ARCH}.deb"

INSTALL_PREFIX="/opt/${APP_NAME}"
ENGINE_PREFIX="/usr/lib/ibus-${APP_NAME}"

echo "==> Checking required tools..."
for cmd in flutter dpkg-deb; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: '$cmd' not found on PATH." >&2
    exit 1
  fi
done

echo "==> Building Flutter Linux release..."
cd "$PROJECT_ROOT"
flutter config --enable-linux-desktop >/dev/null
flutter build linux --release

if [ ! -d "$BUNDLE_DIR" ]; then
  echo "ERROR: build output not found at $BUNDLE_DIR" >&2
  exit 1
fi

BINARY_PATH="$(find "$BUNDLE_DIR" -maxdepth 1 -type f -executable | head -n1)"
BINARY_NAME="$(basename "$BINARY_PATH")"

echo "==> Staging package contents..."
rm -rf "$STAGE_DIR"
mkdir -p \
  "$STAGE_DIR/DEBIAN" \
  "$STAGE_DIR${INSTALL_PREFIX}" \
  "$STAGE_DIR${ENGINE_PREFIX}" \
  "$STAGE_DIR/usr/bin" \
  "$STAGE_DIR/usr/share/applications" \
  "$STAGE_DIR/usr/share/ibus/component"

# --- Flutter app bundle ---
cp -r "$BUNDLE_DIR"/* "$STAGE_DIR${INSTALL_PREFIX}/"

# --- Launcher wrapper ---
cat > "$STAGE_DIR/usr/bin/${APP_NAME}" <<EOF
#!/bin/sh
cd "${INSTALL_PREFIX}"
exec "${INSTALL_PREFIX}/${BINARY_NAME}" "\$@"
EOF
chmod 755 "$STAGE_DIR/usr/bin/${APP_NAME}"

# --- IBus engine (Python) ---
cp -r "$PROJECT_ROOT/engine" "$STAGE_DIR${ENGINE_PREFIX}/"
cp "$PROJECT_ROOT/ibus/amharic_engine.py" "$STAGE_DIR${ENGINE_PREFIX}/"

cat > "$STAGE_DIR${ENGINE_PREFIX}/ibus-engine-amharic" <<EOF
#!/bin/sh
exec /usr/bin/python3 "${ENGINE_PREFIX}/amharic_engine.py" "\$@"
EOF
chmod 755 "$STAGE_DIR${ENGINE_PREFIX}/ibus-engine-amharic"

# --- IBus component descriptor ---
cat > "$STAGE_DIR/usr/share/ibus/component/amharic.xml" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<component>
  <name>org.amharic.Keyboard</name>
  <description>Amharic Phonetic Keyboard</description>
  <exec>${ENGINE_PREFIX}/ibus-engine-amharic --ibus</exec>
  <version>${APP_VERSION}</version>
  <author>Mazengia Tesfa</author>
  <license>MIT</license>
  <homepage>https://mazengia-tesfa.vercel.app</homepage>
  <textdomain>ibus-amharic</textdomain>
  <engines>
    <engine>
      <name>${ENGINE_COMPONENT_NAME}</name>
      <language>am</language>
      <license>MIT</license>
      <author>Mazengia Tesfa</author>
      <longname>Amharic Phonetic</longname>
      <description>Amharic phonetic keyboard</description>
      <icon>ibus-engine-amharic</icon>
      <layout>default</layout>
    </engine>
  </engines>
</component>
EOF

# --- Desktop entry ---
cat > "$STAGE_DIR/usr/share/applications/${APP_NAME}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Amharic Keyboard
Comment=Amharic phonetic input method for Ubuntu
Exec=/usr/bin/${APP_NAME}
Terminal=false
Categories=Utility;
EOF

# --- Debian control metadata ---
cat > "$STAGE_DIR/DEBIAN/control" <<EOF
Package: ${APP_NAME}
Version: ${APP_VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: python3, python3-gi, gir1.2-ibus-1.0, ibus
Maintainer: ${MAINTAINER}
Description: Amharic phonetic keyboard for Ubuntu
 A Flutter desktop companion app and IBus engine that provide
 phonetic Amharic (Ethiopic) text input system-wide on Ubuntu,
 on both Xorg and Wayland sessions.
EOF

# --- Restart IBus after install ---
cat > "$STAGE_DIR/DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e
if command -v ibus >/dev/null 2>&1; then
  ibus restart || true
fi
exit 0
POSTINST
chmod 755 "$STAGE_DIR/DEBIAN/postinst"

echo "==> Building .deb..."
dpkg-deb --build --root-owner-group "$STAGE_DIR" "$DEB_OUT"

echo
echo "=========================================================="
echo " Built: $DEB_OUT"
echo
echo " Install with:"
echo "   sudo apt install \"$DEB_OUT\""
echo "=========================================================="
