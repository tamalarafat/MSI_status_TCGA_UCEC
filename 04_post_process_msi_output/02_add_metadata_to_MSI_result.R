library(openxlsx)
library(dplyr)

# Load MSI result
temp_df <- read.csv("~/Documents/projects/replicate_MSI/main_results/results/MSI_results/MSI_status_TCGA_UCEC.csv")

# Molecular subtypes and tumor budding table - received from Prof. Tilman Rau
temp_subtype_df <- read.xlsx("~/Documents/projects/replicate_MSI/main_results/results/molecular_subtypes_table_original_2024/20240817_TCGA_new_MSI_P53_POLE_neu_5y_YAT.xlsx")

temp_col_names <- c("Patient.ID", "Tumorbudding_yes_no", "POLE_original", "POLE_Kai", "P53_original", "P53_Kai", "Mol_subtype_new", "Mol_subtype_new_numbered")
  
# Subset the data
temp_sub_df <- temp_subtype_df[, temp_col_names]
colnames(temp_sub_df)[c(1, 4, 6, 7, 8)] <- c("patient_id", "POLE_monitored", "P53_monitored", "molecular_subtype_new", "molecular_subtype_new_numbered")

# Let's put these informations together
temp_final_df <- temp_sub_df %>% left_join(temp_df, by = c("patient_id" = "patient_id"))

# Rearrange the columns
temp_final_df <- temp_final_df[, c(1, 2, 11:14, 3:10, 16:19, 15)]

# Let's add the missing classification: which did not add tumor vs tissue comparison
for (i in c(1:nrow(temp_final_df))){
  if (!is.na(temp_final_df[i, ]$MSI_classification) & temp_final_df[i, ]$MSI_classification == "MSI" & temp_final_df[i, ]$molecular_subtype_new == "not classified"){
    temp_final_df[i, ]$molecular_subtype_new = "MSI"
    temp_final_df[i, ]$molecular_subtype_new_numbered = 2
  }
  
  else if (!is.na(temp_final_df[i, ]$MSI_classification) & temp_final_df[i, ]$MSI_classification == "MSS" & temp_final_df[i, ]$molecular_subtype_new == "not classified"){
    temp_final_df[i, ]$molecular_subtype_new = "NSMP"
    temp_final_df[i, ]$molecular_subtype_new_numbered = 3
  }
}

# Let's push the na rows 
temp_final_df_1 <- temp_final_df[!is.na(temp_final_df$MSI_classification), ]

temp_final_df_2 <- temp_final_df[is.na(temp_final_df$MSI_classification), ]

final_df <- rbind.data.frame(temp_final_df_1, temp_final_df_2)

# Save result
write.xlsx(final_df, file = "~/Documents/projects/replicate_MSI/main_results/results/MSI_results/20250926_TCGA_new_MSI_P53_POLE_neu_5y_YAT.xlsx", rowNames = FALSE)

