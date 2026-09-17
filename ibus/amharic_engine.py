#!/usr/bin/env python3

import sys
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
# Constants
# ============================================================

ENGINE_NAME = "amharic_phonetic"
COMPONENT_NAME = "org.amharic.Keyboard"

transliterator = Transliterator()


# ============================================================
# IBus Engine
# ============================================================

class AmharicEngine(IBus.Engine):

    def __init__(self):
        super().__init__()

        self.preedit = ""

        print(
            "AmharicEngine initialized.",
            flush=True
        )

    # --------------------------------------------------------
    # Key processing
    # --------------------------------------------------------

    def do_process_key_event(self, keyval, keycode, state):

        # Modifier keys
        if keyval in (
            IBus.KEY_Shift_L,
            IBus.KEY_Shift_R,
            IBus.KEY_Control_L,
            IBus.KEY_Control_R,
            IBus.KEY_Alt_L,
            IBus.KEY_Alt_R,
            IBus.KEY_Super_L,
            IBus.KEY_Super_R,
        ):
            return False

        # ----------------------------------------------------
        # Backspace
        # ----------------------------------------------------

        if keyval == IBus.KEY_BackSpace:

            if self.preedit:

                self.preedit = self.preedit[:-1]

                self.update_preedit()

                return True

            return False

        # ----------------------------------------------------
        # Escape
        # ----------------------------------------------------

        if keyval == IBus.KEY_Escape:

            self.preedit = ""

            self.update_preedit()

            return True

        # ----------------------------------------------------
        # Enter
        # ----------------------------------------------------

        if keyval in (
            IBus.KEY_Return,
            IBus.KEY_KP_Enter,
        ):

            self.commit_preedit()

            self.commit_text(
                IBus.Text.new_from_string("\n")
            )

            return True

        # ----------------------------------------------------
        # Space
        # ----------------------------------------------------

        if keyval in (
            IBus.KEY_space,
            IBus.KEY_KP_Space,
        ):

            self.commit_preedit()

            self.commit_text(
                IBus.Text.new_from_string(" ")
            )

            return True

        # ----------------------------------------------------
        # Convert keyval to character
        # ----------------------------------------------------

        try:
            character = chr(keyval)

        except (ValueError, TypeError):
            return False

        # Ignore non-printable characters
        if not character.isprintable():
            return False

        # Current transliteration uses lowercase phonetic input.
        character = character.lower()

        # Add character to preedit buffer.
        self.preedit += character

        # Update displayed Amharic text.
        self.update_preedit()

        return True

    # --------------------------------------------------------
    # Update preedit
    # --------------------------------------------------------

    def update_preedit(self):

        if not self.preedit:

            self.update_preedit_text(
                IBus.Text.new_from_string(""),
                0,
                False,
            )

            return

        amharic = transliterator.transliterate(
            self.preedit
        )

        text = IBus.Text.new_from_string(
            amharic
        )

        self.update_preedit_text(
            text,
            len(amharic),
            True,
        )

    # --------------------------------------------------------
    # Commit current preedit
    # --------------------------------------------------------

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

    # --------------------------------------------------------
    # Destroy
    # --------------------------------------------------------

    def do_destroy(self):

        self.preedit = ""

        super().do_destroy()


# ============================================================
# Main
# ============================================================

def main():

    print(
        "Initializing IBus...",
        flush=True
    )

    IBus.init()

    # --------------------------------------------------------
    # Connect to IBus
    # --------------------------------------------------------

    bus = IBus.Bus()

    if not bus.is_connected():

        print(
            "ERROR: Could not connect to IBus.",
            file=sys.stderr,
            flush=True,
        )

        return 1

    print(
        "Connected to IBus.",
        flush=True
    )

    # --------------------------------------------------------
    # Create Factory
    # --------------------------------------------------------

    print(
        "Creating IBus Factory...",
        flush=True
    )

    factory = IBus.Factory.new(
        bus.get_connection()
    )

    if factory is None:

        print(
            "ERROR: Failed to create IBus Factory.",
            file=sys.stderr,
            flush=True,
        )

        return 1

    print(
        "IBus Factory created.",
        flush=True
    )

    # --------------------------------------------------------
    # Register engine
    # --------------------------------------------------------

    factory.add_engine(
        ENGINE_NAME,
        AmharicEngine,
    )

    print(
        f"Engine registered: {ENGINE_NAME}",
        flush=True
    )

    # --------------------------------------------------------
    # Create component
    # --------------------------------------------------------

    print(
        "Creating IBus component...",
        flush=True
    )

    component = IBus.Component.new(
        COMPONENT_NAME,
        "Amharic Keyboard",
        "0.1.0",
        "MIT",
        "Mazengia Tesfa",
        "https://mazengia-tesfa.vercel.app",
        "",
        "",
    )

    if component is None:

        print(
            "ERROR: Failed to create IBus component.",
            file=sys.stderr,
            flush=True,
        )

        return 1

    print(
        "IBus component created.",
        flush=True
    )

    # --------------------------------------------------------
    # Create engine description
    # --------------------------------------------------------

    engine = IBus.EngineDesc.new(
        ENGINE_NAME,
        "Amharic Phonetic",
        "Amharic phonetic keyboard",
        "am",
        "MIT",
        "Mazengia Tesfa",
        "",
        "keyboard",
    )

    if engine is None:

        print(
            "ERROR: Failed to create EngineDesc.",
            file=sys.stderr,
            flush=True,
        )

        return 1

    component.add_engine(engine)

    print(
        "Engine description added.",
        flush=True
    )

    # --------------------------------------------------------
    # Register component
    # --------------------------------------------------------

    bus.register_component(component)

    print(
        "Amharic Keyboard IBus component registered.",
        flush=True
    )

    # --------------------------------------------------------
    # Running message
    # --------------------------------------------------------

    print(
        "",
        flush=True
    )

    print(
        "==========================================",
        flush=True
    )

    print(
        " Amharic Phonetic Keyboard is running",
        flush=True
    )

    print(
        " Engine: amharic_phonetic",
        flush=True
    )

    print(
        "==========================================",
        flush=True
    )

    print(
        "",
        flush=True
    )

    # --------------------------------------------------------
    # Main loop
    # --------------------------------------------------------

    mainloop = GLib.MainLoop()

    try:

        mainloop.run()

    except KeyboardInterrupt:

        print(
            "\nStopping Amharic Keyboard.",
            flush=True
        )

    return 0


# ============================================================
# Entry point
# ============================================================

if __name__ == "__main__":

    sys.exit(main())