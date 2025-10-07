# AI & Developer Instructions for Creating FSM Bots

This guide outlines the process for creating and integrating a new FSM (Finite State Machine) Bot into the engine.

## The Goal

The primary goal is to create a new, self-contained bot that can fix a single, specific issue identified by the audit scripts. The bot's logic should be encapsulated within its own class.

## How to Create a New FSM Bot

1.  **Create a New Bot File:**
    -   In the `fsm_engine/bots/` directory, create a new Python file for your bot (e.g., `my_new_fixer_bot.py`).

2.  **Define the Bot Class:**
    -   Inside your new file, import the base class: `from .base import FSM_Bot`.
    -   Create a new class that inherits from `FSM_Bot` (e.g., `class MyNewFixerBot(FSM_Bot):`).

3.  **Implement the Required Components:**
    -   **`TRIGGER_MESSAGE`**: Set this class variable to the exact string from the `audit_results.log` that should trigger this bot.
    -   **`__init__(self, file_path)`**: The constructor must call `super().__init__(file_path)` and can be used for any bot-specific setup.
    -   **`_define_states(self)`**: Implement this method to return a list of states for your FSM (e.g., `["INITIAL", "APPLYING_FIX", "DONE"]`).
    -   **`_define_transitions(self)`**: Implement this method to define the FSM's logic. It should be a dictionary mapping a state to a handler function.
    -   **Action Functions**: Write the methods that perform the actual work (e.g., `_apply_fix`). These are your state handlers.
    -   **`run(self)`**: This method, inherited from the base class, executes the FSM. You do not need to override it.

## Example: `FixMissingReferencesBot`

Refer to `fsm_engine/bots/fix_missing_references.py` as the canonical example.

```python
from .base import FSM_Bot
import logging

class FixMissingReferencesBot(FSM_Bot):
    TRIGGER_MESSAGE = "Missing References section"

    def __init__(self, file_path):
        super().__init__(file_path)
        self._define_states()
        self._define_transitions()

    def _define_states(self):
        self.states = ["INITIAL", "APPENDING_FILE", "DONE"]
        self.current_state = "INITIAL"

    def _define_transitions(self):
        self.transitions = {
            "INITIAL": self._append_references,
        }

    def _append_references(self):
        """
        Action: Appends the standard 'References' section to the file.
        """
        logging.info(f"[{self.__class__.__name__}] Applying fix to {self.file_path}...")
        try:
            with open(self.file_path, "a") as f:
                f.write("\\n\\n### References\\n")
                f.write("- See /reference_vault/README.md\\n")
            self.current_state = "DONE"
            logging.info(f"[{self.__class__.__name__}] Successfully applied fix.")
        except IOError as e:
            logging.error(f"[{self.__class__.__name__}] Failed to write to {self.file_path}: {e}")
            self.current_state = "ERROR"

```

## Integration

The `BotManager` in `fsm_engine/manager.py` **automatically discovers** all classes that inherit from `FSM_Bot` in the `fsm_engine/bots/` directory. You do not need to manually register your new bot. Once your file is created and saved, the engine will find and use it during the next run.