#!/usr/bin/env python3

import os
import sys
import time
from pathlib import Path

import gi

gi.require_version("IBus", "1.0")
from gi.repository import IBus, GLib


# ============================================================
# Project paths
#
# This script needs to find transliterator.py regardless of which
# layout it's running from:
#   - dev checkout:  project/ibus/amharic_engine.py + project/engine/
#   - installed:     .../amharic_engine.py + ./engine/ (sibling dir,
#                     not parent-of-parent)
#
# Rather than hard-coding one relationship between the two, check
# every plausible location and use whichever one actually has the
# module in it.
# ============================================================

SCRIPT_DIR = Path(__file__).resolve().parent

_engine_dir_candidates = [
    SCRIPT_DIR / "engine",       # installed layout (sibling subdir)
    SCRIPT_DIR.parent / "engine",  # dev layout (project/ibus + project/engine)
    SCRIPT_DIR,                  # transliterator.py alongside this script
]

ENGINE_DIR = next(
    (p for p in _engine_dir_candidates if (p / "transliterator.py").is_file()),
    None,
)

if ENGINE_DIR is None:
    print(
        "FATAL: could not find transliterator.py in any of: "
        + ", ".join(str(p) for p in _engine_dir_candidates),
        flush=True,
    )
    sys.exit(1)

sys.path.insert(0, str(ENGINE_DIR))

from transliterator import Transliterator


# ============================================================
# IBus configuration
# ============================================================

ENGINE_NAME = "amharic_phonetic"
COMPONENT_NAME = "org.amharic.Keyboard"

transliterator = Transliterator()


# ============================================================
# Session diagnostics
#
# Xorg and Wayland deliver key/focus events differently.
# Apps running under XWayland (most non-native-Wayland apps)
# can, on some compositors, cause the *same* key event to
# reach the engine twice. Logging the session type up front
# makes that easy to diagnose if it ever comes back.
# ============================================================

SESSION_TYPE = os.environ.get("XDG_SESSION_TYPE", "unknown")
WAYLAND_DISPLAY = os.environ.get("WAYLAND_DISPLAY", "")


# ============================================================
# Key definitions
# ============================================================

BACKSPACE = IBus.keyval_from_name("BackSpace")
ESCAPE = IBus.keyval_from_name("Escape")

RETURN = IBus.keyval_from_name("Return")
KP_ENTER = IBus.keyval_from_name("KP_Enter")

SPACE = IBus.keyval_from_name("space")
KP_SPACE = IBus.keyval_from_name("KP_Space")

TAB = IBus.keyval_from_name("Tab")
KP_TAB = IBus.keyval_from_name("KP_Tab")


# Modifier keys
SHIFT_L = IBus.keyval_from_name("Shift_L")
SHIFT_R = IBus.keyval_from_name("Shift_R")

CONTROL_L = IBus.keyval_from_name("Control_L")
CONTROL_R = IBus.keyval_from_name("Control_R")

ALT_L = IBus.keyval_from_name("Alt_L")
ALT_R = IBus.keyval_from_name("Alt_R")

SUPER_L = IBus.keyval_from_name("Super_L")
SUPER_R = IBus.keyval_from_name("Super_R")

CAPS_LOCK = IBus.keyval_from_name("Caps_Lock")
NUM_LOCK = IBus.keyval_from_name("Num_Lock")
SCROLL_LOCK = IBus.keyval_from_name("Scroll_Lock")


MODIFIER_KEYS = {
    SHIFT_L,
    SHIFT_R,
    CONTROL_L,
    CONTROL_R,
    ALT_L,
    ALT_R,
    SUPER_L,
    SUPER_R,
    CAPS_LOCK,
    NUM_LOCK,
    SCROLL_LOCK,
}


# ============================================================
# Amharic IBus Engine
# ============================================================

class AmharicEngine(IBus.Engine):

    def __init__(self, connection, object_path):

        super().__init__(
            connection=connection,
            object_path=object_path,
        )

        self.preedit = ""

        # ----------------------------------------------------
        # Duplicate-event protection
        #
        # On XWayland (the compatibility layer most non-native
        # Wayland apps still run through), the same physical
        # keypress can be delivered to the engine twice in
        # quick succession. On plain Xorg this basically never
        # happens, so this guard is a no-op there and safe to
        # always keep on.
        # ----------------------------------------------------

        self._reset_dedupe_state()

        # 50 milliseconds.
        #
        # Two identical events inside this very small window
        # are treated as a duplicate event.
        self.DUPLICATE_EVENT_WINDOW = 0.050

        print(
            f"AmharicEngine initialized: {object_path} "
            f"(session={SESSION_TYPE}, wayland_display={WAYLAND_DISPLAY!r})",
            flush=True,
        )

    # ========================================================
    # Dedupe state helpers
    # ========================================================

    def _reset_dedupe_state(self):
        self.last_keyval = None
        self.last_keycode = None
        self.last_state = None
        self.last_event_time = 0.0

    # ========================================================
    # Duplicate event detection
    # ========================================================

    def is_duplicate_event(self, keyval, keycode, state):

        now = time.monotonic()

        same_event = (
            self.last_keyval == keyval
            and self.last_keycode == keycode
            and self.last_state == state
        )

        too_fast = (
            now - self.last_event_time
            < self.DUPLICATE_EVENT_WINDOW
        )

        if same_event and too_fast:

            print(
                "Ignoring duplicate key event: "
                f"keyval={keyval}, "
                f"keycode={keycode}, "
                f"state={state}",
                flush=True,
            )

            self.last_event_time = now

            return True

        self.last_keyval = keyval
        self.last_keycode = keycode
        self.last_state = state
        self.last_event_time = now

        return False

    # ========================================================
    # Key event processing
    # ========================================================

    def do_process_key_event(
        self,
        keyval,
        keycode,
        state,
    ):

        try:
            return self._process_key_event(keyval, keycode, state)
        except Exception as exc:
            # A crash here can take the whole IBus daemon's
            # connection to this engine down with it, on either
            # session type. Never let an unexpected error escape.
            print(
                f"Unhandled error in do_process_key_event: {exc}",
                flush=True,
            )
            return False

    def _process_key_event(
        self,
        keyval,
        keycode,
        state,
    ):

        # ----------------------------------------------------
        # Ignore key release events.
        # ----------------------------------------------------

        if state & IBus.ModifierType.RELEASE_MASK:

            return False


        # ----------------------------------------------------
        # Ignore modifier keys.
        # ----------------------------------------------------

        if keyval in MODIFIER_KEYS:

            return False


        # ----------------------------------------------------
        # Ignore duplicate press events.
        # ----------------------------------------------------

        if self.is_duplicate_event(
            keyval,
            keycode,
            state,
        ):

            return True


        # ====================================================
        # Backspace
        # ====================================================

        if keyval == BACKSPACE:

            if self.preedit:

                self.preedit = self.preedit[:-1]

                self.update_preedit()

                return True

            return False


        # ====================================================
        # Escape
        # ====================================================

        if keyval == ESCAPE:

            if self.preedit:

                self.preedit = ""

                self.update_preedit()

                return True

            return False


        # ====================================================
        # Enter
        # ====================================================

        if keyval in (RETURN, KP_ENTER):

            if self.preedit:

                self.commit_preedit()

            self.commit_text(
                IBus.Text.new_from_string("\n")
            )

            return True


        # ====================================================
        # Space
        # ====================================================

        if keyval in (SPACE, KP_SPACE):

            if self.preedit:

                self.commit_preedit()

            self.commit_text(
                IBus.Text.new_from_string(" ")
            )

            return True


        # ====================================================
        # Tab
        # ====================================================

        if keyval in (TAB, KP_TAB):

            if self.preedit:

                self.commit_preedit()

            # Let the application handle Tab.
            return False


        # ====================================================
        # Convert IBus keyval to Unicode
        #
        # Do NOT use:
        #
        #     chr(keyval)
        #
        # because an IBus keyval is not always a Unicode
        # codepoint (this is what breaks on function keys,
        # arrow keys, etc. and is a real risk on Wayland where
        # extra synthetic keyvals can show up via XWayland).
        # ====================================================

        try:

            character = IBus.keyval_to_unicode(keyval)

        except Exception as exc:

            print(
                f"Unable to convert keyval {keyval}: {exc}",
                flush=True,
            )

            return False


        # No character.
        if not character:

            return False


        # Only process ASCII input.
        if not character.isascii():

            return False


        # Only printable characters.
        if not character.isprintable():

            return False


        # ====================================================
        # Add character to Latin preedit
        # ====================================================

        character = character.lower()

        self.preedit += character

        print(
            f"Key: '{character}' "
            f"-> preedit='{self.preedit}'",
            flush=True,
        )

        self.update_preedit()

        return True


    # ========================================================
    # Update IBus preedit
    # ========================================================

    def update_preedit(self):

        if not self.preedit:

            self.update_preedit_text(
                IBus.Text.new_from_string(""),
                0,
                False,
            )

            return


        # ----------------------------------------------------
        # Transliterate Latin input to Amharic.
        # ----------------------------------------------------

        amharic = transliterator.transliterate(
            self.preedit
        )


        # ----------------------------------------------------
        # Show Amharic as preedit.
        # ----------------------------------------------------

        self.update_preedit_text(
            IBus.Text.new_from_string(amharic),
            len(amharic),
            True,
        )


    # ========================================================
    # Commit current preedit
    # ========================================================

    def commit_preedit(self):

        if not self.preedit:

            return


        amharic = transliterator.transliterate(
            self.preedit
        )


        self.commit_text(
            IBus.Text.new_from_string(amharic)
        )


        self.preedit = ""


        self.update_preedit()


    # ========================================================
    # Focus handling
    #
    # Window-focus events are where Xorg and Wayland diverge
    # the most (different window managers / compositors fire
    # them with different timing and, under XWayland, sometimes
    # twice). Always clearing state on focus change - rather
    # than trusting stray leftover preedit - keeps behavior
    # identical no matter which session type is running.
    # ====================================================

    def do_focus_in(self):

        self.preedit = ""

        self._reset_dedupe_state()

        self.update_preedit()

        super().do_focus_in()

    def do_focus_out(self):

        # Commit whatever was typed rather than silently
        # dropping it when focus leaves the text field.
        self.commit_preedit()

        self._reset_dedupe_state()

        super().do_focus_out()


    # ========================================================
    # Reset
    # ========================================================

    def do_reset(self):

        self.preedit = ""

        self._reset_dedupe_state()

        self.update_preedit()

        super().do_reset()


    # ========================================================
    # Disable
    # ========================================================

    def do_disable(self):

        self.preedit = ""

        self._reset_dedupe_state()

        self.update_preedit()

        super().do_disable()


    # ========================================================
    # Destroy
    # ========================================================

    def do_destroy(self):

        self.preedit = ""

        self._reset_dedupe_state()

        super().do_destroy()


# ============================================================
# Main
# ============================================================

def main():

    print(
        "Initializing IBus...",
        flush=True,
    )

    print(
        f"Detected session: XDG_SESSION_TYPE={SESSION_TYPE!r}, "
        f"WAYLAND_DISPLAY={WAYLAND_DISPLAY!r}",
        flush=True,
    )

    IBus.init()


    # --------------------------------------------------------
    # Connect to IBus
    # --------------------------------------------------------

    bus = IBus.Bus()


    if not bus.is_connected():

        print(
            "ERROR: Could not connect to IBus. On Wayland sessions, "
            "make sure ibus-daemon is running (it isn't always "
            "autostarted the same way it is under Xorg) - try "
            "'ibus-daemon -drx' first.",
            flush=True,
        )

        return 1


    print(
        "Connected to IBus.",
        flush=True,
    )


    # --------------------------------------------------------
    # Get D-Bus connection
    # --------------------------------------------------------

    connection = bus.get_connection()


    print(
        "Creating IBus factory...",
        flush=True,
    )


    factory = IBus.Factory.new(connection)


    print(
        "IBus factory created.",
        flush=True,
    )


    # --------------------------------------------------------
    # Register engine.
    # --------------------------------------------------------

    factory.add_engine(
        ENGINE_NAME,
        AmharicEngine,
    )


    print(
        f"Engine registered: {ENGINE_NAME}",
        flush=True,
    )


    # ========================================================
    # IBus Component
    # ========================================================

    component = IBus.Component.new(
        COMPONENT_NAME,
        "Amharic Phonetic Keyboard",
        "0.1.0",
        "MIT",
        "Mazengia Tesfa",
        "https://mazengia-tesfa.vercel.app",
        "",
        "",
    )


    # ========================================================
    # Engine description
    # ========================================================

    engine_desc = IBus.EngineDesc.new(
        ENGINE_NAME,
        "Amharic Phonetic",
        "Amharic phonetic keyboard",
        "am",
        "MIT",
        "Mazengia Tesfa",
        "",
        "default",
    )


    component.add_engine(engine_desc)


    # --------------------------------------------------------
    # Register component with IBus.
    # --------------------------------------------------------

    bus.register_component(component)


    print(
        "Amharic Keyboard component registered.",
        flush=True,
    )


    print(
        "==========================================",
        flush=True,
    )

    print(
        " Amharic Phonetic Keyboard",
        flush=True,
    )

    print(
        f" Engine: {ENGINE_NAME}",
        flush=True,
    )

    print(
        f" Session: {SESSION_TYPE}",
        flush=True,
    )

    print(
        "==========================================",
        flush=True,
    )


    # ========================================================
    # Main GLib loop
    # ========================================================

    main_loop = GLib.MainLoop()


    try:

        main_loop.run()

    except KeyboardInterrupt:

        print(
            "Stopping Amharic Keyboard.",
            flush=True,
        )

    return 0


# ============================================================
# Application entry point
# ============================================================

if __name__ == "__main__":

    sys.exit(main())
