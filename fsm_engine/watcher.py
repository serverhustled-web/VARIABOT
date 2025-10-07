"""
The Filesystem Watcher Service.

This module provides a persistent daemon that monitors the repository for
file changes and triggers the audit/remediation pipeline.
"""
import time
import logging
import subprocess
import configparser
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# --- Configuration ---
logging.basicConfig(level=logging.INFO, format='[WATCHER] %(asctime)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
REPO_ROOT = Path(__file__).parent.parent # The root of the repository
PREFERENCES_FILE = REPO_ROOT / "PREFERENCES.conf"
AUDIT_SCRIPT = REPO_ROOT / "run_all_audits.sh"

class AuditTriggerHandler(FileSystemEventHandler):
    """
    Handles filesystem events and triggers the audit process.
    """
    def __init__(self, ignored_dirs):
        super().__init__()
        self.ignored_dirs = set(ignored_dirs)
        logging.info(f"Ignoring changes in directories: {self.ignored_dirs}")

    def on_modified(self, event):
        """
        Called when a file or directory is modified.
        """
        if event.is_directory:
            return

        src_path = Path(event.src_path)

        # Check if the path is within an ignored directory
        if any(ignored in src_path.parts for ignored in self.ignored_dirs):
            return

        # Ignore changes to the audit log itself to prevent loops
        if src_path.name == "audit_results.log":
            return

        logging.info(f"Change detected: {src_path}. Triggering audit pipeline...")
        try:
            # Run the main audit script
            subprocess.run([str(AUDIT_SCRIPT)], check=True, capture_output=True, text=True)
            logging.info("Audit pipeline finished successfully.")
        except subprocess.CalledProcessError as e:
            logging.error(f"Audit pipeline failed with exit code {e.returncode}.")
            logging.error(f"STDOUT: {e.stdout}")
            logging.error(f"STDERR: {e.stderr}")
        except Exception as e:
            logging.error(f"An unexpected error occurred while running the audit script: {e}")

def start_watcher():
    """
    Initializes and starts the filesystem watcher.
    """
    # Read preferences
    config = configparser.ConfigParser()
    ignored_dirs = []
    if PREFERENCES_FILE.exists():
        config.read(PREFERENCES_FILE)
        dirs_str = config.get('Watcher', 'IGNORE_DIRECTORIES', fallback='')
        ignored_dirs = [d.strip() for d in dirs_str.split(',') if d.strip()]
    else:
        logging.warning("PREFERENCES.conf not found. Running with default settings.")

    event_handler = AuditTriggerHandler(ignored_dirs)
    observer = Observer()
    observer.schedule(event_handler, str(REPO_ROOT), recursive=True)

    logging.info(f"Starting filesystem watcher on '{REPO_ROOT}'. Press Ctrl+C to stop.")
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logging.info("Stopping filesystem watcher.")
        observer.stop()

    observer.join()

if __name__ == "__main__":
    start_watcher()