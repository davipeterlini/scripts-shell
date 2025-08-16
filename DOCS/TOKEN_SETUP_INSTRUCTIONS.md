# GitHub Token Setup Instructions

This document provides instructions on how to set up the required tokens for the repository synchronization GitHub Action.

## Required Tokens

The sync-repo.yml workflow requires two tokens:

1. `GITHUB_TOKEN` - Automatically provided by GitHub Actions
2. `TARGET_REPO_TOKEN` - Must be created manually

## Setting up GITHUB_TOKEN

The `GITHUB_TOKEN` is automatically created by GitHub Actions for each workflow run. No additional setup is required for this token.

## Creating and Setting up TARGET_REPO_TOKEN

Follow these steps to create and set up the `TARGET_REPO_TOKEN`:

### 1. Create a Personal Access Token (PAT)

1. Log in to the GitHub account that has access to the target repository (https://github.com/davipeterlinicit/scripts-shell)
2. Go to Settings > Developer settings > Personal access tokens > Tokens (classic)
3. Click "Generate new token" > "Generate new token (classic)"
4. Give your token a descriptive name like "Repository Sync"
5. Set the expiration as needed
6. Select the following permissions:
   - `repo` (Full control of private repositories)
7. Click "Generate token"
8. Copy the token value immediately (you won't be able to see it again)

### 2. Add the Token to Source Repository Secrets

1. Go to your source repository on GitHub
2. Navigate to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Name: `TARGET_REPO_TOKEN`
5. Value: Paste the personal access token you created
6. Click "Add secret"

## Verification

After setting up the token:

1. Make a commit or merge a PR to the main branch
2. Go to the "Actions" tab in your repository
3. You should see the "Sync to Target Repository" workflow running
4. Check that changes are properly synchronized to the target repository

## Troubleshooting

If the synchronization fails:

1. Check the workflow run logs for specific error messages
2. Verify that the `TARGET_REPO_TOKEN` has proper permissions
3. Ensure the target repository exists and is accessible
4. Confirm that the source and destination repository paths in the workflow file are correct