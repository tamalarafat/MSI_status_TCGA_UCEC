#!/bin/bash -l
#PBS -N sarek_msi_tt
#PBS -l select=1:ncpus=32:mem=240gb
#PBS -l walltime=72:00:00
#PBS -j oe

set -euo pipefail

RESULTSDIR=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/vi_results
WORKROOT=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/vi_analysis/vi_tumortissue
CFG=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/vi_config/run-vi.config
PARAMS=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/vi_config/nf-params-vi.json
PIPE=/pfssmain/departments/pathologie/db/nf-wfs/cio-abcd-variantinterpretation_dev/dev
SING_CACHE=/pfssmain/departments/pathologie/db/nf-wfs/cio-abcd-variantinterpretation_dev/singularity-images

export TERM=dumb
export NXF_ANSI_LOG=false
export NXF_HOME="$HOME/.nextflow"
export NXF_OFFLINE='true'  # <-- disable unless plugins are pre-cached
export NXF_SINGULARITY_CACHEDIR="$SING_CACHE"
# export NXF_APPTAINER_CACHEDIR="$SING_CACHE"
export APPTAINER_CACHEDIR="$SING_CACHE"
export CONDA_PKGS_DIRS="$HOME/.conda/pkgs"

mkdir -p "$RESULTSDIR" "$WORKROOT/work" "$NXF_HOME" "$SING_CACHE" "$CONDA_PKGS_DIRS"

# activate Nextflow env
source "$HOME/miniconda3/bin/activate"
conda activate /pfssmain/home/tamyas01/conda-envs/nextflow-end

nextflow run "$PIPE" \
  -profile singularity,hilbert \
  -c "$CFG" \
  -params-file "$PARAMS" \
  --input /pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/vi_config/vi_samplesheet_tumor_tissue.csv \
  --outdir "$RESULTSDIR" \
  -work-dir "$WORKROOT/work" \
  -plugins nf-validation@1.0.0 \
  -resume


