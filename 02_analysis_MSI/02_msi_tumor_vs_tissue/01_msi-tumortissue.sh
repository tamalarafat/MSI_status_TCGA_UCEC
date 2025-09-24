#!/bin/bash -l
#PBS -N sarek_msi_tt
#PBS -l select=1:ncpus=32:mem=240gb
#PBS -l walltime=72:00:00
#PBS -j oe

set -euo pipefail

RESULTSDIR=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/results/sarek_tumortissue
WORKROOT=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/comparison_tumor_tissue
CFG=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/run-sarek.config
PARAMS=/pfssmain/departments/pathologie/users/tamyas01/work_dir/sarek/comparison_tumor_tissue/nf-params-tt.json
PIPE=/pfssmain/home/tamyas01/nf-core-sarek_3.4.0/3_4_0
SING_CACHE=/pfssmain/home/tamyas01/singularity_dir

# --- runtime env for non-interactive node ---
export TERM=dumb
export NXF_ANSI_LOG=false
export NXF_HOME="$HOME/.nextflow"
export NXF_OFFLINE='true'
export NXF_SINGULARITY_CACHEDIR="$SING_CACHE"
export APPTAINER_CACHEDIR="$SING_CACHE"
export CONDA_PKGS_DIRS="$HOME/.conda/pkgs"

mkdir -p "$RESULTSDIR" "$WORKROOT/work" "$NXF_HOME" "$SING_CACHE" "$CONDA_PKGS_DIRS"

# --- activate your conda env that has the patched nextflow ---
source "$HOME/miniconda3/bin/activate"
conda activate /pfssmain/home/tamyas01/conda-envs/nextflow-end

# sanity (optional)
which nextflow
nextflow -v || true
singularity --version || apptainer --version || true

# --- run sarek ---
nextflow run "$PIPE" \
  -profile singularity,hilbert \
  -c "$CFG" \
  -params-file "$PARAMS" \
  -work-dir "$WORKROOT/work" \
  -resume

echo "Finished."