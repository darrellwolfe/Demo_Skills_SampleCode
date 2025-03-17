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
import urllib.parse
import time

# ----------------------------------------------------
# Logging and Screenshot Directory Setup
# ----------------------------------------------------
log_directory = os.path.expanduser(r'~\Documents')
log_filename = os.path.join(log_directory, 'resume_search_logic.log')
screenshot_filename = os.path.join(log_directory, 'job_search_screenshot.png')

if not os.path.exists(log_directory):
    os.makedirs(log_directory)

logging.basicConfig(
    level=logging.INFO, 
    filename=log_filename, 
    filemode='a',
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logging.info("Logging system initialized.")
print(f"Log file path: {log_filename}")

# ----------------------------------------------------
# Resume & Parameter Functions
# ----------------------------------------------------
logging.info("Read Resume Logic.")
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

logging.info("Select Resume Logic.")
def select_resume():
    file_path = filedialog.askopenfilename(filetypes=[("Word Documents", "*.docx")])
    if file_path:
        resume_text = read_resume(file_path)
        resume_preview.delete("1.0", tk.END)
        resume_preview.insert(tk.END, resume_text[:500])
        selected_resume.set(file_path)

logging.info("Submit Parameters Logic.")
def submit_parameters():
    params = {
        "remote_only": remote_var.get(),
        "desired_pay": desired_pay_entry.get(),
        "location": location_entry.get(),
        "keywords": keywords_entry.get()
    }
    # Validate desired pay if present
    try:
        if params["desired_pay"]:
            float(params["desired_pay"])  # Just to check it's numeric
    except ValueError:
        messagebox.showerror("Input Error", "Desired pay must be a number.")
        logging.error("Invalid input for desired pay.", exc_info=True)
        return

    # Log the parameters
    logging.info("Selected Resume File: " + selected_resume.get())
    logging.info("Job Parameters:")
    for key, value in params.items():
        logging.info(f"{key}: {value}")
    
    messagebox.showinfo("Success", "Parameters submitted. You can now scrape Google jobs.")

logging.info("Google URL Logic.")
# ----------------------------------------------------
# Google Scraping Functions
# ----------------------------------------------------
def get_google_jobs_search_url():
    """Construct a Google job search URL from user inputs."""
    keywords = keywords_entry.get().strip() + " " + desired_pay_entry.get().strip() + " jobs"
    location = location_entry.get().strip()
    remote = remote_var.get()
    
    if remote:
        location = "Remote"
    
    query_params = {
        'q': keywords,
        'l': location,
        'ibp': 'htl;jobs'
    }
    query_string = urllib.parse.urlencode(query_params)
    return f"https://www.google.com/search?{query_string}"

logging.info("Google Scrape Logic.")
def scrape_google_jobs():
    """Scrape jobs from Google using the constructed URL."""
    job_search_url = get_google_jobs_search_url()
    logging.info(f"Starting job scrape. URL: {job_search_url}")
    
    driver = configure_webdriver()
    job_titles = []

    try:
        driver.get(job_search_url)
        WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "div.g"))
        )
        job_cards = driver.find_elements(By.CSS_SELECTOR, "div.g")
        for card in job_cards:
            try:
                title_element = card.find_element(By.CSS_SELECTOR, 'h2')
            except Exception as e:
                logging.info("h2 not found, trying alternative selector.")
                try:
                    title_element = card.find_element(By.CSS_SELECTOR, "div.job-title")
                except Exception as e:
                    logging.warning("Job title element not found for a card. Skipping this card.")
                    continue
            job_titles.append(title_element.text)
        
        logging.info(f"Scraping completed. Found {len(job_titles)} job titles.")
        messagebox.showinfo("Scraping Completed", f"Found {len(job_titles)} job titles.")
    except TimeoutException:
        driver.save_screenshot(screenshot_filename)  # Save screenshot at the defined path
        logging.error("Timeout waiting for job results, screenshot saved at " + screenshot_filename)
        messagebox.showerror("Timeout", "Failed to load job results within the time limit. Screenshot saved at " + screenshot_filename)
    finally:
        driver.quit()

    return job_titles

logging.info("Webdriver Logic.")
def configure_webdriver():
    """Configure the Selenium WebDriver."""
    options = EdgeOptions()
    driver = webdriver.Edge(options=options)
    return driver

# ----------------------------------------------------
# GUI Setup
# ----------------------------------------------------
root = tk.Tk()
root.title("Resume and Job Search")

selected_resume = tk.StringVar()

frame_resume = tk.Frame(root, padx=10, pady=10)
frame_resume.pack(fill=tk.BOTH, expand=True)

label_resume = tk.Label(frame_resume, text="Select your resume (.docx):")
label_resume.pack()
button_select = tk.Button(frame_resume, text="Browse", command=select_resume)
button_select.pack(pady=5)
resume_preview = tk.Text(frame_resume, height=10, width=80)
resume_preview.pack(pady=5)

frame_params = tk.Frame(root, padx=10, pady=10)
frame_params.pack(fill=tk.BOTH, expand=True)

remote_var = tk.BooleanVar()
checkbox_remote = tk.Checkbutton(frame_params, text="Remote Only", variable=remote_var)
checkbox_remote.pack(anchor='w')

label_pay = tk.Label(frame_params, text="Desired Pay (numeric):")
label_pay.pack(anchor='w')
desired_pay_entry = tk.Entry(frame_params)
desired_pay_entry.pack(fill=tk.X, pady=2)

label_location = tk.Label(frame_params, text="Desired Location:")
label_location.pack(anchor='w')
location_entry = tk.Entry(frame_params)
location_entry.pack(fill=tk.X, pady=2)

label_keywords = tk.Label(frame_params, text="Keywords:")
label_keywords.pack(anchor='w')
keywords_entry = tk.Entry(frame_params)
keywords_entry.pack(fill=tk.X, pady=2)

button_submit = tk.Button(root, text="Submit Parameters", command=submit_parameters)
button_submit.pack(pady=10)

button_scrape = tk.Button(root, text="Scrape Google Jobs", command=scrape_google_jobs)
button_scrape.pack(pady=10)

root.mainloop()
