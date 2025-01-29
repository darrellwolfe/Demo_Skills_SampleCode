import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score

# Load and preprocess the data
data = pd.read_csv("land_data.csv")
# Preprocess the data as needed, including cleaning, transforming, and normalizing it.

# Select features and labels
features = ['factor1', 'factor2', 'factor3', 'factor4', 'factor5']
X = data[features]
y = data['land_value']

# Split data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the model
model = LinearRegression()
model.fit(X_train, y_train)

# Make predictions on test data
y_pred = model.predict(X_test)

# Evaluate the model performance
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)

print("Mean Squared Error: ", mse)
print("R-squared Score: ", r2)

# Use the trained model to make predictions on new data
new_data = pd.read_csv("new_land_data.csv")
X_new = new_data[features]
y_new_pred = model.predict(X_new)
