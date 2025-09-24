# MSI-sensor pro output from comparison "Tumor vs Blood"
temp_tb <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_blood/MSISENSORPRO/msi_tumor_blood_output.csv")

# MSI-sensor pro output from comparison "Tumor vs Tissue"
temp_tt <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_tissue/MSISENSORPRO/msi_tumor_tissue_output.csv")

# Put all the information together
temp_df <- rbind.data.frame(temp_tb, temp_tt)

temp_df$sample_1 <- do.call(rbind, strsplit(temp_df$pair, "_vs_", fixed = TRUE))[, 1]
temp_df$sample_2 <- do.call(rbind, strsplit(temp_df$pair, "_vs_", fixed = TRUE))[, 2]

# 2) patient_id from sample_1 (up to the 3rd "-")
temp_df$patient_id <- sub("^((?:[^-]+-){2}[^-]+).*", "\\1", temp_df$sample_1)

# 3) Short Sample ID
temp_df$tumor_sample_ID_short <- sub("^((?:[^-]+-){3}[^-]+).*", "\\1", temp_df$sample_1)

temp_df$normal_sample_ID_short <- sub("^((?:[^-]+-){3}[^-]+).*", "\\1", temp_df$sample_2)

# Rearrange the columns
temp_df <- temp_df[, c(7, 8, 9, 5, 6, 2, 3, 4)]

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
temp_ss_tb <- temp_ss_tb[, c("sample", "bam")]
temp_ss_tb$bam <- basename(dirname(temp_ss_tb$bam))
colnames(temp_ss_tb)[2] <- "case_ID"

# Save result
write.table(temp_df, file = "~/Documents/projects/replicate_MSI/main_results/results/MSI_results/MSI_status_TCGA_UCEC.csv", quote = FALSE, sep = ",", row.names = FALSE)
