# VI samplesheet - "Tumor vs Blood"
temp_tb <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_blood/mutect2/vi_samplesheet.csv")

# VI samplesheet - "Tumor vs Tissue"
temp_tt <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_tissue/mutect2/vi_samplesheet.csv")

# Find the samples that are present in both groups
temp_samp <- intersect(temp_tb$sample, temp_tt$sample)

# Remove the overlapping samples 
temp_tt_ss <- temp_tt[! temp_tt$sample %in% temp_samp, ]

write.table(
  temp_tt_ss,
  file = "vi_samplesheet_tumor_tissue.csv",
  quote = FALSE,
  sep = ",",
  row.names = FALSE)

# Now, create a samplesheet by putting together all of the samples from Tumor-Blood and Tumor-Tissue comparison
temp_all <- rbind.data.frame(temp_tb, temp_tt_ss)

write.table(
  file = "vi_samplesheet_all.csv",
  quote = FALSE,
  sep = ",",
  row.names = FALSE)
