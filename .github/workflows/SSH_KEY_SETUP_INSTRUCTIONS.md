# SSH Key Setup Instructions

This document provides instructions on how to set up the required SSH key for the repository synchronization GitHub Action.

## Required Secret

The sync-repo.yml workflow requires an SSH private key:

1. `SYNC_SSH_PRIVATE_KEY` - Must be created manually

## Creating and Setting up SYNC_SSH_PRIVATE_KEY

Follow these steps to create and set up the `SYNC_SSH_PRIVATE_KEY`:

### 1. Generate an SSH Key Pair

1. Open a terminal on your local machine
2. Run the following command to generate an SSH key pair:
   ```bash
   ssh-keygen -t ed25519 -f github_sync_key -C "github-sync-action"
   ```
3. When prompted for a passphrase, press Enter twice to create a key without a passphrase
4. This creates two files:
   - `github_sync_key` (private key)
   - `github_sync_key.pub` (public key)

### 2. Add the Public Key to Target Repository

1. Log in to the GitHub account that owns the target repository (https://github.com/davipeterlinicit/scripts-shell)
2. Go to the repository Settings > Deploy keys
3. Click "Add deploy key"
4. Title: "Repository Sync Key"
5. Key: Paste the content of the `github_sync_key.pub` file
6. Check "Allow write access"
7. Click "Add key"

### 3. Add the Private Key to Source Repository Secrets

1. Go to your source repository on GitHub
2. Navigate to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Name: `SYNC_SSH_PRIVATE_KEY`
5. Value: Paste the entire content of the `github_sync_key` file (private key)
6. Click "Add secret"

## Verification

After setting up the SSH key:

1. Make a commit or merge a PR to the main branch
2. Go to the "Actions" tab in your repository
3. You should see the "Sync to Target Repository" workflow running
4. Check that changes are properly synchronized to the target repository

## Troubleshooting

If the synchronization fails:

1. Check the workflow run logs for specific error messages
2. Verify that the deploy key has been added correctly to the target repository
3. Ensure the deploy key has write access
4. Confirm that the source and destination repository paths in the workflow file are correct
5. Make sure the private key has been added as a secret in the source repository