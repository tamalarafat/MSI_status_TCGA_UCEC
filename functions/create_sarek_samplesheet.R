# Load the libs
library(rjson)
library(dplyr)

# Function to create the input sample sheet for sarek
create_sarek_samplesheet <- function(sample_sheet, metadata_json_file, output_file_name){
  
  # Check if the output file is to be saved in the working directory or a new directory
  if (!dir.exists(dirname(output_file_name))) {
    dir.create(dirname(output_file_name), recursive = TRUE, mode = "0777")
  }
  
  # Load the metadata cart JSON file
  temp_json <- fromJSON(file = metadata_json_file)
  
  # Input sample sheet - sarek
  temp_sheet <- read.csv(sample_sheet)
  
  # Now extract both fields using lapply
  temp_df <- lapply(temp_json, function(entry) {
    data.frame(
      sample_ID = entry[["associated_entities"]][[1]][["entity_submitter_id"]],
      file_ID   = entry[["file_id"]],
      stringsAsFactors = FALSE
    )
  })
  
  # Combine all rows into a single data frame
  temp_df <- do.call(rbind, temp_df)
  
  # Merge the tables
  temp_sheet$file_ID = basename(dirname(temp_sheet$bam))
  
  temp_sheet <- merge(temp_sheet, temp_df, by = "file_ID")
  
  # Re-arrange and re-name the columns
  sarek_sheet <- temp_sheet %>%
    mutate(
      short_sample_ID = sample,
      sample = sample_ID
    ) %>%
    select(-c(sample_ID, file_ID, short_sample_ID))
  
  # Write the sample sheet
  write.table(sarek_sheet, file = output_file_name, quote = FALSE, sep = ",", row.names = FALSE)
}