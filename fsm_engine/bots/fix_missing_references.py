"""
A concrete FSM Bot implementation to fix missing 'References' sections in files.
"""
from .base import FSM_Bot
import logging
from pathlib import Path

class FixMissingReferencesBot(FSM_Bot):
    """
    This bot is triggered when an audit log indicates a file is missing
    the required 'References' section. It appends a standardized section
    to the end of the file.
    """
    TRIGGER_MESSAGE = "Missing References section"

    def __init__(self, file_path: str):
        super().__init__(file_path)
        self._define_states()
        self._define_transitions()

    def _define_states(self):
        """Defines the states for this simple FSM."""
        self.states = ["INITIAL", "APPENDING_FILE", "DONE", "ERROR"]
        self.current_state = "INITIAL"

    def _define_transitions(self):
        """Maps the 'INITIAL' state to the file-writing action."""
        self.transitions = {
            "INITIAL": self._append_references,
        }

    def _append_references(self):
        """
        Action: Appends the standard 'References' section to the file.
        This is the handler for the 'INITIAL' state.
        """
        bot_name = self.__class__.__name__
        logging.info(f"[{bot_name}] Applying fix to {self.file_path}...")

        target_file = Path(self.file_path)
        if not target_file.is_file():
            logging.error(f"[{bot_name}] File not found at '{self.file_path}'. Transitioning to ERROR.")
            self.current_state = "ERROR"
            return

        try:
            with target_file.open("a") as f:
                f.write("\n\n### References\n")
                f.write("- See /reference_vault/README.md\n")

            self.current_state = "DONE"
            logging.info(f"[{bot_name}] Successfully applied fix.")
        except IOError as e:
            logging.error(f"[{bot_name}] Failed to write to {self.file_path}: {e}")
            self.current_state = "ERROR"