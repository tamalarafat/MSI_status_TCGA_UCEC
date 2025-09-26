library(openxlsx)
library(dplyr)

# MSI-output
temp_yat <- read.xlsx("~/Documents/projects/replicate_MSI/main_results/results/MSI_results/20250926_TCGA_new_MSI_P53_POLE_neu_5y_YAT.xlsx")

# Subset the table generated from my analysis
temp_yat <- temp_yat[, c(1,3,4,5)]
colnames(temp_yat) <- paste0(colnames(temp_yat), "_yat")

## Load the table generated from KAI's analysis
temp_kh <- openxlsx::read.xlsx("~/Documents/projects/replicate_MSI/MSI_and_molecular_subtypes_table/grouped_patients_based_on_budd_and_subtypes/summarized_patient_table.xlsx")
temp_kh <- temp_kh[, c("Patient.ID", "Total_MSI_sites_assessed", "MSI_percentage", "Percentage3")]
colnames(temp_kh)[c(3,4)] <- c("MSI_sites_with_instability", "MSI_percentage")
colnames(temp_kh) <- paste0(colnames(temp_kh), "_kh")

## Let's compare the outputs
temp_mdf <- temp_kh %>% left_join(temp_yat, by = c("Patient.ID_kh" = "patient_id_yat"))

temp_mdf$pct_difference = temp_mdf$MSI_percentage_kh - temp_mdf$MSI_percentage_yat


# Save result
write.xlsx(temp_mdf, file = "~/Documents/projects/replicate_MSI/main_results/results/MSI_results/20250926_Yasir_Kai_result_comparison.xlsx", rowNames = FALSE)
