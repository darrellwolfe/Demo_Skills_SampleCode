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
import geocoder  # new import for device location

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
        "keywords": keywords_entry.get(),
        "radius": radius_entry.get(),
    }
    # If not using device location, include city and state in params
    if not device_location_var.get():
        params["city"] = city_entry.get()
        params["state"] = state_entry.get()
    else:
        params["city"] = ""
        params["state"] = ""

    try:
        if params["desired_pay"]:
            float(params["desired_pay"])  # Check it's numeric
    except ValueError:
        messagebox.showerror("Input Error", "Desired pay must be a number.")
        logging.error("Invalid input for desired pay.", exc_info=True)
        return

    logging.info("Selected Resume File: " + selected_resume.get())
    logging.info("Job Parameters:")
    for key, value in params.items():
        logging.info(f"{key}: {value}")
    
    messagebox.showinfo("Success", "Parameters submitted. You can now scrape Google jobs.")

# ----------------------------------------------------
# Device Location Function
# ----------------------------------------------------
def get_device_location():
    """Retrieve device location via IP using geocoder."""
    try:
        g = geocoder.ip('me')
        city = g.city
        state = g.state
        if city and state:
            location = f"{city}, {state} USA"
            logging.info(f"Device location detected: {location}")
            return location
        else:
            logging.info("Device location could not be determined; falling back to empty string.")
            return ""
    except Exception as e:
        logging.error("Error obtaining device location: " + str(e))
        return ""

# ----------------------------------------------------
# Google URL Logic
# ----------------------------------------------------
def get_google_jobs_search_url():
    """Construct a Google job search URL from user inputs using the working search style."""
    keywords = keywords_entry.get().strip()
    desired_pay = desired_pay_entry.get().strip()
    remote = remote_var.get()
    use_device = device_location_var.get()
    
    # Define a fixed time filter that worked well
    time_filter = "in the last 3 days"
    
    # Determine the remote string
    remote_str = "remote" if remote else ""
    
    # Determine the location string: if using device location, use that; otherwise use manual inputs
    if use_device:
        location_str = get_device_location()
    else:
        city = city_entry.get().strip()
        state = state_entry.get().strip()
        if city and state:
            location_str = f"near {city}, {state}"
        else:
            location_str = ""
    
    # Build the search query. Include desired pay if provided.
    if desired_pay:
        search_query = f"{keywords} {desired_pay}  {remote_str} {time_filter} {location_str}"
    else:
        search_query = f"{keywords}  {remote_str} {time_filter} {location_str}"
    
    # Clean up extra spaces
    search_query = " ".join(search_query.split())
    
    query_params = {
        'q': search_query,
        'ibp': 'htl;jobs'
    }
    query_string = urllib.parse.urlencode(query_params)
    logging.info(f"Constructed search query: {search_query}")
    return f"https://www.google.com/search?{query_string}"

# ----------------------------------------------------
# Display and Scrape Functions
# ----------------------------------------------------
def display_job_results(job_results):
    """Display job details in a new window."""
    if not job_results:
        messagebox.showinfo("No Results", "No job details found.")
        return

    results_window = tk.Toplevel(root)
    results_window.title("Job Search Results")
    text_widget = tk.Text(results_window, wrap="word", width=80, height=20)
    text_widget.pack(fill=tk.BOTH, expand=True)

    for job in job_results:
        text_widget.insert(tk.END, f"Job Title: {job['title']}\n")
        text_widget.insert(tk.END, f"Company: {job['company']}\n")
        text_widget.insert(tk.END, f"Salary: {job['salary']}\n")
        text_widget.insert(tk.END, f"Work Style: {job['work_style']}\n")
        text_widget.insert(tk.END, "\n" + "-" * 40 + "\n\n")

def scrape_google_jobs():
    """Scrape jobs from Google using the constructed URL with updated selectors."""
    job_search_url = get_google_jobs_search_url()
    logging.info(f"Starting job scrape. URL: {job_search_url}")

    driver = configure_webdriver()
    job_results = []

    try:
        driver.get(job_search_url)
        WebDriverWait(driver, 30).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "a.MQUd2b"))
        )
        job_cards = driver.find_elements(By.CSS_SELECTOR, "a.MQUd2b")
        for card in job_cards:
            try:
                title = card.find_element(By.CSS_SELECTOR, "div.tNxQIb.PUpOsf").text
            except Exception as e:
                logging.warning("Job title not found in card. Skipping this field.")
                title = "N/A"
            
            try:
                company = card.find_element(By.CSS_SELECTOR, "div.wHYlTd.MKCbgd.a3jPc").text
            except Exception as e:
                logging.warning("Company name not found in card.")
                company = "N/A"
            
            try:
                salary_elem = card.find_element(By.XPATH, ".//span[contains(@aria-label, 'Salary')]")
                salary = salary_elem.text
            except Exception as e:
                logging.info("Salary not found for this job card.")
                salary = "N/A"
            
            try:
                work_style_elem = card.find_element(By.XPATH, ".//span[normalize-space(text())='Work from home']")
                work_style = work_style_elem.text
            except Exception as e:
                logging.info("Work style (remote) not found for this job card.")
                work_style = "N/A"
            
            job_results.append({
                "title": title,
                "company": company,
                "salary": salary,
                "work_style": work_style,
            })

        logging.info(f"Scraping completed. Found {len(job_results)} job cards.")
        display_job_results(job_results)
        messagebox.showinfo("Scraping Completed", f"Found {len(job_results)} job cards.")
    except TimeoutException:
        driver.save_screenshot(screenshot_filename)
        logging.error("Timeout waiting for job results, screenshot saved at " + screenshot_filename)
        messagebox.showerror("Timeout", "Failed to load job results within the time limit. Screenshot saved at " + screenshot_filename)
    finally:
        driver.quit()

    return job_results

def configure_webdriver() -> webdriver.Edge:
    """Configure and return the Selenium WebDriver for Edge."""
    options = EdgeOptions()
    options.use_chromium = True
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

device_location_var = tk.BooleanVar()
checkbox_device_location = tk.Checkbutton(frame_params, text="Use Device Location", variable=device_location_var)
checkbox_device_location.pack(anchor='w')

label_pay = tk.Label(frame_params, text="Desired Pay (numeric):")
label_pay.pack(anchor='w')
desired_pay_entry = tk.Entry(frame_params)
desired_pay_entry.pack(fill=tk.X, pady=2)

label_keywords = tk.Label(frame_params, text="Keywords:")
label_keywords.pack(anchor='w')
keywords_entry = tk.Entry(frame_params)
keywords_entry.pack(fill=tk.X, pady=2)

# Only show city and state fields if not using device location
label_city = tk.Label(frame_params, text="City:")
label_city.pack(anchor='w')
city_entry = tk.Entry(frame_params)
city_entry.pack(fill=tk.X, pady=2)

label_state = tk.Label(frame_params, text="State:")
label_state.pack(anchor='w')
state_entry = tk.Entry(frame_params)
state_entry.pack(fill=tk.X, pady=2)

label_radius = tk.Label(frame_params, text="Radius (in miles):")
label_radius.pack(anchor='w')
radius_entry = tk.Entry(frame_params)
radius_entry.pack(fill=tk.X, pady=2)

button_submit = tk.Button(root, text="Submit Parameters", command=submit_parameters)
button_submit.pack(pady=10)

button_scrape = tk.Button(root, text="Scrape Google Jobs", command=scrape_google_jobs)
button_scrape.pack(pady=10)

root.mainloop()
