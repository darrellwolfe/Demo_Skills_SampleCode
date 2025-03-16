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
# Logging setup
# ----------------------------------------------------
log_directory = os.path.expanduser(r'~\Documents')
log_filename = os.path.join(log_directory, 'resume_search_logic.log')
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
    
    messagebox.showinfo("Success", "Parameters submitted. You can now scrape Indeed jobs.")

# ----------------------------------------------------
# Indeed Scraping Functions
# ----------------------------------------------------
def get_indeed_search_url():
    """
    Construct an Indeed search URL from user inputs.
    Indeed doesn't have a direct 'salary' parameter,
    so we'll just append the numeric salary to the keywords
    as if the user typed it into the search box.
    """
    keywords = keywords_entry.get().strip()
    location = location_entry.get().strip()
    desired_pay = desired_pay_entry.get().strip()
    remote = remote_var.get()
    
    # If user wants remote only, override location
    if remote:
        location = "Remote"
    
    # If user entered a desired pay, append "$75000" to the keywords
    if desired_pay:
        keywords += f" ${desired_pay}"
    
    # Build the query
    # Example: https://www.indeed.com/jobs?q=Data+Analyst+%2475000&l=Remote
    query_params = {
        'q': keywords,
        'l': location,
    }
    query_string = urllib.parse.urlencode(query_params)
    return f"https://www.indeed.com/jobs?{query_string}"

def scrape_indeed_jobs():
    """
    No login required. Simply go to Indeed with the constructed URL,
    wait for job cards, scrape them, and display how many were found.
    """
    job_search_url = get_indeed_search_url()
    logging.info(f"Starting scrape_indeed_jobs. URL: {job_search_url}")
    
    driver = configure_webdriver()
    job_titles = []

    try:
        driver.get(job_search_url)

        # Check if a CAPTCHA is present:
        time.sleep(5)  # Wait a moment to see if CAPTCHA loads
        if "Additional Verification Required" in driver.page_source:
            messagebox.showinfo("CAPTCHA", "Please solve the CAPTCHA in the browser, then click OK.")
            # Wait a bit longer for user to solve
            time.sleep(15)

        # Then proceed with your normal waiting for job results:
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "ul.jobsearch-ResultsList"))
        )
        
        # Each job listing is typically under 'a.tapItem'
        job_cards = driver.find_elements(By.CSS_SELECTOR, "a.tapItem")
        for card in job_cards:
            try:
                title_element = card.find_element(By.CSS_SELECTOR, 'span[title]')
                job_titles.append(title_element.text)
            except Exception as e:
                logging.error(f"Error scraping a job card: {e}")
        
        logging.info(f"Scraping completed. Found {len(job_titles)} job titles.")
        messagebox.showinfo("Scraping Completed", f"Found {len(job_titles)} job titles.")
    except TimeoutException:
        logging.error("Timeout waiting for Indeed job results.")
        messagebox.showerror("Timeout", "Failed to load Indeed jobs page within the time limit.")
    except Exception as e:
        logging.error(f"An error occurred: {str(e)}", exc_info=True)
        messagebox.showerror("Error", f"An error occurred: {str(e)}")
    finally:
        driver.quit()

    return job_titles

def configure_webdriver():
    options = EdgeOptions()
    # If you want to run in the background, uncomment this:
    # options.add_argument("--headless")
    #options.add_argument("--no-sandbox")
    #options.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Edge(options=options)
    return driver

# ----------------------------------------------------
# GUI Setup
# ----------------------------------------------------
root = tk.Tk()
root.title("Resume and Job Parameters (Indeed)")

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

# Button to scrape Indeed
button_scrape = tk.Button(root, text="Scrape Indeed Jobs", command=scrape_indeed_jobs)
button_scrape.pack(pady=10)

root.mainloop()
