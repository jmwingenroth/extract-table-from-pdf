# Load libraries
library(tidyverse)

# Load parameters
time_variables <- paste0("Sep",24:20)

# Find file paths and data descriptions based on file-naming conventions
files <- list.files("data/", pattern = "extracted.*csv", full.names = TRUE, recursive = TRUE)
titles <- str_extract(files, "[a-z]+(?=\\.csv)") 

# Load raw data
raw_dfs <- lapply(files, read_csv, col_names = FALSE)

# Fix formatting
tidy_dfs <- raw_dfs %>%

    # Rename first column to ZIP code
    lapply(
        rename, 
        ZIP = X1
    ) %>%

    # Drop non-ZIP rows
    lapply(
        filter, 
        as.numeric(ZIP) >= 1e4, 
        as.numeric(ZIP) <= 1e5
    ) %>%

    # Drop columns with % or $ symbols appearing anywhere
    lapply(
        select_if, 
        \(x) !any(str_detect(x, "\\$|\\%"))
    ) %>%

    # Convert all columns to numeric
    lapply(
        mutate, 
        across(everything(), \(x) parse_number(str_remove(x, " |-")))
    ) %>%

    # Fix ZIP codes split across multiple rows (e.g., 96059)
    lapply(group_by, ZIP) %>%
    lapply(summarise_all, sum, na.rm = TRUE)

# Add descriptive column names (keeping ZIP the same)
for (i in 1:length(tidy_dfs)) {
    colnames(tidy_dfs[[i]])[-1] <- paste0(titles[i], "_", time_variables)
}

# Join into one dataframe and save
left_join(tidy_dfs[[1]], tidy_dfs[[2]], by = "ZIP") %>%
    write_csv("data/intermediate/FAIR_pdfs_tidy.csv")
