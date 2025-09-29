# SOPS Setup Guide

*SOPS was added to this project with the help of Claude; we had a chat and this is the summary Claude generated after walking me through it all.*

This project uses [SOPS](https://github.com/getsops/sops) (Secrets OPerationS) for encrypting secrets, with [age](https://github.com/FiloSottile/age) as the encryption backend and [direnv](https://direnv.net/) for automatic secret loading.

## Initial Setup

### 1. Install Dependencies

```bash
# Install SOPS
curl -LO https://github.com/getsops/sops/releases/download/v3.9.0/sops-v3.9.0.linux.amd64
sudo mv sops-v3.9.0.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# Install age (via homebrew or apt)
brew install age
# or
sudo apt install age

# Install direnv
brew install direnv

# Add direnv hook to shell (~/.bashrc or ~/.zshrc)
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Generate Age Key Pair

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Save the public key output (starts with `age1...`) - you'll need it for the next step.

**Important:** Back up your private key (`~/.config/sops/age/keys.txt`) to a secure location (e.g., password manager). Without it, you cannot decrypt secrets.

### 3. Configure SOPS

Create `.sops.yaml` in project root:

```yaml
creation_rules:
  - path_regex: \.env\.sops$
    age: age1YOUR_PUBLIC_KEY_HERE
```

### 4. Create Encrypted Secrets

```bash
# Create your secrets file
nano .env.sops

# Add your secrets:
ANTHROPIC_API_KEY=your-key-here
AWS_ACCESS_KEY_ID=your-aws-key
# ... other secrets

# Encrypt in place
sops -e -i .env.sops
```

### 5. Setup direnv

Create `.envrc` in project root:

```bash
cat > .envrc << 'EOF'
# Load secrets from SOPS
set -a
source <(sops -d .env.sops)
set +a
EOF

# Allow direnv to execute
direnv allow
```

### 6. Update .gitignore

```
.env
.env.tmp
.envrc.local
```

## Daily Usage

Secrets automatically load when you `cd` into the project directory (thanks to direnv).

To manually decrypt and view secrets:
```bash
sops -d .env.sops
```

To edit secrets:
```bash
sops .env.sops
```

SOPS will decrypt, open your editor, then re-encrypt on save.

## New Machine Setup

1. Clone the repository
2. Install dependencies (SOPS, age, direnv)
3. Restore your age private key to `~/.config/sops/age/keys.txt`
4. Run `direnv allow` in the project directory
5. Secrets will automatically load when you `cd` into the directory

## How It Works

- **SOPS** encrypts your secrets file using AES-256
- **age** encrypts the AES key using public-key cryptography
- The encrypted `.env.sops` file is safe to commit to git
- **direnv** automatically loads decrypted secrets into your environment when you enter the directory

## Security Notes

- Never commit `.env` or unencrypted secrets
- Always back up your age private key securely
- The `.env.sops` file is safe to commit - it's encrypted
- If `.envrc` is modified, you must run `direnv allow` again (security feature)