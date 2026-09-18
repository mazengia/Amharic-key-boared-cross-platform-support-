#!/usr/bin/env bash
#
# install-dev.sh — build and install Amharic Keyboard straight onto
# this machine (no .deb). Good for fast iteration during development.
#
# Usage: ./packaging/install-dev.sh
#
set -euo pipefail

APP_NAME="amharic-keyboard"
ENGINE_COMPONENT_NAME="amharic_phonetic"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_PREFIX="/opt/${APP_NAME}"
ENGINE_PREFIX="/usr/lib/ibus-${APP_NAME}"

echo "==> Checking required tools..."
for cmd in flutter python3 dpkg; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: '$cmd' not found on PATH." >&2
    exit 1
  fi
done

echo "==> Checking IBus python bindings..."
if ! python3 -c "import gi; gi.require_version('IBus', '1.0'); from gi.repository import IBus" 2>/dev/null; then
  echo "ERROR: python3-gi / gir1.2-ibus-1.0 not installed." >&2
  echo "Run: sudo apt install python3-gi gir1.2-ibus-1.0 ibus" >&2
  exit 1
fi

echo "==> Building Flutter Linux release..."
cd "$PROJECT_ROOT"
flutter config --enable-linux-desktop >/dev/null
flutter build linux --release

BUNDLE_DIR="$PROJECT_ROOT/build/linux/x64/release/bundle"

if [ ! -d "$BUNDLE_DIR" ]; then
  echo "ERROR: build output not found at $BUNDLE_DIR" >&2
  exit 1
fi

BINARY_PATH="$(find "$BUNDLE_DIR" -maxdepth 1 -type f -executable | head -n1)"
BINARY_NAME="$(basename "$BINARY_PATH")"

echo "==> Installing app to $INSTALL_PREFIX ..."
sudo rm -rf "$INSTALL_PREFIX"
sudo mkdir -p "$INSTALL_PREFIX"
sudo cp -r "$BUNDLE_DIR"/* "$INSTALL_PREFIX/"

sudo tee /usr/bin/"$APP_NAME" > /dev/null <<EOF
#!/bin/sh
cd "$INSTALL_PREFIX"
exec "$INSTALL_PREFIX/$BINARY_NAME" "\$@"
EOF
sudo chmod +x /usr/bin/"$APP_NAME"

echo "==> Installing IBus engine to $ENGINE_PREFIX ..."
sudo rm -rf "$ENGINE_PREFIX"
sudo mkdir -p "$ENGINE_PREFIX"
sudo cp -r "$PROJECT_ROOT/engine" "$ENGINE_PREFIX/"
sudo cp "$PROJECT_ROOT/ibus/amharic_engine.py" "$ENGINE_PREFIX/"

sudo tee "$ENGINE_PREFIX/ibus-engine-amharic" > /dev/null <<EOF
#!/bin/sh
exec /usr/bin/python3 "$ENGINE_PREFIX/amharic_engine.py" "\$@"
EOF
sudo chmod +x "$ENGINE_PREFIX/ibus-engine-amharic"

echo "==> Registering IBus component..."
sudo mkdir -p /usr/share/ibus/component
sudo tee /usr/share/ibus/component/amharic.xml > /dev/null <<EOF
<?xml version="1.0" encoding="utf-8"?>
<component>
  <name>org.amharic.Keyboard</name>
  <description>Amharic Phonetic Keyboard</description>
  <exec>${ENGINE_PREFIX}/ibus-engine-amharic --ibus</exec>
  <version>0.1.0</version>
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

echo "==> Installing desktop launcher entry..."
sudo tee /usr/share/applications/"$APP_NAME".desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=Amharic Keyboard
Comment=Amharic phonetic input method for Ubuntu
Exec=/usr/bin/${APP_NAME}
Terminal=false
Categories=Utility;
EOF

echo "==> Restarting IBus..."
if ! ibus restart 2>/dev/null; then
  echo "Could not restart via 'ibus restart' - starting the daemon directly."
  ibus-daemon -drx || true
fi

echo
echo "=========================================================="
echo " Installed."
echo
echo " Launch the app with:      ${APP_NAME}"
echo " Or find it in the app grid as: Amharic Keyboard"
echo
echo " To add the input source system-wide:"
echo "   Settings -> Region & Language -> Input Sources -> +"
echo "   -> Other -> Amharic (Phonetic) [Amharic Keyboard]"
echo "=========================================================="
