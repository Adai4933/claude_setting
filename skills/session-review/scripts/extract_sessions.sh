#!/usr/bin/env bash
# Extract Claude Code session digests and user-typed prompts for behavior review.
# Output: $OUTDIR/digest.tsv (date, project, title, first prompt) and $OUTDIR/prompts/<project>.txt
# Usage: extract_sessions.sh [-d DAYS] [-p PROJECT_FILTER] [-o OUTDIR]
#   -d DAYS            look-back window in days (default 30)
#   -p PROJECT_FILTER  case-insensitive substring match on project dir slug (default: all)
#   -o OUTDIR          workspace dir (default ~/.claude/cache/session-review)
set -euo pipefail

DAYS=30
FILTER=""
OUTDIR="$HOME/.claude/cache/session-review"
while getopts "d:p:o:" opt; do
  case $opt in
    d) DAYS="$OPTARG" ;;
    p) FILTER="$OPTARG" ;;
    o) OUTDIR="$OPTARG" ;;
    *) echo "usage: $0 [-d days] [-p project_filter] [-o outdir]" >&2; exit 1 ;;
  esac
done

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR/prompts"

# Main-session transcripts only; subagent transcripts are Claude's own work, not user behavior.
find "$HOME/.claude/projects" -maxdepth 2 -name "*.jsonl" -mtime -"$DAYS" -not -path "*/subagents/*" | while read -r F; do
  proj=$(echo "$F" | sed 's|.*/projects/||; s|/[^/]*$||')
  if [ -n "$FILTER" ] && ! echo "$proj" | grep -qi "$FILTER"; then continue; fi
  date=$(stat -c %y "$F" | cut -d' ' -f1)
  title=$(jq -r 'select(.type=="ai-title") | .aiTitle' "$F" 2>/dev/null | head -1)
  # User-typed messages are string content; arrays are tool results. Lines starting
  # with "<" are command/caveat wrappers, not the user's words.
  msgs=$(jq -r 'select(.type=="user" and (.message.content|type=="string")) | .message.content' "$F" 2>/dev/null | grep -v '^<' | grep -v '^\s*$' || true)
  first=$(echo "$msgs" | head -1 | cut -c1-200)
  [ -z "$title" ] && [ -z "$first" ] && continue
  printf '%s\t%s\t%s\t%s\n' "$date" "$proj" "${title:-NO_TITLE}" "$first" >> "$OUTDIR/digest.tsv"
  if [ -n "$msgs" ]; then
    slug=$(echo "$proj" | sed 's|^-home-robin-Desktop-Workstation-||; s|^-home-robin|home|')
    { echo "=== SESSION $date $(basename "$F" .jsonl | cut -c1-8) ==="; echo "$msgs"; echo; } >> "$OUTDIR/prompts/${slug}.txt"
  fi
done

echo "workspace: $OUTDIR"
echo "sessions: $( [ -f "$OUTDIR/digest.tsv" ] && wc -l < "$OUTDIR/digest.tsv" || echo 0 )"
echo "prompt files by size:"
wc -l "$OUTDIR"/prompts/* 2>/dev/null | sort -rn | head -20 || echo "  none"
