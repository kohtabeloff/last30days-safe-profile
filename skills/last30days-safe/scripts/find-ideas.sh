#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Pick a Python 3.12+ interpreter. LAST30DAYS_PYTHON always wins if it is set.
pick_python() {
  if [[ -n "${LAST30DAYS_PYTHON:-}" ]]; then
    printf '%s\n' "$LAST30DAYS_PYTHON"
    return 0
  fi
  local candidate
  for candidate in python3.12 python3.13 python3.14 python3; do
    if command -v "$candidate" >/dev/null 2>&1 \
      && "$candidate" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 12) else 1)' 2>/dev/null; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

if ! PYTHON_BIN="$(pick_python)"; then
  echo "last30days-safe: no Python 3.12+ interpreter found." >&2
  echo "Install Python 3.12 or newer, or point LAST30DAYS_PYTHON at one:" >&2
  echo "  LAST30DAYS_PYTHON=/path/to/python3 $0 \"topic\"" >&2
  exit 1
fi

ENGINE="$SCRIPT_DIR/last30days.py"
if [[ ! -f "$ENGINE" ]]; then
  echo "last30days-safe: engine not found at $ENGINE" >&2
  echo "Reinstall the skill, or run scripts/sync-upstream.sh to refresh the vendored engine." >&2
  exit 1
fi

extra_args=()
has_search=0
has_days=0
has_register=0
has_no_browser=0
has_discover=0

for arg in "$@"; do
  case "$arg" in
    --search=*|--search)
      has_search=1
      ;;
    --days=*|--days|--lookback-days=*|--lookback-days)
      has_days=1
      ;;
    --register=*|--register)
      has_register=1
      ;;
    --no-browser-cookies)
      has_no_browser=1
      ;;
    --discover|--discover=*|--nominate-only|--judgments|--finalize)
      has_discover=1
      ;;
  esac
done

if [[ $has_search -eq 0 && $has_discover -eq 0 ]]; then
  extra_args+=(--search reddit,hackernews,youtube)
fi
if [[ $has_days -eq 0 && $has_discover -eq 0 ]]; then
  extra_args+=(--days 7)
fi
if [[ $has_register -eq 0 && $has_discover -eq 0 ]]; then
  extra_args+=(--register creator)
fi
if [[ $has_no_browser -eq 0 ]]; then
  extra_args+=(--no-browser-cookies)
fi

exec "$PYTHON_BIN" "$ENGINE" "${extra_args[@]}" "$@"
