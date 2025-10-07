"""
This module defines the abstract base class for all FSM Bots.
"""
from abc import ABC, abstractmethod
import logging

class FSM_Bot(ABC):
    """
    Abstract Base Class for a Finite State Machine Bot.

    Each bot that inherits from this class is responsible for fixing one
    specific type of error identified by the audit scripts.
    """
    TRIGGER_MESSAGE = "A unique string from the audit log that triggers this bot."

    def __init__(self, file_path: str):
        if not file_path:
            raise ValueError("File path cannot be None or empty.")
        self.file_path = file_path
        self.states = []
        self.transitions = {}
        self.current_state = "INITIAL"

    @abstractmethod
    def _define_states(self):
        """
        Define the possible states for this FSM.
        e.g., self.states = ["INITIAL", "FIXING", "DONE", "ERROR"]
        """
        pass

    @abstractmethod
    def _define_transitions(self):
        """
        Define the state transition logic.
        Maps a state to a handler function.
        e.g., self.transitions = {"INITIAL": self._my_fix_function}
        """
        pass

    def run(self):
        """
        Executes the state machine.
        This loop continues until a terminal state (like "DONE" or "ERROR")
        is reached.
        """
        logging.info(f"[{self.__class__.__name__}] Running on '{self.file_path}'")
        while self.current_state not in ["DONE", "ERROR"]:
            handler = self.transitions.get(self.current_state)
            if handler:
                handler()
            else:
                logging.error(f"[{self.__class__.__name__}] No handler defined for state '{self.current_state}'. Halting.")
                self.current_state = "ERROR"
        logging.info(f"[{self.__class__.__name__}] Finished with state '{self.current_state}'.")