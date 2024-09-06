import pandas as pd
import matplotlib.pyplot as plt

# Path to the CSV file
file_path = 'C:/Users/dwolfe/Documents/Demo_Skills_SampleCode/Projects/National_Market_Markers/_dataframes/GasPrices_owd_intl_1861_2023.csv'

# Read the CSV file
df = pd.read_csv(file_path)

# Display the first few rows to verify the data
print(df.head())

# Filter data for years 1970 to 2023
filtered_df = df[(df['Year'] >= 1970) & (df['Year'] <= 2023)]

# Plotting the filtered data
plt.figure(figsize=(12, 6))  # Set figure size
plt.plot(filtered_df['Year'], filtered_df['Oil price - Crude prices since 1861 (current US$)'], marker='o', linestyle='-')
plt.title('International Crude Oil Prices from 1970 to 2023')
plt.xlabel('Year')
plt.ylabel('Oil Price (current US$)')
plt.grid(True)
plt.xticks(rotation=45)  # Rotate x-axis labels for better readability
plt.tight_layout()  # Adjust layout
plt.show()  # Display the plot
