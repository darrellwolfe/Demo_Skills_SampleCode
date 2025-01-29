from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# Route for the home page
@app.route('/')
def index():
    return render_template('index.html')

# Route for handling the request form submission
@app.route('/submit', methods=['POST'])
def submit():
    # Get the form data from the request
    name = request.form['name']
    email = request.form['email']
    message = request.form['message']
    
    # Process the form data (e.g., send an email, store in a database)
    print(f"Name: {name}")
    print(f"Email: {email}")
    print(f"Message: {message}")
    
    # Redirect to a success page or display a success message
    return redirect(url_for('index'))

if __name__ == '__main__':
    # Get the domain name of your machine
    domain_name = 'localhost'
    port = 5000
    
    # Run the Flask app on the specified domain name and port
    app.run(host=domain_name, port=port, debug=False)