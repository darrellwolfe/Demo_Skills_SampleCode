import tkinter
from tkinter import ttk
import random
from math import cos, sin

# Create the root window
root = tkinter.Tk()
root.title("Fireworks Display")

# Create a frame
frm = ttk.Frame(root, padding=10)
frm.grid()

# Create a canvas for drawing fireworks
canvas = tkinter.Canvas(frm, width=500, height=500, bg='black')
canvas.grid(column=0, row=0, columnspan=3)

# Function to animate fireworks
def show_fireworks():
    # Clear the canvas
    canvas.delete("all")
    
    # Fireworks parameters
    num_explosions = 5
    explosion_points = 20
    explosion_colors = ["red", "yellow", "orange", "white", "blue", "green", "purple"]
    
    def create_explosion(x, y):
        for _ in range(explosion_points):
            angle = random.uniform(0, 2 * 3.14159)  # Random angle in radians
            distance = random.uniform(50, 150)  # Random distance
            x_end = x + distance * random.uniform(0.7, 1) * cos(angle)
            y_end = y + distance * random.uniform(0.7, 1) * sin(angle)
            color = random.choice(explosion_colors)
            canvas.create_line(x, y, x_end, y_end, fill=color)
    
    def animate_explosions():
        for _ in range(num_explosions):
            x = random.randint(50, 450)
            y = random.randint(50, 450)
            create_explosion(x, y)
        root.after(500, canvas.delete, "all")  # Clear the canvas after a short delay

    animate_explosions()

# Use the frame to add a button
button = ttk.Button(frm, text="Fireworks!", command=show_fireworks)
button.grid(column=1, row=1)

# Add a quit button to the frame
quit_button = ttk.Button(frm, text="Quit", command=root.destroy)
quit_button.grid(column=2, row=1)

# Start the main event loop
root.mainloop()
