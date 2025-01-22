library(tidyverse)

raw_data <- read_csv(
    "data/extracted_raw.csv",
    skip = 1,
    col_names = FALSE
)

raw_data %>%
    transmute(
        zip_code = as.numeric(X1)
    ) %>%
    filter(!is.na(zip_code))
