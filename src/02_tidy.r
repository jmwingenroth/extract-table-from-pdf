# Load libraries
library(tidyverse)

# Load raw data
raw_data <- read_csv(
    "data/extracted_raw.csv",
    col_names = FALSE
)

# Drop rows not associated with ZIP codes
zip_data <- raw_data %>%
    mutate(X1 = as.numeric(X1)) %>%
    filter(!is.na(X1))

# Check that digits weren't lost to non-numeric columns during extraction
if (any(c(
    any(zip_data$X3 != "$"),
    any(zip_data$X6 != "$"),
    any(zip_data$X9 != "$"),
    any(zip_data$X12 != "$"),
    any(zip_data$X14 != "$")
))) {
    stop("Data were tabulated incorrectly while extracting from PDF")
}

# Extract exposure columns from data and convert to numeric
exp_data <- zip_data %>%
    select(
        zip = X1, 
        expos_24 = X4, 
        expos_23 = X7, 
        expos_22 = X10, 
        expos_21 = X13, 
        expos_20 = X15
    ) %>%
    mutate(across(
        expos_24:expos_20, 
        \(x) parse_number(str_remove(x, " |-"))
    ))

# ZIP code 96059 has data split across two rows, can be combined with sum()
tidy_data <- exp_data %>% 
    group_by(zip) %>%
    summarise_all(sum, na.rm = TRUE)

write_csv(tidy_data, "data/exposure_tidy.csv")
