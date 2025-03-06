./install_brew_apps.sh app1 app2 app3
```

## Other Scripts

### `setup_iterm.sh`

Configures iTerm2 with custom settings and themes.

**Features:**
- Downloads and installs custom color schemes
- Sets up Oh My Zsh with custom plugins and themes
- Configures iTerm2 preferences
- Installs Powerline fonts for enhanced terminal appearance

**Usage:**
```bash
./setup_iterm.sh
```

### `setup_terminal.sh`

Sets up the default Terminal app with custom configurations.

**Features:**
- Installs Oh My Zsh
- Configures custom themes and plugins for Zsh
- Sets up aliases and environment variables

**Usage:**
```bash
./setup_terminal.sh
```

### `update_all_apps_mac.sh`

Updates all installed Homebrew packages and applications.

**Features:**
- Updates Homebrew itself
- Updates all installed formulae
- Updates all installed casks
- Performs cleanup to remove old versions

**Usage:**
```bash
./update_all_apps_mac.sh
```

## Additional Files

### `install_brew_apps.sh`

This script is responsible for installing applications using Homebrew. It's the core script for setting up your macOS development environment.

**Key Functions:**
- `install_homebrew()`: Installs Homebrew if not already present
- `install_brew_apps()`: Installs specified applications using Homebrew
- Error handling and progress reporting

## Usage Instructions

1. Ensure you have granted execute permissions to all scripts:
   ```
   chmod +x *.sh
   ```

2. Run the main script to install Homebrew apps:
   ```
   ./install_brew_apps.sh app1 app2 app3
   ```
   Replace `app1 app2 app3` with the names of the applications you want to install.

3. Run other scripts as needed for additional setup:
   ```
   ./setup_iterm.sh
   ./setup_terminal.sh
   ```

4. To update all apps:
   ```
   ./update_all_apps_mac.sh