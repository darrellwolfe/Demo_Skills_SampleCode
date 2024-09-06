# Set the working directory to where the CSV file is stored (if needed)
setwd("path_to_your_dataframes_folder")

# Read the CSV file
df <- read.csv("_dataframes/GasPrices_eia_prices_1970_2022.csv")

# Display the first few rows of the dataframe
head(df)
