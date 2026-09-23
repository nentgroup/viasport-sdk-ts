#!/usr/bin/env bash
set -euo pipefail

is_semver_tag() {
  [[ "$1" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

classify_markdown() {
  local text
  text=$(printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]')

  if grep -Eq '^#{1,6}[[:space:]].*breaking' <<<"$text"; then
    echo feat
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*(features|new features?)' <<<"$text"; then
    echo feat
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*(bug fixes|fixes)' <<<"$text"; then
    echo fix
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*performance' <<<"$text"; then
    echo perf
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*refactor' <<<"$text"; then
    echo refactor
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*(documentation|docs)' <<<"$text"; then
    echo docs
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*(build|dependencies|deps)' <<<"$text"; then
    echo build
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*ci' <<<"$text"; then
    echo ci
    return
  fi
  if grep -Eq '^#{1,6}[[:space:]].*tests?' <<<"$text"; then
    echo test
    return
  fi
}

has_breaking_markdown() {
  local text
  text=$(printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]')
  grep -Eq '^#{1,6}[[:space:]].*breaking' <<<"$text"
}

classify_subjects() {
  local subject raw_type best_type="" best_rank=999 rank

  while IFS= read -r subject; do
    subject=$(printf '%s\n' "$subject" | tr -d '\r')
    [[ -z "$subject" ]] && continue
    [[ "$subject" =~ $RELEASE_SKIP_SUBJECT_RE ]] && continue

    if [[ "$subject" =~ $CC_SUBJECT_RE ]]; then
      raw_type=${BASH_REMATCH[1],,}

      case "$raw_type" in
        feat) rank=1 ;;
        fix) rank=2 ;;
        perf) rank=3 ;;
        refactor) rank=4 ;;
        docs) rank=5 ;;
        build) rank=6 ;;
        ci) rank=7 ;;
        test) rank=8 ;;
        style) rank=9 ;;
        chore) rank=10 ;;
        revert) rank=11 ;;
        *) continue ;;
      esac

      if (( rank < best_rank )); then
        best_rank=$rank
        best_type=$raw_type
      fi
    fi
  done

  if [[ -n "$best_type" ]]; then
    echo "$best_type"
  fi
}

best_subject_from_subjects() {
  local subject raw_type best_subject="" best_rank=999 rank

  while IFS= read -r subject; do
    subject=$(printf '%s\n' "$subject" | tr -d '\r')
    [[ -z "$subject" ]] && continue
    [[ "$subject" =~ $RELEASE_SKIP_SUBJECT_RE ]] && continue

    if [[ "$subject" =~ $CC_SUBJECT_RE ]]; then
      raw_type=${BASH_REMATCH[1],,}

      case "$raw_type" in
        feat) rank=1 ;;
        fix) rank=2 ;;
        perf) rank=3 ;;
        refactor) rank=4 ;;
        docs) rank=5 ;;
        build) rank=6 ;;
        ci) rank=7 ;;
        test) rank=8 ;;
        style) rank=9 ;;
        chore) rank=10 ;;
        revert) rank=11 ;;
        *) continue ;;
      esac

      if (( rank < best_rank )); then
        best_rank=$rank
        best_subject=$subject
      fi
    fi
  done

  if [[ -n "$best_subject" ]]; then
    echo "$best_subject"
  fi
}

find_previous_release_tag() {
  local current_tag=$1 previous_tag=

  while IFS= read -r tag; do
    [[ -z "$tag" ]] && continue
    if [[ "$tag" == "$current_tag" ]]; then
      break
    fi
    previous_tag=$tag
  done < <(
    gh api "repos/${SPEC_REPO}/releases?per_page=100" --paginate --jq '.[].tag_name' \
      | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' \
      | sort -V
  )

  if [[ -n "$previous_tag" ]]; then
    echo "$previous_tag"
  fi
}

semver_fallback_type() {
  local previous_tag=${1#v} current_tag=${2#v}
  local prev_major prev_minor prev_patch curr_major curr_minor curr_patch

  if [[ -z "$previous_tag" ]]; then
    echo feat
    return
  fi

  IFS=. read -r prev_major prev_minor prev_patch <<<"$previous_tag"
  IFS=. read -r curr_major curr_minor curr_patch <<<"$current_tag"

  if (( curr_major > prev_major )); then
    echo feat
    return
  fi
  if (( curr_minor > prev_minor )); then
    echo feat
    return
  fi
  if (( curr_patch > prev_patch )); then
    echo fix
    return
  fi

  echo fix
}

subject_summary() {
  local subject=$1

  if [[ "$subject" =~ $CC_SUBJECT_RE ]]; then
    echo "${BASH_REMATCH[4]}"
    return
  fi

  echo "$subject"
}

: "${SPEC_REPO:?SPEC_REPO is required}"
: "${SPEC_REF:?SPEC_REF is required}"
: "${PKG:?PKG is required}"
: "${GITHUB_OUTPUT:?GITHUB_OUTPUT is required}"

REF_ENCODED=$(python3 - <<'PY'
import os
import urllib.parse
print(urllib.parse.quote(os.environ["SPEC_REF"], safe=""))
PY
)

COMMIT_JSON=$(gh api \
  -H "Accept: application/vnd.github+json" \
  "/repos/${SPEC_REPO}/commits/${REF_ENCODED}")

UPSTREAM_SHA=$(printf '%s' "$COMMIT_JSON" | jq -r '.sha')
UPSTREAM_MESSAGE=$(printf '%s' "$COMMIT_JSON" | jq -r '.commit.message')
UPSTREAM_SUBJECT=$(printf '%s\n' "$UPSTREAM_MESSAGE" | head -n1 | tr -d '\r')

CC_SUBJECT_RE='^([[:alpha:]][[:alnum:]-]*)(\([^)]+\))?(!)?:[[:space:]]+(.+)$'
CC_BREAKING_SUBJECT_RE='^([[:alpha:]][[:alnum:]-]*)(\([^)]+\))?!:[[:space:]]+'
RELEASE_SUBJECT_RE='^chore(\([^)]+\))?:[[:space:]]release[[:space:]]v?([0-9]+\.[0-9]+\.[0-9]+)([[:space:]]|$)'
RELEASE_SKIP_SUBJECT_RE='^chore(\([^)]+\))?:[[:space:]]release[[:space:]]'

PR_TYPE=fix
BREAKING_CHANGE=false
CLASSIFICATION_SOURCE=commit-subject
EFFECTIVE_SUBJECT="$UPSTREAM_SUBJECT"
RELEASE_TAG=
RELEASE_PR=
PREVIOUS_RELEASE_TAG=

if is_semver_tag "$SPEC_REF"; then
  RELEASE_TAG="$SPEC_REF"
elif [[ "$UPSTREAM_SUBJECT" =~ $RELEASE_SUBJECT_RE ]]; then
  RELEASE_VERSION=${BASH_REMATCH[2]}
  for candidate in "v${RELEASE_VERSION}" "${RELEASE_VERSION}"; do
    if gh api "repos/${SPEC_REPO}/releases/tags/${candidate}" >/dev/null 2>&1; then
      RELEASE_TAG="$candidate"
      break
    fi
  done
  if [[ -z "$RELEASE_TAG" ]]; then
    RELEASE_TAG="v${RELEASE_VERSION}"
  fi
fi

if [[ -n "$RELEASE_TAG" ]]; then
  PREVIOUS_RELEASE_TAG=$(find_previous_release_tag "$RELEASE_TAG")
  if [[ -n "$PREVIOUS_RELEASE_TAG" ]]; then
    COMPARE_SUBJECTS=$(gh api "repos/${SPEC_REPO}/compare/${PREVIOUS_RELEASE_TAG}...${RELEASE_TAG}" --paginate --jq '.commits[].commit.message | split("\n")[0]' 2>/dev/null || true)
    COMPARE_MESSAGES=$(gh api "repos/${SPEC_REPO}/compare/${PREVIOUS_RELEASE_TAG}...${RELEASE_TAG}" --paginate --jq '.commits[].commit.message' 2>/dev/null || true)
    COMPARE_TYPE=$(printf '%s\n' "$COMPARE_SUBJECTS" | classify_subjects)
    BEST_COMPARE_SUBJECT=$(printf '%s\n' "$COMPARE_SUBJECTS" | best_subject_from_subjects)

    if [[ -n "$BEST_COMPARE_SUBJECT" ]]; then
      EFFECTIVE_SUBJECT="$BEST_COMPARE_SUBJECT"
    fi
    if [[ -n "$COMPARE_TYPE" ]]; then
      PR_TYPE=$COMPARE_TYPE
      CLASSIFICATION_SOURCE=compare-commits
    fi
    if grep -Eiq '(^|[[:space:]])BREAKING[ -]CHANGE:' <<<"$COMPARE_MESSAGES"; then
      BREAKING_CHANGE=true
    fi
    if grep -Eq "$CC_BREAKING_SUBJECT_RE" <<<"$COMPARE_SUBJECTS"; then
      BREAKING_CHANGE=true
    fi
  fi

  if [[ "$CLASSIFICATION_SOURCE" != compare-commits ]]; then
    RELEASE_BODY=$(gh api "repos/${SPEC_REPO}/releases/tags/${RELEASE_TAG}" --jq '.body // ""' 2>/dev/null || true)
    RELEASE_NOTES_TYPE=$(classify_markdown "$RELEASE_BODY")
    if [[ -n "$RELEASE_NOTES_TYPE" ]]; then
      PR_TYPE=$RELEASE_NOTES_TYPE
      CLASSIFICATION_SOURCE=release-notes
      if has_breaking_markdown "$RELEASE_BODY"; then
        BREAKING_CHANGE=true
      fi
    fi
  fi

  if [[ "$CLASSIFICATION_SOURCE" != compare-commits && "$CLASSIFICATION_SOURCE" != release-notes ]]; then
    if [[ "$UPSTREAM_SUBJECT" =~ \(#([0-9]+)\)$ ]]; then
      RELEASE_PR=${BASH_REMATCH[1]}
    else
      RELEASE_PR=$(gh api "repos/${SPEC_REPO}/commits/${UPSTREAM_SHA}/pulls" --jq '.[0].number // ""' 2>/dev/null | head -n1 || true)
    fi

    if [[ -n "$RELEASE_PR" ]]; then
      RELEASE_PR_BODY=$(gh api "repos/${SPEC_REPO}/pulls/${RELEASE_PR}" --jq '.body // ""' 2>/dev/null || true)
      RELEASE_PR_TYPE=$(classify_markdown "$RELEASE_PR_BODY")
      if [[ -n "$RELEASE_PR_TYPE" ]]; then
        PR_TYPE=$RELEASE_PR_TYPE
        CLASSIFICATION_SOURCE=release-pr-body
        if has_breaking_markdown "$RELEASE_PR_BODY"; then
          BREAKING_CHANGE=true
        fi
      fi
    fi
  fi

  if [[ "$CLASSIFICATION_SOURCE" != compare-commits && "$CLASSIFICATION_SOURCE" != release-notes && "$CLASSIFICATION_SOURCE" != release-pr-body ]]; then
    if [[ -n "$PREVIOUS_RELEASE_TAG" ]]; then
      PR_TYPE=$(semver_fallback_type "$PREVIOUS_RELEASE_TAG" "$RELEASE_TAG")
    else
      PR_TYPE=$(semver_fallback_type "" "$RELEASE_TAG")
    fi
    CLASSIFICATION_SOURCE=semver-fallback
  fi
else
  PR_BANG=

  if [[ "$UPSTREAM_SUBJECT" =~ $CC_SUBJECT_RE ]]; then
    RAW_TYPE=${BASH_REMATCH[1],,}
    PR_BANG=${BASH_REMATCH[3]:-}

    case "$RAW_TYPE" in
      feat|fix|chore|refactor|docs|perf|build|ci|test|style|revert)
        PR_TYPE=$RAW_TYPE
        ;;
    esac
  fi

  if [[ -n "$PR_BANG" ]] || printf '%s\n' "$UPSTREAM_MESSAGE" | grep -Eiq '(^|[[:space:]])BREAKING[ -]CHANGE:'; then
    BREAKING_CHANGE=true
  fi
fi

PR_BANG=
if [[ "$BREAKING_CHANGE" == true ]]; then
  PR_BANG='!'
fi

PR_PREFIX="${PR_TYPE}${PR_BANG}"
PR_SUMMARY=$(subject_summary "$EFFECTIVE_SUBJECT")
if [[ -z "$PR_SUMMARY" ]] || [[ "$PR_SUMMARY" =~ $RELEASE_SKIP_SUBJECT_RE ]]; then
  PR_SUMMARY="regenerate ${PKG} client from ${SPEC_REF}"
fi

LABELS=("automated" "sdk-regeneration" "type:${PR_TYPE}")
if [[ "$BREAKING_CHANGE" == true ]]; then
  LABELS+=("breaking-change")
fi

LABELS_CSV=$(IFS=,; echo "${LABELS[*]}")
LABELS_JSON=$(printf '%s\n' "${LABELS[@]}" | jq -R . | jq -sc .)

{
  echo "upstream_sha=${UPSTREAM_SHA}"
  echo "upstream_subject=${UPSTREAM_SUBJECT}"
  echo "effective_subject=${EFFECTIVE_SUBJECT}"
  echo "pr_type=${PR_TYPE}"
  echo "pr_prefix=${PR_PREFIX}"
  echo "breaking_change=${BREAKING_CHANGE}"
  echo "classification_source=${CLASSIFICATION_SOURCE}"
  echo "release_tag=${RELEASE_TAG}"
  echo "release_pr=${RELEASE_PR}"
  echo "pr_commit_message=${PR_PREFIX}: ${PR_SUMMARY}"
  echo "pr_title=${PR_PREFIX}: regenerate ${PKG} client from ${SPEC_REF}"
  echo "labels_csv=${LABELS_CSV}"
  echo "labels_json=${LABELS_JSON}"
} >> "$GITHUB_OUTPUT"

