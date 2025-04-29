# Git Push Interceptor Setup Instructions

This document provides instructions on how to set up the Git Push Interceptor script, which intercepts git push commands, validates the repository, and ensures the correct SSH key is used.

## Prerequisites

1. Ensure you have bash installed on your system.
2. Make sure you have already run the `github/configure_multi_ssh_github_keys.sh` script to set up your SSH keys.

## Setup Steps

1. The `git_push_interceptor.sh` script should be located in the `github` folder of your project.

2. Make the script executable:
   ```
   chmod +x /path/to/your/project/github/git_push_interceptor.sh
   ```

3. Create a Git alias for the push command. Open your global Git configuration file:
   ```
   git config --global --edit
   ```

4. Add the following alias to the file:
   ```
   [alias]
       push = !"/path/to/your/project/github/git_push_interceptor.sh"
   ```
   Replace `/path/to/your/project` with the actual path to your project directory.

5. Save and close the file.

6. Update your `.env` or `.env.local` file with the following variables:
   ```
   PERSONAL_GITHUB_USERNAME=your_personal_github_username
   WORK_GITHUB_USERNAME=your_work_github_username
   SSH_KEY_PERSONAL=/path/to/your/personal/ssh/key
   SSH_KEY_WORK=/path/to/your/work/ssh/key
   ```

## Usage

After setting up the interceptor, whenever you use `git push`, it will automatically:
1. Determine if the repository is personal or work-related.
2. Connect the appropriate SSH key.
3. Execute the push command.

No changes to your regular Git workflow are needed. Simply use `git push` as you normally would.

## Troubleshooting

- If you encounter any issues, ensure that the paths in your Git alias and environment variables are correct.
- Check that the `github/connect_git_ssh_account.sh` script is in the correct location relative to the interceptor script.
- Verify that your SSH keys are properly set up and the paths in the environment variables are correct.

