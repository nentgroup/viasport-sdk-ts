#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${LABELS_JSON:?LABELS_JSON is required}"
: "${REPO:?REPO is required}"

printf '%s' "$LABELS_JSON" | jq -r '.[]' | while read -r label; do
  case "$label" in
    automated)
      color="0e8a16"
      description="Automated change"
      ;;
    sdk-regeneration)
      color="1d76db"
      description="SDK regeneration update"
      ;;
    breaking-change)
      color="b60205"
      description="Contains breaking changes from the upstream API"
      ;;
    type:feat)
      color="a2eeef"
      description="Regeneration triggered by an upstream feat commit"
      ;;
    type:fix)
      color="d73a4a"
      description="Regeneration triggered by an upstream fix commit"
      ;;
    type:docs)
      color="0075ca"
      description="Regeneration triggered by an upstream docs commit"
      ;;
    type:perf)
      color="5319e7"
      description="Regeneration triggered by an upstream perf commit"
      ;;
    type:refactor)
      color="fbca04"
      description="Regeneration triggered by an upstream refactor commit"
      ;;
    type:build|type:ci|type:chore|type:revert|type:style|type:test)
      color="cfd3d7"
      description="Regeneration triggered by upstream conventional commit metadata"
      ;;
    *)
      color="ededed"
      description="Regeneration triggered by upstream conventional commit metadata"
      ;;
  esac

  gh label create "$label" \
    --repo "$REPO" \
    --color "$color" \
    --description "$description" \
    --force
done

