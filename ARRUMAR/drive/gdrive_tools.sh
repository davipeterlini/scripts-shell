

# Function to check for and install gdrive CLI tool
install_gdrive() {
  if ! command -v gdrive &> /dev/null; then
    print_info "Installing Google Drive CLI tool..."

    # Check the operating system
    OS="$(uname -s)"
    case "${OS}" in
      Linux*)
        print_info "Detected Linux OS"
        # Download the latest gdrive binary for Linux
        wget -O gdrive "https://github.com/gdrive-org/gdrive/releases/download/2.1.1/gdrive-linux-x64"
        chmod +x gdrive
        sudo mv gdrive /usr/local/bin/
        ;;
      Darwin*)
        print_info "Detected macOS"
        # Use Homebrew for macOS
        if ! command -v brew &> /dev/null; then
          print_error "Homebrew is required to install gdrive on macOS. Please install Homebrew first."
          exit 1
        fi
        brew install gdrive
        ;;
      *)
        print_error "Unsupported operating system: ${OS}"
        exit 1
        ;;
    esac

    print_info "You need to authenticate gdrive with your Google account"
    gdrive about
  else
    print_success "gdrive is already installed."
  fi
}

# Function to publish the extension package to Google Drive
publish_to_drive() {
  print_alert "\nDo you want to upload the extension package to Google Drive? (y/n): "
  read -r drive_choice
  if [[ "$drive_choice" =~ ^[Nn]$ ]]; then
    print_alert "Skipping Google Drive upload as per user choice."
    return
  fi

  # Google Drive folder ID
  DRIVE_FOLDER_ID="1L-EEXzibRVoYHGJyfJThR8Fml8I1UqpK"

  print_info "Accessing the extensions/vscode directory..."
  cd extensions/vscode || {
    print_error "Failed to access extensions/vscode directory."
    exit 1
  }

  # Get the list of vsix files
  VSIX_FILES=(build/*.vsix)

  if [ ${#VSIX_FILES[@]} -eq 0 ] || [ ! -f "${VSIX_FILES[0]}" ]; then
    print_error "No .vsix files found in the build directory."
    cd - || {
      print_error "Failed to return to the root directory."
      exit 1
    }
    return
  fi

  print_info "Uploading ${#VSIX_FILES[@]} VSIX package(s) to Google Drive..."

  # Upload each file
  for file in "${VSIX_FILES[@]}"; do
    if [ -f "$file" ]; then
      print_info "Uploading $file to Google Drive folder..."
      gdrive upload --parent "$DRIVE_FOLDER_ID" "$file"

      if [ $? -eq 0 ]; then
        print_success "Successfully uploaded $file to Google Drive"
      else
        print_error "Failed to upload $file to Google Drive"
      fi
    else
      print_alert "File $file does not exist, skipping."
    fi
  done

  print_info "Returning to the root directory..."
  cd - || {
    print_error "Failed to return to the root directory."
    exit 1
  }

  # Open the Google Drive folder in the browser
  print_info Opening the Google Drive folder in your browser...
  open_browser "https://drive.google.com/drive/u/0/folders/$DRIVE_FOLDER_ID"
}
