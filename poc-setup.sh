#!/bin/bash

# Navigate to the root directory where the 'auth' folder is located
#cd "$(dirname "$0")"/..

# Source the export_token.sh script to set the GITHUB_TOKEN environment variable
source ./auth/export_tokens.sh

# Check for GitHub token
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "GitHub token not found. Exiting."
    exit 1
fi

# Get GitHub username from token
github_username=$(curl -sH "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | jq -r .login)

if [[ "$github_username" == "null" ]]; then
    echo "Failed to retrieve GitHub username. Check your token permissions. Exiting."
    exit 1
else
    echo "GitHub username retrieved successfully: $github_username"
fi

# Prompt for repository details
echo "Enter the name for your new GitHub repository (no underscores, max 20 characters):"
read repo_name

# Validate repository name
if [[ "${#repo_name}" -gt 20 ]] || [[ "$repo_name" == *_* ]]; then
    echo "Invalid repository name. Exiting."
    exit 1
fi

echo "Should the repository be private? (yes/no):"
read is_private

private_flag=false
if [[ "$is_private" =~ ^[Yy] ]]; then
    private_flag=true
fi

# List of possible programming languages
echo "Select the primary language for the repository:"
languages=("Python" "JavaScript" "Java" "C++" "C#" "Go" "Ruby" "PHP")
select lang in "${languages[@]}"; do
    repo_language="$lang"
    break
done

# Create the repository
API_URL="https://api.github.com/user/repos"

DATA_PAYLOAD=$(jq -n \
                  --arg name "$repo_name" \
                  --arg private "$private_flag" \
                  --arg description "Primary language: $repo_language" \
                  '{name: $name, private: $private, description: $description}')

# Create the repository using curl
RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -d "$DATA_PAYLOAD" "$API_URL")

# Check if the repository was successfully created
if [[ "$RESPONSE" == *"created_at"* ]]; then
    echo "Repository '$repo_name' created successfully."
else
    echo "Failed to create the repository. Please check your GitHub token and repository name."
fi

cd "$HOME/project/examples"

# Clone the repository using SSH
git clone git@github.com:$github_username/$repo_name.git

# Navigate into the repository directory
cd $repo_name

# Create and switch to the develop branch
git checkout -b develop

# Create README.md
echo "# $repo_name" > README.md

# Add, commit, and push README.md
git add README.md
git add .gitignore
git add .env
git commit -m "Initial commit with README.md and .gitignore .env"
git push -u origin develop

echo "Repository setup complete."