"""
The Central Bot Manager.

This module is responsible for discovering, registering, and dispatching
all FSM Bots.
"""
import os
import importlib
import inspect
import logging
import re
from pathlib import Path
from .bots.base import FSM_Bot

# --- Configuration ---
AUDIT_LOG_FILE = Path("audit_results.log")
BOTS_DIR = Path(__file__).parent / "bots"

logging.basicConfig(level=logging.INFO, format='[BOT-MANAGER] %(message)s')

class BotManager:
    """
    Discovers and runs FSM bots based on audit log entries.
    """
    def __init__(self):
        self.bot_registry = self._register_bots()

    def _register_bots(self) -> dict:
        """
        Dynamically discovers and registers all FSM_Bot subclasses in the
        `fsm_engine/bots` directory.
        """
        registry = {}
        bot_package = 'fsm_engine.bots'

        for filename in os.listdir(BOTS_DIR):
            if filename.endswith('.py') and not filename.startswith('__'):
                module_name = filename[:-3]
                module = importlib.import_module(f".{module_name}", package=bot_package)

                for _, obj in inspect.getmembers(module, inspect.isclass):
                    # Check if it's a subclass of FSM_Bot and not the base class itself
                    if issubclass(obj, FSM_Bot) and obj is not FSM_Bot:
                        trigger = getattr(obj, 'TRIGGER_MESSAGE', None)
                        if trigger:
                            if trigger in registry:
                                logging.warning(f"Duplicate trigger '{trigger}' found. Overwriting.")
                            registry[trigger] = obj
                            logging.info(f"Registered bot '{obj.__name__}' for trigger: '{trigger}'")
                        else:
                            logging.warning(f"Bot '{obj.__name__}' is missing a TRIGGER_MESSAGE.")
        return registry

    def dispatch(self, log_entry: str):
        """
        Parses a single log entry and dispatches the appropriate bot if a
        trigger message is found.
        """
        clean_entry = re.sub(r'\x1b\[[0-9;]*m', '', log_entry) # Strip ANSI codes

        for trigger, bot_class in self.bot_registry.items():
            if trigger in clean_entry:
                # Trigger found, now extract the file path.
                file_path = None
                if " in: " in clean_entry:
                    file_path = clean_entry.split(" in: ")[-1].strip()
                elif ":" in clean_entry:
                    match = re.match(r"([^:]+):\d+", clean_entry)
                    if match:
                        file_path = match.group(1).strip()

                if file_path:
                    try:
                        logging.info(f"Dispatching '{bot_class.__name__}' for file: {file_path}")
                        bot_instance = bot_class(file_path=file_path)
                        bot_instance.run()
                        # Stop after the first match to prevent multiple bots
                        # acting on the same log line.
                        return
                    except Exception as e:
                        logging.error(f"Failed to instantiate or run bot {bot_class.__name__}: {e}", exc_info=True)
                else:
                    logging.warning(f"Could not extract file path from log entry: '{log_entry}'")

    def run_on_log_file(self):
        """
        Reads the audit log file and dispatches bots for each line.
        """
        if not AUDIT_LOG_FILE.exists():
            logging.warning(f"Audit log file not found at '{AUDIT_LOG_FILE}'. Nothing to process.")
            return

        logging.info(f"Starting bot dispatch for log file: '{AUDIT_LOG_FILE}'")
        with AUDIT_LOG_FILE.open('r') as f:
            for line in f:
                self.dispatch(line.strip())
        logging.info("Bot dispatch finished.")


if __name__ == '__main__':
    # This allows for direct testing of the manager.
    logging.info("Running BotManager in standalone mode for testing.")
    manager = BotManager()
    manager.run_on_log_file()