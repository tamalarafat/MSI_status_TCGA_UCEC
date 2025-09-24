# Load the function
source("../functions/create_sarek_samplesheet.R")

# define path for the metadata cart JSON file and re-arranged sample sheet
json_path <- "../data/TCGA_metadata/metadata.cart.2024-01-10.json"

# Processed sample sheet - Tumor vs Blood normal
temp_samplesheet_tb <- "../data/config/samplesheet_tumor_blood_downloaded.csv"

create_sarek_samplesheet(sample_sheet = temp_samplesheet_tb, metadata_json_file = json_path, output_file_name = "../data/config/sarek_samplesheet_tumor_blood.csv")

# Processed sample sheet - Tumor vs Tissue normal
temp_samplesheet_tt <- "../data/config/samplesheet_tumor_tissue_downloaded.csv"

create_sarek_samplesheet(sample_sheet = temp_samplesheet_tt, metadata_json_file = json_path, output_file_name = "../data/config/sarek_samplesheet_tumor_tissue.csv")
