import tkinter
from tkinter import ttk

# Create the root window
root = tkinter.Tk()

# Create a frame
frm = ttk.Frame(root, padding=10)
frm.grid()

# Use the frame to add a button
button = ttk.Button(frm, text="Click Me")
button.grid(column=1, row=0)

# Add a quit button to the frame
quit_button = ttk.Button(frm, text="Quit", command=root.destroy)
quit_button.grid(column=2, row=0)

# Start the main event loop
root.mainloop()

