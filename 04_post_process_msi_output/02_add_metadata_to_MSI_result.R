library(openxlsx)

# Load MSI result
temp_df <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/MSI_results/MSI_status_TCGA_UCEC.csv")

# Molecular subtypes and tumor budding table - received from Prof. Tilman Rau
temp_subtype_df <- read.xlsx("~/Documents/projects/replicate_MSI/main_results/results/molecular_subtypes_table/20240817_TCGA_new_MSI_P53_POLE_neu_5y_YAT.xlsx")

temp_col_names <- c("Patient.ID", "Tumorbudding_yes_no", "POLE_original", "POLE_Kai", "P53_original", "P53_Kai", "Mol_subtype_new", "Mol_subtype_new_numbered")
  
# Subset the data
temp_sub_df <- temp_subtype_df[, temp_col_names]
colnames(temp_sub_df)[c(4, 6, 7, 8)] <- c("POLE_monitored", "P53_monitored", "molecular_subtype_new", "molecular_subtype_new_numbered")


## Load the table generated from KAI's analysis
temp_kh <- openxlsx::read.xlsx("~/Documents/projects/replicate_MSI/MSI_and_molecular_subtypes_table/grouped_patients_based_on_budd_and_subtypes/summarized_patient_table.xlsx")
temp_kh <- temp_kh[, c("Patient.ID", "Total_MSI_sites_assessed", "MSI_percentage", "Percentage3")]
colnames(temp_kh)[c(3,4)] <- c("MSI_sites_with_instability", "MSI_percentage")

### 474 patients from the tumor blood comparison listed in the table
length(intersect(temp_kh$Patient.ID, temp_yat$Patient.ID))

## Let's compare the outputs

# Subset the table generated from my analysis
temp_yat <- temp_df[, c(7,2,3,4)]

colnames(temp_yat) <- c("Patient.ID", "YAT_Total_MSI_sites_assessed", "YAT_MSI_sites_with_instability", "YAT_MSI_percentage")

temp_mdf <- merge(temp_kh, temp_yat, by = "Patient.ID", all = F)

temp_mdf$pct_difference = temp_mdf$MSI_percentage - temp_mdf$YAT_MSI_percentage

#### KAI only included Tumor vs Blood results
# MSI-sensor pro output from comparison "Tumor vs Blood"
temp_tb <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_blood/MSISENSORPRO/msi_tumor_blood_output.csv")

# Put all the information together
temp_df <- temp_tb


temp_df$sample_1 <- do.call(rbind, strsplit(temp_df$pair, "_vs_", fixed = TRUE))[, 1]
temp_df$sample_2 <- do.call(rbind, strsplit(temp_df$pair, "_vs_", fixed = TRUE))[, 2]

# 2) patient_id from sample_1 (up to the 3rd "-")
temp_df$patient_id <- sub("^((?:[^-]+-){2}[^-]+).*", "\\1", temp_df$sample_1)

# Subset the table generated from my analysis
temp_yat <- temp_df[, c(7,2,3,4)]

colnames(temp_yat) <- c("Patient.ID", "YAT_Total_MSI_sites_assessed", "YAT_MSI_sites_with_instability", "YAT_MSI_percentage")

temp_mdf <- merge(temp_kh, temp_yat, by = "Patient.ID", all.x = T)

temp_mdf$pct_difference = temp_mdf$MSI_percentage - temp_mdf$YAT_MSI_percentage


### Let's take the missing MSI cases
temp_kh_miss <- temp_kh[which(is.na(temp_kh$MSI_percentage)), ]
rownames(temp_kh_miss) <- NULL

temp_kh_miss_fill <- merge(temp_kh_miss, temp_yat, by = "Patient.ID", all.x = T)

#### KAI only included Tumor vs Blood results
# MSI-sensor pro output from comparison "Tumor vs Blood"
temp_tb <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/sarek_comparison_tumor_blood/MSISENSORPRO/msi_tumor_blood_output.csv")

# Put all the information together
temp_df <- temp_tb


temp_df$sample_1 <- do.call(rbind, strsplit(temp_df$pair, "_vs_", fixed = TRUE))[, 1]
temp_df$sample_2 <- do.call(rbind, strsplit(temp_df$pair, "_vs_", fixed = TRUE))[, 2]

# 2) patient_id from sample_1 (up to the 3rd "-")
temp_df$patient_id <- sub("^((?:[^-]+-){2}[^-]+).*", "\\1", temp_df$sample_1)

# Subset the table generated from my analysis
temp_yat <- temp_df[, c(7,2,3,4)]

colnames(temp_yat) <- c("Patient.ID", "YAT_Total_MSI_sites_assessed", "YAT_MSI_sites_with_instability", "YAT_MSI_percentage")

temp_mdf <- merge(temp_kh, temp_yat, by = "Patient.ID", all.x = T)

temp_mdf$pct_difference = temp_mdf$MSI_percentage - temp_mdf$YAT_MSI_percentage


### Let's take the missing MSI cases
temp_kh_miss <- temp_kh[which(is.na(temp_kh$MSI_percentage)), ]
rownames(temp_kh_miss) <- NULL

temp_kh_miss_fill <- merge(temp_kh_miss, temp_yat, by = "Patient.ID", all.x = T)