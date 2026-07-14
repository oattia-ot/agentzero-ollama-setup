## Global git configuration
```bash
git config --global user.email oren.attiaa@gmail.com
git config --global user.name oattia-ot
git config --global http.postBuffer 524288000
git config --global http.version HTTP/1.1
git config --global core.compression 0          # disable compression (faster on very slow links)
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999
```

# Git Commands — Update GitHub Repo
```bash
export VERSION="ver-0.1r2m5"
[ -n "${VERSION:-}" ] && echo "$VERSION" > version.txt || echo "VERSION environment variable is not set!"
cat > version.txt << EOF
Agent Zero + Ollama — Advanced Docker Compose Setup 
===================================================
Version: ${VERSION:-unknown}
Pushed to GitHub: $(date '+%Y-%m-%d %H:%M:%S %Z')
EOF
git init
git remote add origin https://github.com/oattia-ot/agentzero-ollama-setup.git
git branch -M main                    # rename branch to main
git add .
git commit -m "${VERSION}"
#git push -u origin main               # -u sets upstream tracking
# Or
git push -f origin main               # -f sets to forcing pushing tracking
```

## Top 20 largest files recursively (across all folders) sorted in descending order
du -ah --max-depth=100 | sort -hr | head -n 20

## In case of permissions to GitHub issues
execute --> ./idol-docker-setup/ssh-setup/setup-ssh-key.sh


## GitHub failed to push
If VS Code is injecting its askpass script via environment variables. Run this single command:
```bash
env -u GIT_ASKPASS -u VSCODE_GIT_ASKPASS_NODE -u VSCODE_GIT_ASKPASS_MAIN -u VSCODE_GIT_IPC_HANDLE git push -f origin main
``` 

## Daily Workflow
```bash
git status                            # check what changed
git add .                             # stage all changes
git add <file>                        # stage specific file
git commit -m "your message"          # commit staged changes
git push origin main                  # push to remote
```

## Pull Before Push (avoid conflicts)
```bash
git pull origin main                  # fetch + merge
git pull --rebase origin main         # fetch + rebase (cleaner history)
```

## Check State
```bash
git branch                            # list local branches
git remote -v                         # show remote URLs
git log --oneline -5                  # last 5 commits
git diff                              # show unstaged changes
```

## Fix Common Problems
```bash
# Wrong branch name
git branch -m master main             # rename local branch
git push -u origin main

# Remote has changes you don't have
git fetch origin
git rebase origin/main
git push origin main

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

## Full Update Cycle (safe)
```bash
git pull --rebase origin main         # sync with remote first
git add .
git commit -m "your message"
git push origin main
```