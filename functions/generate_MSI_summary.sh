#!/usr/bin/env bash
set -euo pipefail

# Defaults
INPUT_DIR=""
OUTPUT_DIR=""
OUT_NAME="msi_summary.csv"
# By default, expect the summary file to be EXACTLY the folder name (your current convention).
# If you need to match e.g. "<pair>_summary.txt", pass: --pattern "*_summary.txt"
SUMMARY_PATTERN=""   # empty means "exact folder name"

print_usage() {
  cat <<EOF
Usage: $(basename "$0") -i <msisensorpro_output_dir> -o <output_dir> [--name <filename>] [--pattern <glob>]

Required:
  -i, --input DIR     Directory containing msisensorpro pair subfolders
  -o, --output DIR    Directory to write the summary CSV

Optional:
  --name FILE         Output CSV filename (default: msi_summary.csv)
  --pattern GLOB      Override summary filename pattern inside each pair folder.
                      Default is exact match to the folder name.
                      Example: --pattern "*.msi"  or  --pattern "*_summary.txt"

Examples:
  $(basename "$0") -i /path/to/msisensorpro -o /path/to/out
  $(basename "$0") -i results/msi -o results -–name msi_run2.csv
  $(basename "$0") -i results/msi -o results --pattern "*.msi"
EOF
}

# ---- parse args ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--input)  INPUT_DIR="${2-}"; shift 2 ;;
    -o|--output) OUTPUT_DIR="${2-}"; shift 2 ;;
    --name)      OUT_NAME="${2-}"; shift 2 ;;
    --pattern)   SUMMARY_PATTERN="${2-}"; shift 2 ;;
    -h|--help)   print_usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; print_usage; exit 1 ;;
  esac
done

# ---- validate ----
[[ -n "$INPUT_DIR"  ]] || { echo "ERROR: --input is required" >&2; print_usage; exit 1; }
[[ -n "$OUTPUT_DIR" ]] || { echo "ERROR: --output is required" >&2; print_usage; exit 1; }
[[ -d "$INPUT_DIR"  ]] || { echo "ERROR: Input dir not found: $INPUT_DIR" >&2; exit 1; }
mkdir -p "$OUTPUT_DIR"

OUT="$OUTPUT_DIR/$OUT_NAME"
tmp_out="$(mktemp)"
printf "pair,total_sites,somatic_sites,percentage\n" > "$tmp_out"

shopt -s nullglob
# Iterate over immediate subdirectories only
while IFS= read -r -d '' d; do
  pair="$(basename "$d")"

  # Determine the summary file path inside this pair folder
  if [[ -z "$SUMMARY_PATTERN" ]]; then
    # exact file name equals folder name
    f="$d/$pair"
    if [[ ! -f "$f" ]]; then
      echo "WARN: No exact-match summary file for $pair at $f" >&2
      continue
    fi
  else
    # glob pattern match inside folder (take the first match)
    matches=( "$d"/$SUMMARY_PATTERN )
    if [[ ${#matches[@]} -eq 0 || ! -f "${matches[0]}" ]]; then
      echo "WARN: No summary file matching '$SUMMARY_PATTERN' in $d" >&2
      continue
    fi
    f="${matches[0]}"
  fi

  # The summary is a 2-line TSV with headers. Parse flexibly by header names.
  awk -v pair="$pair" -F'\t' '
    NR==1 {
      for (i=1;i<=NF;i++) idx[$i]=i
      tot_col = idx["Total_Number_of_Sites"]
      som_col = idx["Number_of_Somatic_Sites"]
      pct_col = (idx["Percentage"] ? idx["Percentage"] : (idx["%"] ? idx["%"] : 0))
      next
    }
    NR==2 {
      tot = (tot_col ? $tot_col : "")
      som = (som_col ? $som_col : "")
      pct = (pct_col ? $pct_col : "")
      # normalize percent: drop trailing % if present
      gsub(/%$/, "", pct)
      printf "%s,%s,%s,%s\n", pair, tot, som, pct
      exit
    }
  ' "$f" >> "$tmp_out" || {
    echo "WARN: Failed to parse $f" >&2
  }

done < <(find "$INPUT_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

mv "$tmp_out" "$OUT"
echo "Wrote: $OUT"

