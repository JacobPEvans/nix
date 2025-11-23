# Claude Code Auto-Approved Commands
#
# This file defines baseline permissions that Claude can execute without approval.
# Commands are organized by category for easy maintenance.
#
# Security Notes:
# - These are AUTO-APPROVED - only add commands you trust 100%
# - Read-only web access (GET requests only)
# - No destructive operations (rm -rf, system modifications, etc.)
# - settings.local.json can override these for ad-hoc additions

{ ... }:

let
  # Core read-only tools (always safe)
  coreReadTools = [
    "Read(**)"
    "Glob(**)"
    "Grep(**)"
  ];

  # Git operations (version control)
  gitCommands = [
    "Bash(git status:*)"
    "Bash(git log:*)"
    "Bash(git diff:*)"
    "Bash(git show:*)"
    "Bash(git branch:*)"
    "Bash(git checkout:*)"
    "Bash(git add:*)"
    "Bash(git commit:*)"
    "Bash(git push:*)"
    "Bash(git pull:*)"
    "Bash(git fetch:*)"
    "Bash(git merge:*)"
    "Bash(git rebase:*)"
    "Bash(git stash:*)"
    "Bash(git remote:*)"
    "Bash(git tag:*)"
    "Bash(git config:*)"
    "Bash(git clone:*)"
  ];

  # GitHub CLI (PR management, issues, etc.)
  githubCommands = [
    "Bash(gh auth status:*)"
    "Bash(gh pr list:*)"
    "Bash(gh pr view:*)"
    "Bash(gh pr create:*)"
    "Bash(gh pr checkout:*)"
    "Bash(gh pr merge:*)"
    "Bash(gh pr diff:*)"
    "Bash(gh pr comment:*)"
    "Bash(gh issue list:*)"
    "Bash(gh issue view:*)"
    "Bash(gh issue create:*)"
    "Bash(gh repo view:*)"
    "Bash(gh repo clone:*)"
    "Bash(gh api:*)"
    "Bash(gh workflow list:*)"
    "Bash(gh workflow view:*)"
    "Bash(gh release list:*)"
    "Bash(gh release view:*)"
  ];

  # Nix package manager and darwin-rebuild
  nixCommands = [
    "Bash(nix --version:*)"
    "Bash(nix search:*)"
    "Bash(nix search nixpkgs:*)"
    "Bash(nix flake update:*)"
    "Bash(nix flake metadata:*)"
    "Bash(nix build:*)"
    "Bash(nix develop:*)"
    "Bash(nix shell:*)"
    "Bash(nix run:*)"
    "Bash(nix-env -q:*)"
    "Bash(nix-env --query:*)"
    "Bash(darwin-rebuild switch:*)"
    "Bash(darwin-rebuild build:*)"
    "Bash(darwin-rebuild --list-generations:*)"
    "Bash(darwin-rebuild --rollback:*)"
  ];

  # Homebrew (fallback package manager)
  homebrewCommands = [
    "Bash(brew list:*)"
    "Bash(brew search:*)"
    "Bash(brew info:*)"
    "Bash(brew --version:*)"
    "Bash(brew doctor:*)"
    "Bash(brew config:*)"
    "Bash(brew outdated:*)"
    "Bash(brew deps:*)"
    "Bash(sudo -u jevans brew list:*)"
    "Bash(sudo -u jevans brew search:*)"
    "Bash(sudo -u jevans brew info:*)"
  ];

  # Python ecosystem
  pythonCommands = [
    "Bash(python --version:*)"
    "Bash(python3 --version:*)"
    "Bash(python -m:*)"
    "Bash(python3 -m:*)"
    "Bash(pip list:*)"
    "Bash(pip show:*)"
    "Bash(pip freeze:*)"
    "Bash(pip install:*)"
    "Bash(pip install --user:*)"
    "Bash(pip3 list:*)"
    "Bash(pip3 show:*)"
    "Bash(pip3 install:*)"
    "Bash(poetry --version:*)"
    "Bash(poetry install:*)"
    "Bash(poetry add:*)"
    "Bash(poetry remove:*)"
    "Bash(poetry update:*)"
    "Bash(poetry run:*)"
    "Bash(poetry shell:*)"
    "Bash(poetry show:*)"
    "Bash(pyenv versions:*)"
    "Bash(pyenv install:*)"
    "Bash(pyenv global:*)"
    "Bash(pyenv local:*)"
    "Bash(pytest:*)"
    "Bash(pytest -v:*)"
    "Bash(pytest --collect-only:*)"
  ];

  # JavaScript/TypeScript ecosystem
  nodeCommands = [
    "Bash(node --version:*)"
    "Bash(npm --version:*)"
    "Bash(npm list:*)"
    "Bash(npm ls:*)"
    "Bash(npm install:*)"
    "Bash(npm ci:*)"
    "Bash(npm run:*)"
    "Bash(npm test:*)"
    "Bash(npm run test:*)"
    "Bash(npm run build:*)"
    "Bash(npm run lint:*)"
    "Bash(npm run dev:*)"
    "Bash(npm run start:*)"
    "Bash(npm outdated:*)"
    "Bash(npm audit:*)"
    "Bash(npx:*)"
    "Bash(yarn --version:*)"
    "Bash(yarn install:*)"
    "Bash(yarn add:*)"
    "Bash(yarn remove:*)"
    "Bash(yarn run:*)"
    "Bash(pnpm --version:*)"
    "Bash(pnpm install:*)"
    "Bash(pnpm add:*)"
    "Bash(pnpm run:*)"
  ];

  # Rust ecosystem
  rustCommands = [
    "Bash(cargo --version:*)"
    "Bash(cargo build:*)"
    "Bash(cargo test:*)"
    "Bash(cargo run:*)"
    "Bash(cargo check:*)"
    "Bash(cargo fmt:*)"
    "Bash(cargo clippy:*)"
    "Bash(cargo clean:*)"
    "Bash(cargo update:*)"
    "Bash(cargo install:*)"
    "Bash(cargo uninstall:*)"
    "Bash(cargo search:*)"
    "Bash(cargo tree:*)"
    "Bash(rustc --version:*)"
    "Bash(rustup --version:*)"
    "Bash(rustup update:*)"
    "Bash(rustup show:*)"
    "Bash(rustup default:*)"
  ];

  # Docker commands
  # NOTE: Removed docker exec, docker run - these require user approval (in ask list)
  #       These allow arbitrary code execution in containers
  dockerCommands = [
    "Bash(docker --version:*)"
    "Bash(docker ps:*)"
    "Bash(docker images:*)"
    "Bash(docker logs:*)"
    "Bash(docker inspect:*)"
    "Bash(docker start:*)"
    "Bash(docker stop:*)"
    "Bash(docker restart:*)"
    "Bash(docker build:*)"
    "Bash(docker pull:*)"
    "Bash(docker push:*)"
    "Bash(docker tag:*)"
    "Bash(docker compose:*)"
    "Bash(docker info:*)"
  ];

  # Kubernetes commands
  # NOTE: Removed kubectl delete, helm uninstall - these require user approval
  #       These are destructive operations that can break production systems
  kubernetesCommands = [
    "Bash(kubectl version:*)"
    "Bash(kubectl get:*)"
    "Bash(kubectl describe:*)"
    "Bash(kubectl logs:*)"
    "Bash(kubectl port-forward:*)"
    "Bash(kubectl config:*)"
    "Bash(kubectl rollout:*)"
    "Bash(helm version:*)"
    "Bash(helm list:*)"
    "Bash(helm repo:*)"
    "Bash(helm search:*)"
  ];

  # AWS CLI
  # NOTE: Removed aws s3 rm, aws ec2 terminate - these require user approval
  #       These are destructive cloud operations with serious consequences
  awsCommands = [
    "Bash(aws --version:*)"
    "Bash(aws sts get-caller-identity:*)"
    "Bash(aws s3 ls:*)"
    "Bash(aws s3 cp:*)"
    "Bash(aws s3 sync:*)"
    "Bash(aws ec2 describe-instances:*)"
    "Bash(aws ecr get-login-password:*)"
    "Bash(aws lambda list-functions:*)"
    "Bash(aws cloudformation list-stacks:*)"
    "Bash(aws cloudformation describe-stacks:*)"
    "Bash(aws logs tail:*)"
    "Bash(aws ssm get-parameter:*)"
  ];

  # Database clients (read-focused operations only)
  # NOTE: Removed sqlite3, mongosh - these require user approval for write operations
  #       Keep only read-only commands; full access moved to ask list
  databaseCommands = [
    "Bash(redis-cli --version:*)"
    "Bash(redis-cli ping:*)"
    "Bash(redis-cli info:*)"
    "Bash(redis-cli get:*)"
  ];

  # File operations and text processing
  # NOTE: Removed chmod, rm, rmdir - these are in ask list (moved to claude-permissions-ask.nix)
  fileCommands = [
    "Bash(ls:*)"
    "Bash(cat:*)"
    "Bash(head:*)"
    "Bash(tail:*)"
    "Bash(less:*)"
    "Bash(more:*)"
    "Bash(wc:*)"
    "Bash(grep:*)"
    "Bash(find:*)"
    "Bash(tree:*)"
    "Bash(pwd:*)"
    "Bash(cd:*)"
    "Bash(mkdir:*)"
    "Bash(touch:*)"
    "Bash(cp:*)"
    "Bash(mv:*)"
    "Bash(diff:*)"
    "Bash(sed:*)"
    "Bash(awk:*)"
    "Bash(cut:*)"
    "Bash(sort:*)"
    "Bash(uniq:*)"
    "Bash(jq:*)"
    "Bash(yq:*)"
  ];

  # Compression and archiving
  archiveCommands = [
    "Bash(tar -tzf:*)"
    "Bash(tar -xzf:*)"
    "Bash(tar -czf:*)"
    "Bash(tar --disable-copyfile:*)"
    "Bash(zip:*)"
    "Bash(unzip:*)"
    "Bash(gzip:*)"
    "Bash(gunzip:*)"
  ];

  # Network operations (READ-ONLY: GET requests only)
  networkCommands = [
    "Bash(curl -s:*)"
    "Bash(curl --silent:*)"
    "Bash(curl -X GET:*)"
    "Bash(curl --request GET:*)"
    "Bash(wget:*)"
    "Bash(ping -c:*)"
    "Bash(nslookup:*)"
    "Bash(dig:*)"
    "Bash(host:*)"
    "Bash(netstat:*)"
    "Bash(lsof -i:*)"
  ];

  # System information (read-only)
  systemCommands = [
    "Bash(whoami:*)"
    "Bash(hostname:*)"
    "Bash(uname:*)"
    "Bash(date:*)"
    "Bash(uptime:*)"
    "Bash(which:*)"
    "Bash(whereis:*)"
    "Bash(env:*)"
    "Bash(printenv:*)"
    "Bash(ps:*)"
    "Bash(top -l 1:*)"
    "Bash(df:*)"
    "Bash(du:*)"
    "Bash(free:*)"
    "Bash(launchctl list:*)"
    "Bash(launchctl print:*)"
  ];

  # Process management (limited)
  processCommands = [
    "Bash(echo:*)"
    "Bash(printf:*)"
    "Bash(test:*)"
    "Bash(source:*)"
    "Bash(export:*)"
    "Bash(alias:*)"
    "Bash(history:*)"
  ];

  # macOS specific
  # NOTE: Removed osascript, system_profiler, defaults read to ask list
  #       These pose security risks and are in claude-permissions-ask.nix
  macosCommands = [
    "Bash(sw_vers:*)"
    "Bash(mdls:*)"
    "Bash(mdfind:*)"
    "Bash(pbcopy:*)"
    "Bash(pbpaste:*)"
  ];

  # Claude-specific tools (generally safe)
  claudeTools = [
    "WebSearch"
    "TodoWrite"
    "TodoRead"
  ];

  # Special: Read access with sensitive file exclusions
  readPermissions = [
    "Read(**)"
  ];

in
{
  # Export the complete allow list
  allowList = coreReadTools
    ++ gitCommands
    ++ githubCommands
    ++ nixCommands
    ++ homebrewCommands
    ++ pythonCommands
    ++ nodeCommands
    ++ rustCommands
    ++ dockerCommands
    ++ kubernetesCommands
    ++ awsCommands
    ++ databaseCommands
    ++ fileCommands
    ++ archiveCommands
    ++ networkCommands
    ++ systemCommands
    ++ processCommands
    ++ macosCommands
    ++ claudeTools;

  # Explicitly denied commands (destructive operations)
  denyList = [
    # Destructive file operations
    "Bash(rm -rf /*:*)"
    "Bash(rm -rf ~:*)"
    "Bash(rm -rf /:*)"

    # Sensitive file access
    "Read(.env)"
    "Read(.env.*)"
    "Read(**/.env)"
    "Read(**/.env.*)"
    "Read(**/secrets/**)"
    "Read(**/credentials/**)"
    "Read(**/*_rsa)"
    "Read(**/*_dsa)"
    "Read(**/*_ecdsa)"
    "Read(**/*_ed25519)"
    "Read(~/.ssh/id_*)"
    "Read(~/.aws/credentials)"
    "Read(~/.gnupg/**)"

    # Write operations (POST, PUT, DELETE, PATCH)
    "Bash(curl -X POST:*)"
    "Bash(curl -X PUT:*)"
    "Bash(curl -X DELETE:*)"
    "Bash(curl -X PATCH:*)"
    "Bash(curl --request POST:*)"
    "Bash(curl --request PUT:*)"
    "Bash(curl --request DELETE:*)"
    "Bash(curl --request PATCH:*)"
    "Bash(curl -d:*)"
    "Bash(curl --data:*)"

    # System modifications
    "Bash(sudo rm:*)"
    "Bash(sudo dd:*)"
    "Bash(mkfs:*)"
    "Bash(fdisk:*)"

    # Privilege escalation concerns
    "Bash(sudo su:*)"
    "Bash(sudo -i:*)"
    "Bash(sudo bash:*)"

    # Network security
    "Bash(nc -l:*)"
    "Bash(ncat -l:*)"
    "Bash(socat:*)"
  ];
}
