check_downloaded_samples_status <- function(curated_sample_sheet, file_dir_path, output_downloaded_sheet_name, output_not_downloaded_sheet_name){
  
  # Check if the output file is to be saved in the working directory or a new directory
  if (!dir.exists(dirname(output_downloaded_sheet_name))) {
    dir.create(dirname(output_downloaded_sheet_name), recursive = TRUE, mode = "0777")
  }
  
  # List only folders (exclude files)
  folder_names <- list.dirs(path = file_dir_path, full.names = FALSE, recursive = FALSE)
  
  # All downloaded folders
  temp_downed_ind <- which(basename(dirname(curated_sample_sheet$bam)) %in% folder_names)
  
  # Subset the sample sheet to keep the samples that were downloaded
  temp_downloaded <- curated_sample_sheet[temp_downed_ind, ]
  rownames(temp_downloaded) <- NULL
  
  # Write the sample sheet
  write.table(temp_downloaded, file = output_downloaded_sheet_name, quote = FALSE, sep = ",", row.names = FALSE)
  
  # For the file that were not downloaded
  if (nrow(curated_sample_sheet) != nrow(temp_downloaded)){
    temp_not_downloaded <- curated_sample_sheet[-temp_downed_ind, ]
    rownames(temp_not_downloaded) <- NULL
    write.table(temp_not_downloaded, file = output_not_downloaded_sheet_name, quote = FALSE, sep = ",", row.names = FALSE)
  }
}

