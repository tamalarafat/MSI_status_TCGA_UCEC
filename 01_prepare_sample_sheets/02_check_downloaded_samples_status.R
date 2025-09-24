# Load the function
source("../functions/check_downloaded_samples_status.R")

# Define your target directory
dir_path <- "/pfssmain/departments/pathologie/data/research/2025-TCGA-UCEC/"

# Sample sheet path:Tumor vs Blood normal
temp_samp_sheet_tb <- read.csv("../data/config/processed_samplesheet_tumor_blood.csv")

# Check download status
check_downloaded_samples_status(
  curated_sample_sheet = temp_samp_sheet_tb,
  file_dir_path = dir_path,
  output_downloaded_sheet_name = "../data/config/samplesheet_tumor_blood_downloaded.csv",
  output_not_downloaded_sheet_name = "../data/config/samplesheet_tumor_blood_notdownloaded.csv"
)

# Sample sheet path:Tumor vs Tissue normal
temp_samp_sheet_tt <- read.csv("../data/config/processed_samplesheet_tumor_tissue.csv") # Tumor vs Tissue normal

# Check download status
check_downloaded_samples_status(
  curated_sample_sheet = temp_samp_sheet_tt,
  file_dir_path = dir_path,
  output_downloaded_sheet_name = "../data/config/samplesheet_tumor_tissue_downloaded.csv",
  output_not_downloaded_sheet_name = "../data/config/samplesheet_tumor_tissue_notdownloaded.csv"
)
