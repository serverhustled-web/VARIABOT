# FSM Engine Organization

This document outlines the professional structure of the FSM Engine.

## Directory Structure

-   **`fsm_engine/`**: The root directory for the entire engine. It is a self-contained Python package.
    -   **`bots/`**: Contains all FSM Bot implementations.
        -   `base.py`: Defines the abstract `FSM_Bot` base class that all bots must inherit from.
        -   `__init__.py`: Makes the `bots` directory a package and can be used for bot registration.
        -   `fix_missing_references.py`: An example of a concrete bot implementation.
    -   `__init__.py`: Makes the `fsm_engine` directory a Python package.
    -   `manager.py`: The central `BotManager` that discovers, registers, and dispatches bots.
    -   `watcher.py`: The persistent filesystem watcher daemon that triggers the audit process.
    -   `requirements.txt`: Contains all Python dependencies for the engine (e.g., `watchdog`).
-   **`audit_scripts/`**: (Future location) A dedicated directory to hold all `audit_*.sh` scripts.
-   **`README.md`**: The main entry point for understanding and running the engine.
-   **`ORGANIZATION_INSTRUCTIONS.md`**: This file.
-   **`PREFERENCES.conf`**: A configuration file for engine-wide settings.
-   **`AI_INSTRUCTIONS.md`**: Instructions for developers (human or AI) on how to create and integrate new bots.

## Key Principles

1.  **Separation of Concerns**: The watcher, manager, and bots are all separate components with distinct responsibilities.
2.  **Extensibility**: Adding a new bot is as simple as creating a new Python class in the `bots/` directory. The manager will discover it automatically.
3.  **Configuration over Code**: Global settings (like ignored directories) are managed in `PREFERENCES.conf`, not hard-coded.
4.  **Professional Documentation**: Each major component has clear documentation outlining its purpose and use.