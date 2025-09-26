# MSI-sensor pro output from comparison "Tumor vs Blood"
temp_tb <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_blood/MSISENSORPRO/msi_tumor_blood_output.csv")

# 1) Add sample information 
temp_tb$sample_1 <- do.call(rbind, strsplit(temp_tb$pair, "_vs_", fixed = TRUE))[, 1]
temp_tb$sample_2 <- do.call(rbind, strsplit(temp_tb$pair, "_vs_", fixed = TRUE))[, 2]

# 2) patient_id from sample_1 (up to the 3rd "-")
temp_tb$patient_id <- sub("^((?:[^-]+-){2}[^-]+).*", "\\1", temp_tb$sample_1)

# Adding metadata - comparison information
temp_tb$tumor_compared_to <- "Blood"

# MSI-sensor pro output from comparison "Tumor vs Tissue"
temp_tt <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_tissue/MSISENSORPRO/msi_tumor_tissue_output.csv")

# 1) Add sample information 
temp_tt$sample_1 <- do.call(rbind, strsplit(temp_tt$pair, "_vs_", fixed = TRUE))[, 1]
temp_tt$sample_2 <- do.call(rbind, strsplit(temp_tt$pair, "_vs_", fixed = TRUE))[, 2]

# 2) patient_id from sample_1 (up to the 3rd "-")
temp_tt$patient_id <- sub("^((?:[^-]+-){2}[^-]+).*", "\\1", temp_tt$sample_1)

# Adding metadata - comparison information
temp_tt$tumor_compared_to <- "Tissue"

# Remove the patients from Tumor vs Tissue comparison which are already present in Tumor vs Blood comparison
temp_match <- intersect(temp_tb$patient_id, temp_tt$patient_id)

# Removing
temp_tt <-temp_tt[!temp_tt$patient_id %in% temp_match, ]

# Put all the information together
temp_df <- rbind.data.frame(temp_tb, temp_tt)

# 3) Short Sample ID
temp_df$tumor_sample_ID_short <- sub("^((?:[^-]+-){3}[^-]+).*", "\\1", temp_df$sample_1)

temp_df$normal_sample_ID_short <- sub("^((?:[^-]+-){3}[^-]+).*", "\\1", temp_df$sample_2)

# Rearrange the columns
temp_df <- temp_df[, c(7, 9, 10, 5, 6, 2, 3, 4, 8)]

# Assign column names
colnames(temp_df)[c(4, 5, 6, 7, 8)] <- c("tumor_sample_compared", "normal_sample_compared", "total_MSI_sites_assessed", "MSI_sites_with_instability", "MSI_percentage")

# Assign MSI status
temp_df$MSI_classification <- ifelse(temp_df$MSI_percentage >= 2, "MSI", "MSS")


# Add case-id information

# Tumor vs Blood
temp_ss_tb <- read.csv("~/Documents/projects/MSI_status_TCGA_UCEC/data/config/sarek_config_tumor_blood/sarek_samplesheet_tumor_blood.csv")
temp_ss_tb <- temp_ss_tb[, c("sample", "bam")]
temp_ss_tb$bam <- basename(dirname(temp_ss_tb$bam))
colnames(temp_ss_tb)[2] <- "case_ID"

# Tumor vs Tissue
temp_ss_tt <- read.csv("~/Documents/projects/MSI_status_TCGA_UCEC/data/config/sarek_config_tumor_tissue/sarek_samplesheet_tumor_tissue.csv")
temp_ss_tt <- temp_ss_tt[, c("sample", "bam")]
temp_ss_tt$bam <- basename(dirname(temp_ss_tt$bam))
colnames(temp_ss_tt)[2] <- "case_ID"

# Put these two table together
temp_ss <- rbind.data.frame(temp_ss_tb, temp_ss_tt)

# remove the duplicated samples
temp_ss <- temp_ss[-which(duplicated(temp_ss$sample)), ]

# Incorporate information - Tumor cases
temp_df$tumor_case_ID <- temp_ss$case_ID[match(temp_df$tumor_sample_compared, temp_ss$sample)]
temp_df$normal_case_ID <- temp_ss$case_ID[match(temp_df$normal_sample_compared, temp_ss$sample)]

# Re-arrange columns
temp_df <- temp_df[, c(1,2,3,6,7,8,10,9,4,5,11,12)]

# Save result
write.table(temp_df, file = "~/Documents/projects/replicate_MSI/main_results/results/MSI_results/MSI_status_TCGA_UCEC.csv", quote = FALSE, sep = ",", row.names = FALSE)
