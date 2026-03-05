#!/usr/bin/env bash
# scripts/lib/expertise-id.sh
# Generates unique expertise record IDs: exp-YYYYMMDDHHMMSS-XXXX
# Usage: source this file, then call generate_expertise_id

generate_expertise_id() {
  local timestamp
  timestamp=$(date -u +%Y%m%d%H%M%S)
  local hex
  hex=$(head -c 2 /dev/urandom | od -An -tx1 | tr -d ' \n')
  echo "exp-${timestamp}-${hex}"
}
