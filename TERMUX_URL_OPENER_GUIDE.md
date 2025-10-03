# VARIABOT Termux URL Opener - Complete Guide

## Overview

The VARIABOT Termux URL Opener enables seamless URL sharing from any Android app directly to VARIABOT for processing, analysis, and interaction. This integration allows you to share web pages, articles, GitHub repos, documentation, and more to VARIABOT with a single tap.

## Features

✅ **One-Tap URL Sharing** - Share URLs from any app to Termux  
✅ **Automatic Processing** - URLs are automatically queued for VARIABOT  
✅ **Multiple Processing Modes** - Process, save, or download URLs  
✅ **Smart Caching** - URL cache prevents duplicate processing  
✅ **Notification Support** - Get notified of processing status  
✅ **Auto-Launch VARIABOT** - Optional automatic VARIABOT startup  
✅ **Comprehensive Logging** - Track all URL processing activities  
✅ **Configurable Behavior** - Customize via configuration file  

## Quick Start

### Installation

```bash
# Navigate to VARIABOT directory
cd ~/VARIABOT

# Run installation script
bash bin/install_url_opener.sh

# Verify installation
termux-url-opener --version
```

### Usage

#### Method 1: Share from any app
1. Open any app (Browser, YouTube, GitHub, etc.)
2. Tap the "Share" button
3. Select "Termux"
4. The URL will be automatically processed by VARIABOT

#### Method 2: Manual command line
```bash
termux-url-opener https://example.com/article
```

## Configuration

### Configuration File
Location: `$HOME/.variabot/url_opener.conf`

### Default Configuration
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

### Customizing Configuration

Edit the configuration file:
```bash
nano $HOME/.variabot/url_opener.conf
```

View current configuration:
```bash
termux-url-opener --config
```

## Processing Modes

### 1. Process Mode (Default)
URLs are sent to VARIABOT for AI-powered processing.

**Use cases:**
- Summarize long articles
- Extract key information from web pages
- Analyze GitHub repositories
- Process documentation
- Extract code snippets

**Configuration:**
```bash
DEFAULT_ACTION="process"
```

### 2. Save Mode
URLs are saved for manual processing later.

**Use cases:**
- Build a reading list
- Collect URLs for batch processing
- Save interesting links

**Configuration:**
```bash
DEFAULT_ACTION="save"
```

**View saved URLs:**
```bash
cat $HOME/.variabot/saved_urls.txt
```

### 3. Download Mode
Download URL content to device storage.

**Use cases:**
- Offline access to web content
- Download files and documents
- Archive web pages

**Configuration:**
```bash
DEFAULT_ACTION="download"
```

**Downloads location:**
```
$HOME/storage/downloads/variabot/
```

## Integration with VARIABOT

### When VARIABOT is Running
URLs are automatically queued and processed in real-time.

**Queue location:**
```
$HOME/.variabot/url_queue.txt
```

### When VARIABOT is Not Running

#### Option 1: Auto-Launch (Recommended for active use)
```bash
# Enable in configuration
AUTO_LAUNCH_VARIABOT=true
```

#### Option 2: Manual Launch (Better for battery)
```bash
# URLs saved to pending file
# Launch VARIABOT when ready
./launch_termux.sh
```

**Pending URLs location:**
```
$HOME/.variabot/pending_urls.txt
```

## Python Integration

Access URL queues from Python code:

```python
from termux_environment import TermuxEnvironment

env = TermuxEnvironment()

# Get queued URLs (cleared after reading)
queued_urls = env.get_url_queue()
for url in queued_urls:
    print(f"Processing: {url}")

# Get pending URLs (not cleared)
pending_urls = env.get_pending_urls()
print(f"Pending: {len(pending_urls)} URLs")

# Clear pending URLs
env.clear_pending_urls()
```

## Logging

### Log Location
```
$HOME/.variabot/logs/url_opener_YYYYMMDD.log
```

### Log Format
```
[2024-10-03 10:30:45] [INFO] Received URL: https://example.com
[2024-10-03 10:30:45] [INFO] URL cached: /data/.../cache/urls/1234567890.url
[2024-10-03 10:30:46] [INFO] Processing URL with VARIABOT
```

### View Logs
```bash
# View today's log
cat $HOME/.variabot/logs/url_opener_$(date +%Y%m%d).log

# Tail log in real-time
tail -f $HOME/.variabot/logs/url_opener_$(date +%Y%m%d).log

# View all logs
ls -lh $HOME/.variabot/logs/
```

## Notifications

### Enable Notifications

1. Install termux-api package:
```bash
pkg install termux-api
```

2. Install Termux:API app:
   - [F-Droid](https://f-droid.org/packages/com.termux.api/)
   - [Google Play](https://play.google.com/store/apps/details?id=com.termux.api)

3. Enable in configuration:
```bash
ENABLE_NOTIFICATIONS=true
```

### Notification Examples
- "VARIABOT - URL queued for processing"
- "VARIABOT - Launching to process URL..."
- "Download Complete - URL content downloaded successfully"

## Use Cases and Examples

### 1. Article Summarization
```bash
# Share long articles for AI summarization
# From browser: Share → Termux
# VARIABOT will extract key points and create summary
```

### 2. GitHub Repository Analysis
```bash
# Share GitHub repo URL
termux-url-opener https://github.com/username/repo

# VARIABOT can:
# - Analyze project structure
# - Review README
# - Examine code patterns
# - Suggest improvements
```

### 3. Documentation Processing
```bash
# Share documentation pages
termux-url-opener https://docs.python.org/3/tutorial/

# VARIABOT can:
# - Extract code examples
# - Create quick reference
# - Answer questions about content
```

### 4. YouTube Video Processing
```bash
# Share YouTube URLs
termux-url-opener https://youtube.com/watch?v=xxxxx

# VARIABOT can:
# - Extract video metadata
# - Process transcripts (if available)
# - Summarize content
```

### 5. News Aggregation
```bash
# Set to save mode for reading list
DEFAULT_ACTION="save"

# Share multiple news articles throughout day
# Process batch later with VARIABOT
```

## Troubleshooting

### URLs Not Being Captured

**Problem:** Sharing to Termux doesn't work

**Solutions:**
1. Verify installation:
   ```bash
   ls -l $HOME/bin/termux-url-opener
   ```

2. Check permissions:
   ```bash
   chmod +x $HOME/bin/termux-url-opener
   ```

3. Restart Termux app completely

4. Reinstall:
   ```bash
   bash bin/install_url_opener.sh
   ```

### Notifications Not Working

**Problem:** No notifications appear

**Solutions:**
1. Install termux-api:
   ```bash
   pkg install termux-api
   ```

2. Install Termux:API app from store

3. Grant notification permissions to Termux:API app

4. Check configuration:
   ```bash
   grep ENABLE_NOTIFICATIONS $HOME/.variabot/url_opener.conf
   ```

### VARIABOT Not Processing URLs

**Problem:** URLs queued but not processed

**Solutions:**
1. Check if VARIABOT is running:
   ```bash
   pgrep -f variabot_universal.py
   ```

2. Launch VARIABOT manually:
   ```bash
   ./launch_termux.sh
   ```

3. Enable auto-launch:
   ```bash
   echo "AUTO_LAUNCH_VARIABOT=true" >> $HOME/.variabot/url_opener.conf
   ```

4. Check logs:
   ```bash
   tail -20 $HOME/.variabot/logs/url_opener_$(date +%Y%m%d).log
   ```

### Download Failures

**Problem:** Downloads not working

**Solutions:**
1. Install wget:
   ```bash
   pkg install wget
   ```

2. Check storage permissions:
   ```bash
   termux-setup-storage
   ```

3. Verify downloads directory:
   ```bash
   ls -ld $HOME/storage/downloads/variabot
   ```

### Configuration Issues

**Problem:** Changes not taking effect

**Solutions:**
1. Verify configuration syntax:
   ```bash
   cat $HOME/.variabot/url_opener.conf
   ```

2. No spaces around `=` in configuration:
   ```bash
   # Correct
   AUTO_PROCESS=true
   
   # Wrong
   AUTO_PROCESS = true
   ```

3. Recreate configuration:
   ```bash
   rm $HOME/.variabot/url_opener.conf
   termux-url-opener --help  # Creates new config
   ```

## Advanced Usage

### Batch Processing URLs

```bash
# Create file with URLs
cat > urls.txt << EOF
https://example.com/page1
https://example.com/page2
https://example.com/page3
EOF

# Process all URLs
while read url; do
    termux-url-opener "$url"
done < urls.txt
```

### Custom URL Filters

Edit script to add custom validation:

```bash
# Add to validate_url function
case "$url" in
    *youtube.com*|*youtu.be*)
        # Custom YouTube handling
        ;;
    *github.com*)
        # Custom GitHub handling
        ;;
esac
```

### Integration with Other Scripts

```bash
#!/bin/bash
# Custom automation script

# Get URL from somewhere
URL="https://example.com/article"

# Send to VARIABOT URL opener
termux-url-opener "$URL"

# Wait for processing
sleep 5

# Check results
cat $HOME/.variabot/logs/url_opener_$(date +%Y%m%d).log | tail -5
```

## Performance Tips

1. **Enable caching** to avoid reprocessing URLs:
   ```bash
   ENABLE_CACHE=true
   ```

2. **Use save mode** for batch processing:
   ```bash
   DEFAULT_ACTION="save"
   ```

3. **Disable auto-launch** to save battery:
   ```bash
   AUTO_LAUNCH_VARIABOT=false
   ```

4. **Set max cache size** to prevent storage issues:
   ```bash
   MAX_CACHE_SIZE=100  # MB
   ```

5. **Clean old logs** regularly:
   ```bash
   find $HOME/.variabot/logs/ -name "url_opener_*.log" -mtime +30 -delete
   ```

## Security Considerations

1. **URL Validation:** All URLs are validated before processing
2. **Local Processing:** URLs processed locally, no external services
3. **Secure Storage:** Logs and cache stored in private Termux home
4. **Permission Control:** Script requires explicit user action
5. **No Auto-Execute:** URLs are not automatically executed

## Maintenance

### Clean Cache
```bash
rm -rf $HOME/.variabot/cache/urls/*
```

### Clean Logs
```bash
rm -f $HOME/.variabot/logs/url_opener_*.log
```

### Reset Configuration
```bash
rm $HOME/.variabot/url_opener.conf
termux-url-opener --help  # Regenerates config
```

### Update Script
```bash
cd ~/VARIABOT
git pull
bash bin/install_url_opener.sh
```

## Support and Documentation

- **Main Documentation:** `bin/README.md`
- **VARIABOT Docs:** `reference_vault/linux_kali_android.md`
- **Issue Tracker:** GitHub repository issues
- **Community:** GitHub discussions

## References

- Internal: `/reference_vault/PRODUCTION_GRADE_STANDARDS.md`
- Internal: `/reference_vault/linux_kali_android.md#termux-optimization`
- External: [Termux Wiki - URL Opener](https://wiki.termux.com/wiki/Termux-url-opener)
- External: [Termux:API Documentation](https://wiki.termux.com/wiki/Termux:API)
- External: [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

## Changelog

### Version 1.0 (2024-10-03)
- Initial release
- Basic URL handling and validation
- VARIABOT integration
- Configuration system
- Logging framework
- Notification support
- Multiple processing modes
- Caching system
- Auto-launch capability
