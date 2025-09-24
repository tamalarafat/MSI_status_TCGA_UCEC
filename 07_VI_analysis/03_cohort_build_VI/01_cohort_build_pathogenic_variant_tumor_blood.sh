out="tumorblood_cohort_pathogenic.tsv" 
shopt -s nullglob 
first_hdr_done=false 
> "$out" 
for f in TCGA-*__pathogenic.tsv TCGA-*pathogenic.tsv; do 
 s=$(basename "$f" _pathogenic.tsv) 
 s=$(basename "$s" __pathogenic.tsv)  # tolerate double underscore pattern 
 if ! $first_hdr_done; then 
   printf "sample\t"; head -n1 "$f" | cut -f2- >> "$out" 
   first_hdr_done=true 
 fi 
 tail -n +2 "$f" | sed "s/^/$s\t/" >> "$out" 
done 
echo "Wrote $out"