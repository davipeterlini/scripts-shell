#!/bin/bash
# setup_work_projects.sh
# Purpose: Set up and maintain work project repositories

# Constants
SCRIPT_DIR=$(dirname "$(realpath "$0")")
readonly ERROR_LOG="/tmp/git_error_output"

# Import utilities
source "$(dirname "$0")/../../utils/colors_message.sh"
source "$(dirname "$0")/../../utils/load_env.sh"
source "$(dirname "$0")/../../utils/bash_tools.sh"

# Load environment variables
load_env

# Repository configuration
declare -A REPOSITORIES=(
    ["$PROJECT_DIR_WORK/flow/chat"]="git@github.com:CI-T-HyperX/flow-channels-app-service.git"
    ["$PROJECT_DIR_WORK/flow/ai-core"]="git@github.com:CI-T-HyperX/flow-core-app-llm-service.git"
    ["$PROJECT_DIR_WORK/flow/coder"]="git@github.com:CI-T-HyperX/flow-coder-framework.git"
    ["$PROJECT_DIR_WORK/flow/coder"]="git@github.com:CI-T-HyperX/flow-coder-service.git"
    ["$PROJECT_DIR_WORK/flow/coder"]="git@bitbucket.org:ciandt_it/flow-coder-extension.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:davipeterlinicit/case-end-to-end-ops.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:laisbonafeciandt/case-end-to-end-metrics.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:arysanchez/case-end-to-end-chat.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:davipeterlinicit/coder-cases.git"
    ["$PROJECT_DIR_WORK/flow/coder/cases"]="git@github.com:CI-T-HyperX/flow-core-lib-commons-py.git"
    ["$PROJECT_DIR_WORK/flow/coder/pocs"]="git@github.com:continuedev/continue.git"
    ["$PROJECT_DIR_WORK/flow/coder/mcp-server"]="git@github.com:CI-T-HyperX/mcp-ciandt-flow.git"
)

# Directory structure configuration
readonly DIRECTORIES=(
    "$PROJECT_DIR_WORK"
    "$PROJECT_DIR_WORK/flow"
    "$PROJECT_DIR_WORK/flow/chat"
    "$PROJECT_DIR_WORK/flow/ai-core"
    "$PROJECT_DIR_WORK/flow/coder"
    "$PROJECT_DIR_WORK/flow/coder/cases"
    "$PROJECT_DIR_WORK/flow/coder/mcp-server"
    "$PROJECT_DIR_WORK/flow/coder/pocs"
)

# Function to manage repositories
manage_repositories() {
    for target_dir in "${!REPOSITORIES[@]}"; do
        local repo_url="${REPOSITORIES[$target_dir]}"
        local repo_name=$(basename "$repo_url" .git)
        local repo_path="$target_dir/$repo_name"

        if [[ -d "$repo_path" ]]; then
            print_info "Updating repository: $repo_name"
            (cd "$repo_path" && git pull)
        else
            print_info "Cloning repository: $repo_name"
            git clone "$repo_url" "$repo_path"
        fi
    done
}

# Main script execution
main() {
    if [[ -z "$PROJECT_DIR_WORK" ]]; then
        print_error "PROJECT_DIR_WORK environment variable is not set. Please check your .env file."
        exit 1
    fi

    create_directories "${DIRECTORIES[@]}"
    manage_repositories

    print_success "Work projects setup completed successfully!"
}

# Check if the script is being executed directly or sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi