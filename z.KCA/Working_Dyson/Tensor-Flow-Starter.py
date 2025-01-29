import tensorflow as tf
import pandas as pd

# Load the data set
data = pd.read_csv('sales_data.csv')

# Engineer the features
data['year_diff'] = data.groupby(['property_size'])['sale_price'].diff().fillna(0)

# Split the data into training and testing sets
train_data = data[data['year'] <= 2019]
test_data = data[data['year'] == 2020]

# Define the input and output features
X_train = train_data[['property_size', 'year']]
y_train = train_data['year_diff']

X_test = test_data[['property_size', 'year']]
y_test = test_data['year_diff']

# Define the linear regression model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(units=1, input_shape=[2])
])

# Compile the model
model.compile(optimizer=tf.optimizers.Adam(learning_rate=0.1), loss='mean_squared_error')

# Train the model
model.fit(X_train, y_train, epochs=100)

# Evaluate the model
loss = model.evaluate(X_test, y_test)
print('Mean squared error:', loss)

# Generate predictions for the test data
y_pred = model.predict(X_test)

# Visualize the results
import matplotlib.pyplot as plt

plt.scatter(test_data['property_size'], y_test, color='red')
plt.scatter(test_data['property_size'], y_pred, color='blue')
plt.xlabel('Property Size')
plt.ylabel('Year over Year Change in Price')
plt.show()
