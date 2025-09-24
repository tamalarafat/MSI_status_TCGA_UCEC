# Load the function
source("../functions/process_tcga_samplesheet.R")

# Load the GDC sample sheet - downloaded while retrieving tcga data
temp_samp_sheet <- read.delim("../data/TCGA_metadata/gdc_sample_sheet.2024-01-10.tsv")

# Location of the BAM files
bam_path <- "/pfssmain/departments/pathologie/data/research/2025-TCGA-UCEC/"

# Sample types to compare against "Primary Tumor"

sample_type_normal_blood <- "Blood Derived Normal" # Blood samples
sample_type_normal_tissue <- "Solid Tissue Normal" # Tissue samples
sample_type_tumor <- "Primary Tumor"

# Process and arrange sample sheet for tumor vs normal comparison

# Tumor vs normal blood
process_tcga_samplesheet(gdc_samplesheet = temp_samp_sheet, sample_type_normal = sample_type_normal_blood, sample_type_tumor = sample_type_tumor, bam_path = bam_path, output_samplesheetname = "../data/config/processed_samplesheet_tumor_blood.csv")

# Tumor vs normal tissue
process_tcga_samplesheet(gdc_samplesheet = temp_samp_sheet, sample_type_normal = sample_type_normal_tissue, sample_type_tumor = sample_type_tumor, bam_path = bam_path, output_samplesheetname = "../data/config/processed_samplesheet_tumor_tissue.csv")




