import matplotlib.pyplot as plt

# Years from 1980 to 2025
years = list(range(1980, 2026))
# Approximate GDP values (in trillions USD) for each year
gdp = [
    2.8, 3.1, 3.2, 3.6, 4.0, 4.3, 4.5, 4.8, 5.1, 5.5, 5.9, 6.2, 6.6, 7.0, 7.4, 7.8, 8.2,
    8.7, 9.2, 9.7, 10.3, 10.6, 10.9, 11.2, 11.8, 12.5, 13.1, 13.8, 14.1, 14.0, 14.7, 15.5,
    16.2, 16.8, 17.4, 18.0, 18.6, 19.5, 20.5, 21.4, 21.0, 22.7, 24.0, 25.5, 26.8, 28.0
]

plt.figure(figsize=(10,6))
plt.plot(years, gdp, marker='o', linestyle='-')
plt.xlabel('Year')
plt.ylabel('US GDP (trillions USD)')
plt.title('US GDP (1980 - 2025)')
plt.grid(True)
plt.xticks(years[::5])  # Label every 5 years for clarity
plt.tight_layout()
plt.show()
