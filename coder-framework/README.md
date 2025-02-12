# Coder Framework Installation

This guide provides instructions to install Python, configure the PATH, and install the Coder framework on macOS, Linux, and Windows systems.

## Installation Steps

1. **Install Python**:
    - The script will install Python 3 and pip (Python package installer).

2. **Configure PATH**:
    - The script will add the Python scripts directory to your PATH.

3. **Install Coder**:
    - The script will install the Coder framework using pip.

## Instructions

1. **Clone the Repository**:
    ```sh
    git clone <repository_url>
    cd coder-framework
    ```

2. **Run the Python Installation Script**:
    ```sh
    chmod +x install_python.sh
    ./install_python.sh
    ```

3. **Run the Coder Installation Script**:
    ```sh
    chmod +x install_coder.sh
    ./install_coder.sh
    ```

4. **Apply PATH Changes**:
    - After running the scripts, restart your terminal or run the following command to apply the PATH changes:
    ```sh
    source ~/.bashrc
    ```
    - If you are using Zsh, run:
    ```sh
    source ~/.zshrc
    ```

## Notes

- The script supports macOS, Linux, and Windows systems.
- If you encounter any issues, please ensure that you have the necessary permissions to install software and modify configuration files.

## Troubleshooting

- **Unsupported OS**:
    - If you are using an unsupported OS, please install Python manually and configure the PATH accordingly.
- **Permission Issues**:
    - If you encounter permission issues, try running the script with `sudo`:
    ```sh
    sudo ./install_python.sh
    sudo ./install_coder.sh
    ```

## Contact

For any questions or issues, please contact [your_email@example.com].