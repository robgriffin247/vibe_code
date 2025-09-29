#!/bin/bash
# Decrypt secrets and export to environment
export $(sops -d .env.sops | xargs)
echo "✓ Secrets loaded into environment"
