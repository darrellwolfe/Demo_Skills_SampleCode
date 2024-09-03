import pandas as pd
import matplotlib.pyplot as plt

# Path to the CSV file
file_path = 'C:/Users/dwolfe/Documents/Demo_Skills_SampleCode/Projects/National_Market_Markers/_dataframes/GasPrices_eia_prices_1970_2022.csv'

# Read the CSV file
df = pd.read_csv(file_path)
# print(df['MSN'].unique())

# Filter rows where 'MSN' column contains 'AVACD'
filtered_df = df[df['MSN'].str.contains('MGACD', case=False, na=False)]

# Display the first few rows of the filtered dataframe
# print(filtered_df.head())

# Check how many rows match the filter
# print("Number of rows matching filter:", filtered_df.shape[0])

# Calculate the average for each year for the filtered data
average_prices = filtered_df.iloc[:, 3:].mean()  # Assumes year data starts at the 4th column

# Print the average prices
# print(average_prices)

# Create a line plot
plt.figure(figsize=(10, 5))  # Set the figure size
plt.plot(average_prices.index, average_prices.values, marker='o')  # Plot the average prices
plt.title('Average Gas Prices Over Years for MGACD')  # Add a title
plt.xlabel('Year')  # Add x-axis label
plt.ylabel('Average Price')  # Add y-axis label
plt.grid(True)  # Add a grid
plt.xticks(rotation=45)  # Rotate x-axis labels for better readability
plt.tight_layout()  # Adjust layout to make room for the rotated x-axis labels
plt.show()  # Display the plot


