import tkinter as tk
from tkinter import filedialog, messagebox
import docx
import logging
import os
from selenium import webdriver
from selenium.webdriver.edge.options import Options as EdgeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import time # For time.sleep()
import urllib.parse

# Define the directory for the log file
log_directory = os.path.expanduser('~\Documents')
log_filename = os.path.join(log_directory, 'resume_search_logic.log')

# Check if the directory exists, if not, create it
if not os.path.exists(log_directory):
    os.makedirs(log_directory)
    logging.info(f"Created directory at {log_directory}")

# Set up logging to file
logging.basicConfig(level=logging.INFO, filename=log_filename, filemode='a', 
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Test logging
logging.info("Logging system initialized. If you see this message, logging is configured correctly.")

# Add a check to display log file path
print(f"Log file path: {log_filename}")  # This line will print the log path to your console

# Rest of your script...


# Import keyring if available
try:
    import keyring
except ImportError:
    keyring = None
    logging.error("Keyring module is not installed.", exc_info=True)

# --- Keyring Utility Functions ---
def load_linkedin_credentials():
    if keyring:
        stored_username = keyring.get_password("linkedin", "username")
        stored_password = keyring.get_password("linkedin", "password")
        return stored_username, stored_password
    return None, None

def save_linkedin_credentials(username, password):
    if keyring:
        keyring.set_password("linkedin", "username", username)
        keyring.set_password("linkedin", "password", password)

# --- Resume and Parameters Functions ---
def read_resume(file_path):
    """Reads the text content from a .docx resume."""
    try:
        doc = docx.Document(file_path)
        full_text = [para.text for para in doc.paragraphs]
        return "\n".join(full_text)
    except Exception as e:
        messagebox.showerror("File Error", f"Error reading file: {e}")
        logging.error("Error reading resume file.", exc_info=True)
        return ""

def select_resume():
    file_path = filedialog.askopenfilename(filetypes=[("Word Documents", "*.docx")])
    if file_path:
        resume_text = read_resume(file_path)
        resume_preview.delete("1.0", tk.END)
        resume_preview.insert(tk.END, resume_text[:500])
        selected_resume.set(file_path)

def submit_parameters():
    params = {
        "remote_only": remote_var.get(),
        "desired_pay": desired_pay_entry.get(),
        "location": location_entry.get()
    }
    try:
        params["desired_pay"] = float(params["desired_pay"]) if params["desired_pay"] else None
    except ValueError:
        messagebox.showerror("Input Error", "Desired pay must be a number.")
        logging.error("Invalid input for desired pay.", exc_info=True)
        return
    
    logging.info("Selected Resume File: " + selected_resume.get())
    logging.info("Job Parameters:")
    for key, value in params.items():
        logging.info(f"{key}: {value}")
    
    messagebox.showinfo("Success", "Parameters submitted. You can now scrape LinkedIn jobs.")

# --- LinkedIn Scraping Functions ---
import urllib.parse

def scrape_linkedin_jobs():
    username = linkedin_username_entry.get()
    password = linkedin_password_entry.get()

    if not username or not password:
        messagebox.showerror("Credentials Error", "Please enter your LinkedIn username and password.")
        return

    # Construct the search URL based on user inputs
    keywords = keywords_entry.get()
    location = location_entry.get()
    search_params = {
        'keywords': keywords,
        'location': location,
        'f_TP': '1,2',  # Example: add time filters if needed
    }
    search_query = urllib.parse.urlencode(search_params)
    search_url = f"https://www.linkedin.com/jobs/search/?{search_query}"

    logging.info("Starting scrape_linkedin_jobs")
    driver = configure_webdriver()
    
    try:
        logging.info("Driver initialized. Navigating to LinkedIn login page...")
        driver.get("https://www.linkedin.com/login")
        
        WebDriverWait(driver, 10).until(EC.visibility_of_element_located((By.ID, "username")))
        logging.info("Login page loaded. Entering credentials...")
        driver.find_element(By.ID, "username").send_keys(username)
        driver.find_element(By.ID, "password").send_keys(password)
        driver.find_element(By.XPATH, "//button[@type='submit']").click()
        
        logging.info("Credentials submitted. Waiting for MFA verification...")
        messagebox.showinfo("MFA Verification", "If prompted with a verification code, please complete the verification in the browser, then click OK.")
        
        # Save credentials if 'Remember Credentials' is checked
        if remember_credentials_var.get():
            logging.info("Saving credentials using keyring.")
            save_linkedin_credentials(username, password)
        
        logging.info(f"Navigating to LinkedIn jobs page with search parameters: {search_url}")
        driver.get(search_url)  # Navigate directly to the constructed URL
        WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.CLASS_NAME, "jobs-search-results__list-item")))
        
        logging.info("Jobs page loaded. Scraping job titles...")
        job_titles = []
        job_cards = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")
        for card in job_cards:
            title_element = card.find_element(By.CSS_SELECTOR, "h3")
            job_titles.append(title_element.text)
        
        logging.info("Scraping completed. Closing driver...")
        driver.quit()
    except TimeoutException:
        logging.error("Failed to load the LinkedIn jobs page within the time limit.", exc_info=True)
        driver.quit()
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}", exc_info=True)
        driver.quit()

    return job_titles


def configure_webdriver():
    options = EdgeOptions()
    #options.add_argument("--disable-gpu")
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Edge(options=options)
    return driver

# --- GUI Setup ---
root = tk.Tk()
root.title("Resume and Job Parameters")

selected_resume = tk.StringVar()

# Resume selection frame
frame_resume = tk.Frame(root, padx=10, pady=10)
frame_resume.pack(fill=tk.BOTH, expand=True)

label_resume = tk.Label(frame_resume, text="Select your resume (.docx):")
label_resume.pack()
button_select = tk.Button(frame_resume, text="Browse", command=select_resume)
button_select.pack(pady=5)
resume_preview = tk.Text(frame_resume, height=10, width=80)
resume_preview.pack(pady=5)

# Job parameters frame
frame_params = tk.Frame(root, padx=10, pady=10)  # Ensure positive values for padx and pady
frame_params.pack(fill=tk.BOTH, expand=True)

remote_var = tk.BooleanVar()
checkbox_remote = tk.Checkbutton(frame_params, text="Remote Only", variable=remote_var)
checkbox_remote.pack(anchor='w')

label_pay = tk.Label(frame_params, text="Desired Pay:")
label_pay.pack(anchor='w')
desired_pay_entry = tk.Entry(frame_params)
desired_pay_entry.pack(fill=tk.X, pady=2)

label_location = tk.Label(frame_params, text="Desired Location:")
label_location.pack(anchor='w')
location_entry = tk.Entry(frame_params)
location_entry.pack(fill=tk.X, pady=2)

button_submit = tk.Button(root, text="Submit Parameters", command=submit_parameters)
button_submit.pack(pady=10)

# LinkedIn credentials frame
frame_linkedin = tk.Frame(root, padx=10, pady=10)  # Ensure consistent positive padding values
frame_linkedin.pack(fill=tk.BOTH, expand=True)

label_linkedin = tk.Label(frame_linkedin, text="LinkedIn Credentials")
label_linkedin.pack()

label_linkedin_username = tk.Label(frame_linkedin, text="Username:")
label_linkedin_username.pack(anchor='w')
linkedin_username_entry = tk.Entry(frame_linkedin)
linkedin_username_entry.pack(fill=tk.X, pady=2)

label_linkedin_password = tk.Label(frame_linkedin, text="Password:")
label_linkedin_password.pack(anchor='w')
linkedin_password_entry = tk.Entry(frame_linkedin, show="*")
linkedin_password_entry.pack(fill=tk.X, pady=2)

# Remember Credentials checkbox
remember_credentials_var = tk.BooleanVar()
remember_checkbox = tk.Checkbutton(frame_linkedin, text="Remember Credentials", variable=remember_credentials_var)
remember_checkbox.pack(anchor='w')

# Preload credentials if they exist
stored_username, stored_password = load_linkedin_credentials()
if stored_username:
    linkedin_username_entry.insert(0, stored_username)
if stored_password:
    linkedin_password_entry.insert(0, stored_password)

button_scrape = tk.Button(root, text="Scrape LinkedIn Jobs", command=scrape_linkedin_jobs)
button_scrape.pack(pady=10)

root.mainloop()
