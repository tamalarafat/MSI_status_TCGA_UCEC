#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 -i <input_dir> -o <output_tsv> [-g <glob>]"
  echo "  -i  Directory containing per-sample TSVs (e.g. .../reports/TSV)"
  echo "  -o  Output file path (e.g. cohort_pathogenic.tsv)"
  echo "  -g  Glob pattern for files (default: 'TCGA-*pathogenic.tsv,TCGA-*__pathogenic.tsv')"
  exit 1
}

IN=""
OUT=""
GLOBS='TCGA-*pathogenic.tsv,TCGA-*__pathogenic.tsv'

while getopts ":i:o:g:h" opt; do
  case "$opt" in
    i) IN="$OPTARG" ;;
    o) OUT="$OPTARG" ;;
    g) GLOBS="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

[[ -z "$IN" || -z "$OUT" ]] && usage
[[ -d "$IN" ]] || { echo "ERROR: input dir '$IN' not found"; exit 2; }

# Split comma-separated glob list into an array
IFS=',' read -r -a PATTERNS <<< "$GLOBS"

# Collect matching files and sort them (stable)
mapfile -t FILES < <(
  shopt -s nullglob
  for pat in "${PATTERNS[@]}"; do
    # quote expansion carefully by using pushd/popd
    pushd "$IN" >/dev/null
    for f in $pat; do
      [[ -f "$f" ]] && printf "%s\n" "$f"
    done
    popd >/dev/null
  done | sort -V
)

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "ERROR: No files matched in '$IN' for patterns: ${PATTERNS[*]}" >&2
  exit 3
fi

# Write header once from the first file (drop the first column name)
> "$OUT"
{
  printf "sample\t"
  head -n1 "$IN/${FILES[0]}" | cut -f2-
} >> "$OUT"

# Append rows from each file, prefixing with sample ID
for f in "${FILES[@]}"; do
  base="${f##*/}"
  sample="${base%__pathogenic.tsv}"
  sample="${sample%_pathogenic.tsv}"
  tail -n +2 "$IN/$f" | sed $"s/^/${sample}\t/"
done >> "$OUT"

echo "Wrote $OUT"
