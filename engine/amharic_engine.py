#!/usr/bin/env python3

import sys
import time
from pathlib import Path

import gi

gi.require_version("IBus", "1.0")
from gi.repository import IBus, GLib


# ============================================================
# Project paths
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parent.parent
ENGINE_DIR = PROJECT_ROOT / "engine"

sys.path.insert(0, str(ENGINE_DIR))

from transliterator import Transliterator


# ============================================================
# IBus configuration
# ============================================================

ENGINE_NAME = "amharic_phonetic"
COMPONENT_NAME = "org.amharic.Keyboard"

transliterator = Transliterator()


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
        # Some Wayland/XWayland/IBus combinations can result
        # in the same key press reaching the engine twice.
        # ----------------------------------------------------

        self.last_keyval = None
        self.last_keycode = None
        self.last_state = None
        self.last_event_time = 0.0

        # 50 milliseconds.
        #
        # Two identical events inside this very small window
        # are treated as a duplicate event.
        self.DUPLICATE_EVENT_WINDOW = 0.050

        print(
            f"AmharicEngine initialized: {object_path}",
            flush=True,
        )


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
        # codepoint.
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
    # Reset
    # ========================================================

    def do_reset(self):

        self.preedit = ""

        self.last_keyval = None
        self.last_keycode = None
        self.last_state = None
        self.last_event_time = 0.0

        self.update_preedit()

        super().do_reset()


    # ========================================================
    # Disable
    # ========================================================

    def do_disable(self):

        self.preedit = ""

        self.last_keyval = None
        self.last_keycode = None
        self.last_state = None
        self.last_event_time = 0.0

        self.update_preedit()

        super().do_disable()


    # ========================================================
    # Destroy
    # ========================================================

    def do_destroy(self):

        self.preedit = ""

        self.last_keyval = None
        self.last_keycode = None
        self.last_state = None
        self.last_event_time = 0.0

        super().do_destroy()


# ============================================================
# Main
# ============================================================

def main():

    print(
        "Initializing IBus...",
        flush=True,
    )

    IBus.init()


    # --------------------------------------------------------
    # Connect to IBus
    # --------------------------------------------------------

    bus = IBus.Bus()


    if not bus.is_connected():

        print(
            "ERROR: Could not connect to IBus.",
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
    #
    # No custom AmharicEngineFactory is used.
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