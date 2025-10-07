# VARIABOT Termux Bin Directory

This directory contains executable scripts for Termux integration with VARIABOT.

## Files

### termux-url-opener

**Purpose:** Handles URLs shared to Termux and processes them through VARIABOT.

**Installation:**

1. Copy the script to your Termux home bin directory:
   ```bash
   mkdir -p $HOME/bin
   cp bin/termux-url-opener $HOME/bin/
   chmod +x $HOME/bin/termux-url-opener
   ```

2. Termux will automatically detect and use this script when URLs are shared to Termux.

**Configuration:**

The script creates a configuration file at `$HOME/.variabot/url_opener.conf` on first run.

Default configuration options:
```bash
# Enable/disable automatic processing
AUTO_PROCESS=true

# Enable/disable notifications
ENABLE_NOTIFICATIONS=true

# Default action for URLs (process, save, download)
DEFAULT_ACTION="process"

# Enable/disable URL caching
ENABLE_CACHE=true

# Maximum cache size in MB
MAX_CACHE_SIZE=100

# VARIABOT interface to use (auto, web, terminal)
VARIABOT_INTERFACE="auto"

# Enable/disable automatic VARIABOT launch
AUTO_LAUNCH_VARIABOT=false
```

**Usage:**

1. **Share a URL to Termux** from your browser or any app
   - The URL will be automatically processed based on your configuration

2. **Manual usage:**
   ```bash
   termux-url-opener https://example.com/article
   ```

3. **View configuration:**
   ```bash
   termux-url-opener --config
   ```

4. **View help:**
   ```bash
   termux-url-opener --help
   ```

**Features:**

- ✅ Automatic URL validation
- ✅ URL caching for later processing
- ✅ Integration with VARIABOT for AI-powered URL processing
- ✅ Termux notification support (requires termux-api)
- ✅ Multiple processing modes (process, save, download)
- ✅ Comprehensive logging
- ✅ Configurable behavior
- ✅ Auto-launch VARIABOT option
- ✅ Queue URLs for batch processing

**Logs:**

Logs are stored at: `$HOME/.variabot/logs/url_opener_YYYYMMDD.log`

**Requirements:**

- Termux 0.119.0+ 
- VARIABOT installed at `$HOME/VARIABOT`
- Optional: termux-api package for notifications (`pkg install termux-api`)
- Optional: wget for downloading URLs (`pkg install wget`)

**Integration with VARIABOT:**

The URL opener integrates seamlessly with VARIABOT:

1. **When VARIABOT is running:**
   - URLs are queued at `$HOME/.variabot/url_queue.txt`
   - VARIABOT can process them in real-time

2. **When VARIABOT is not running:**
   - URLs are saved to `$HOME/.variabot/pending_urls.txt`
   - Or VARIABOT can be auto-launched if `AUTO_LAUNCH_VARIABOT=true`

3. **Processing modes:**
   - **process**: Send URL to VARIABOT for AI analysis and processing
   - **save**: Save URL for manual processing later
   - **download**: Download URL content to storage/downloads/variabot

**Troubleshooting:**

1. **URL not being captured:**
   - Ensure the script is in `$HOME/bin/termux-url-opener`
   - Ensure the script is executable: `chmod +x $HOME/bin/termux-url-opener`
   - Restart Termux after installing

2. **Notifications not working:**
   - Install termux-api: `pkg install termux-api`
   - Install the Termux:API app from F-Droid or Google Play

3. **VARIABOT not launching:**
   - Check if VARIABOT is installed at `$HOME/VARIABOT`
   - Set `AUTO_LAUNCH_VARIABOT=true` in configuration
   - Check logs at `$HOME/.variabot/logs/`

4. **Permission issues:**
   - Ensure script has execute permissions
   - Ensure required directories can be created

**Examples:**

```bash
# Share a GitHub repo URL to Termux
termux-url-opener https://github.com/user/repo

# Share an article for AI summarization
termux-url-opener https://example.com/long-article

# Share a YouTube video for transcript processing
termux-url-opener https://youtube.com/watch?v=xxxxx

# Share a documentation page for analysis
termux-url-opener https://docs.python.org/3/tutorial/
```

## References

- Internal: `/reference_vault/linux_kali_android.md#termux-optimization`
- Internal: `/reference_vault/PRODUCTION_GRADE_STANDARDS.md`
- External: [Termux Wiki - URL Opener](https://wiki.termux.com/wiki/Termux-url-opener)
- External: [Termux:API Documentation](https://wiki.termux.com/wiki/Termux:API)
