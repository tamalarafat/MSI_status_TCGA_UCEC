#!/bin/bash -l
set -euo pipefail

# Usage check
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <INPUT_DIR_WITH_VCFS> <OUTPUT_DIR>"
  exit 1
fi

INDIR="$(realpath "$1")"
OUTDIR="$(realpath -m "$2")"

mkdir -p "$OUTDIR"

# 1) Build samplesheet_all.csv in OUTDIR
find "$INDIR" -maxdepth 2 -name '*.mutect2.vcf.gz' -type f -print0 \
| xargs -0 realpath \
| awk -v OFS=',' '
    BEGIN { print "sample,vcf" }
    {
      path = $0
      fname = path
      sub(/^.*\//, "", fname)                         # basename
      sub(/\.mutect2\.vcf\.gz$/, "", fname)           # drop suffix
      split(fname, vs, /_vs_/)                        # left/right samples
      left = vs[1]
      split(left, d, /-/)                             # split by dashes
      sample = d[1] "-" d[2] "-" d[3]                 # first 3 fields
      print sample, path
    }' > "$OUTDIR/samplesheet_all.csv"

# If nothing found, stop early
if [[ $(wc -l < "$OUTDIR/samplesheet_all.csv") -le 1 ]]; then
  echo "No *.mutect2.vcf.gz files found under: $INDIR"
  exit 0
fi

# 2) Count variants in all VCFs
outfile="$OUTDIR/mutect2_variants.txt"
: > "$outfile"

# safer read (handles weird chars better than for+word-splitting)
while IFS= read -r vcf; do
  count=$(zgrep -vc '^#' -- "$vcf")
  printf "%s\t%s\n" "$vcf" "$count" >> "$outfile"
done < <(awk -F, 'NR>1 {print $2}' "$OUTDIR/samplesheet_all.csv")

# 3) Build list of empty VCFs from the counts
awk '$2==0{print $1}' "$outfile" > "$OUTDIR/empty_vcfs.txt"

# 4) Filter out empty VCF rows from samplesheet_all.csv
tmp_dedup="$(mktemp)"
awk 'NF{empty[$0]=1} END{for(k in empty)print k}' "$OUTDIR/empty_vcfs.txt" > "$tmp_dedup"

if [[ -s "$tmp_dedup" ]]; then
  awk -F, -v OFS=',' '
    NR==FNR { empty[$0]=1; next }      # load empty vcf paths
    NR==1   { print; next }            # keep header
    { gsub(/^"|"$/, "", $2) }          # strip quotes if present
    !($2 in empty)                     # keep only non-empty vcfs
  ' "$tmp_dedup" "$OUTDIR/samplesheet_all.csv" > "$OUTDIR/vi_samplesheet.csv"
else
  # no empties -> copy all
  cp "$OUTDIR/samplesheet_all.csv" "$OUTDIR/vi_samplesheet.csv"
fi

rm -f "$tmp_dedup"

echo "Done."
echo "  All VCFs CSV : $OUTDIR/samplesheet_all.csv"
echo "  Counts       : $OUTDIR/mutect2_variants.txt"
echo "  Empty VCFs   : $OUTDIR/empty_vcfs.txt"
echo "  Final CSV    : $OUTDIR/vi_samplesheet.csv"
