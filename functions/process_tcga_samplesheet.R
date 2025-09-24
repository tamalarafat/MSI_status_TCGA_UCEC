library(stringr)

# Function to create sample-sheet
process_tcga_samplesheet <- function(gdc_samplesheet, 
                                     sample_type_normal, 
                                     sample_type_tumor, 
                                     bam_path, 
                                     output_samplesheetname){
  
  # Check if the output file is to be saved in the working directory or a new directory
  if (!dir.exists(dirname(output_samplesheetname))) {
    dir.create(dirname(output_samplesheetname), recursive = TRUE, mode = "0777")
  }
  
  # Ensure path ends with "/"
  bam_path <- if (!grepl("/$", bam_path)) paste0(bam_path, "/") else bam_path
  
  # The sample types to compare
  sample_type <- c(sample_type_normal, sample_type_tumor)
  
  # Get the names for which sample types are not evenly matched
  temp_names_mismatch <- names(table(gdc_samplesheet$Case.ID)[table(gdc_samplesheet$Case.ID) == 1])
  
  # Let's exclude these samples
  temp_df_1 <- gdc_samplesheet[!(gdc_samplesheet$Case.ID %in% temp_names_mismatch), ]
  
  # Keep only those rows where the sample type is one of the two types
  temp_df_1 <- temp_df_1[str_detect(temp_df_1$Sample.Type, paste0(sample_type, collapse = "|")), ]
  
  # Now, get the case names
  temp_pat_ids <- unique(temp_df_1$Case.ID)
  
  # Let's create an empty vector to store the patient ids
  temp_collection_vec <- c()
  
  # Iterate over the patient ids and pick the ones eligible for the comparison
  for (i in c(1:length(temp_pat_ids))){
    temp_tab <- table(temp_df_1$Sample.Type[temp_df_1$Case.ID %in% temp_pat_ids[i]])
    
    # Check if the tumor and normal samples are collected for this patient
    if (all(sample_type %in% names(temp_tab)) & (temp_tab[sample_type_normal] == 1 && temp_tab[sample_type_tumor] == 1)) {
      temp_collection_vec <- c(temp_collection_vec, temp_pat_ids[i])
    }
  }
  
  # Let's keep the patients that satisfied the criteria
  temp_df_2 <- temp_df_1[temp_df_1$Case.ID %in% temp_collection_vec, ]
  
  rownames(temp_df_2) <- NULL
  
  # Add complete file path
  temp_df_2$File.Name <- paste0(bam_path, temp_df_2$File.ID, "/",temp_df_2$File.Name)
  
  # Rearrange and keep only the columns needed for the downstream analysis
  temp_df_2 <- temp_df_2[, c("Case.ID", "Sample.Type", "Sample.ID", "File.Name")]
  
  # Change the column names
  colnames(temp_df_2) <- c("patient", "status", "sample", "bam")
  
  # Create bai files column
  temp_df_2$bai <- gsub("bam$", "bai", temp_df_2$bam)
  
  # Change the sample type into binary: Tumor = 1, Normal = 0
  temp_df_2$status <- ifelse(temp_df_2$status == sample_type_tumor, 1, 0)
  
  # Reorder the data table to keep the pairs together
  temp_df_2 <- temp_df_2[order(temp_df_2$patient), ]
  rownames(temp_df_2) <- NULL
  
  write.table(temp_df_2, file = output_samplesheetname, quote = FALSE, sep = ",", row.names = FALSE)
  
}