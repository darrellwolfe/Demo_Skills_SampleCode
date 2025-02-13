import os
import sys
import json
import random
import requests
import pandas as pd
import tkinter as tk
from tkinter import messagebox, StringVar

def resource_path(relative_path):
    """Get absolute path to resource, works for dev and for PyInstaller"""
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")

    return os.path.join(base_path, relative_path)

class InitialsDialog(tk.Toplevel):
    def __init__(self, parent):
        super().__init__(parent)
        self.title("High Score")
        self.initials = ""
        self.create_widgets()
        self.entry.focus_set()
        self.grab_set()

    def create_widgets(self):
        tk.Label(self, text="You got a high score! Enter your initials:").pack(pady=10)
        self.entry = tk.Entry(self, width=5, font=("Helvetica", 14), justify='center')
        self.entry.pack(pady=10)
        self.entry.bind('<KeyRelease>', self.validate)
        self.entry.bind('<Return>', self.on_ok)
        self.ok_button = tk.Button(self, text="OK", command=self.on_ok)
        self.ok_button.pack(pady=10)

    def validate(self, event):
        content = self.entry.get().upper()
        self.entry.delete(0, tk.END)
        self.entry.insert(0, content[:3])

    def on_ok(self, event=None):
        self.initials = self.entry.get()
        if len(self.initials) == 3 and self.initials.isalpha():
            self.destroy()
        else:
            messagebox.showwarning("Invalid Input", "Please enter exactly 3 capital letters.")

class HangmanGame:
    def __init__(self, master):
        self.master = master
        self.master.title("Hangman")
        self.master.geometry("520x520")
        self.master.resizable(False, False)

        self.word = ""
        self.word_letters = set()
        self.guessed_letters = set()
        self.lives = 6
        self.score = 0
        self.high_scores = self.load_high_scores()
        self.acronyms = self.load_acronyms()
        self.game_mode = self.select_game_mode()

        self.create_widgets()
        self.new_game()
        self.master.after(100, self.set_focus)  # Set focus after a short delay
    
    def set_focus(self):
        self.guess_entry.focus_set()
        self.guess_entry.focus_force()  # Force focus

    def load_acronyms(self):
        try:
            # Use resource_path to locate the Excel file
            excel_path = resource_path('acronyms.xlsx')
            df = pd.read_excel(excel_path, header=2)
            return dict(zip(df.iloc[:, 0], df.iloc[:, 1]))
        except FileNotFoundError:
            messagebox.showwarning("File Not Found", "acronyms.xlsx not found. Switching to normal mode.")
            self.game_mode = 'no'
            return {}

    def select_game_mode(self):
        return messagebox.askquestion("Game Mode", "Do you want to play in Assessor Mode?")

    def get_word(self):
        if self.game_mode == 'yes':  # Assessor Mode
            acronym, definition = random.choice(list(self.acronyms.items()))
            self.current_definition = definition
            return acronym
        else:  # Normal Mode
            api_key = "rjzjr06vxd5gc23hsijl1y00tbnu2rzvwq61fht40iz13o7yf"
            url = f"https://api.wordnik.com/v4/words.json/randomWord?hasDictionaryDef=true&minLength=4&maxLength=10&api_key={api_key}"

            while True:
                try:
                    response = requests.get(url, timeout=5)
                    if response.status_code == 200:
                        word = response.json()['word']
                        # Only accept words that:
                        # 1. Are purely alphabetical
                        # 2. Don't start with a capital letter (to exclude proper nouns)
                        if word.isalpha() and word[0].islower():
                            return word.lower()
                        continue

                except requests.RequestException as e:
                    words = ["python", "programming", "computer", "science", "algorithm", "database", "network"]
                    return random.choice(words)

    def new_game(self):
        self.word = self.get_word()
        self.word_letters = set(letter for letter in self.word if letter.isalpha())
        self.guessed_letters = set()
        self.lives = 6
        self.score = 0
        self.update_display()
        self.guess_var.set("")
        self.guess_entry.focus_set()

    def create_widgets(self):
        self.hangman_display = tk.Label(self.master, font=("Courier", 14), justify=tk.LEFT)
        self.hangman_display.pack(pady=10)

        self.word_display = tk.Label(self.master, font=("Courier", 20))
        self.word_display.pack(pady=10)

        self.lives_label = tk.Label(self.master, text="Lives: 6", font=("Helvetica", 12))
        self.lives_label.pack()

        self.score_label = tk.Label(self.master, text="Score: 0", font=("Helvetica", 12))
        self.score_label.pack()

        self.guessed_letters_label = tk.Label(self.master, text="Guessed Letters: ", font=("Helvetica", 12))
        self.guessed_letters_label.pack(pady=5)

        self.guess_var = StringVar()
        self.guess_entry = tk.Entry(self.master, font=("Helvetica", 14), width=2, justify='center', textvariable=self.guess_var)
        self.guess_entry.pack(pady=10)
        self.guess_entry.bind('<Return>', self.make_guess)
        self.guess_var.trace_add("write", self.validate_guess)

        self.new_game_button = tk.Button(self.master, text="New Game", command=self.new_game)
        self.new_game_button.pack(pady=5)

        self.high_scores_button = tk.Button(self.master, text="High Scores", command=self.show_high_scores)
        self.high_scores_button.pack(pady=5)

    def validate_guess(self, *args):
        content = self.guess_var.get()
        if content:
            last_char = content[-1].lower()
            if last_char.isalpha() or last_char == '-':
                self.guess_var.set(last_char)
            else:
                self.guess_var.set('')

    def make_guess(self, event=None):
        guess = self.guess_var.get().lower()
        self.guess_var.set("")

        if guess in self.guessed_letters:
            messagebox.showinfo("Repeated Guess", "You've already guessed that letter.")
            return
        if not guess or not guess.isalpha():
            messagebox.showwarning("Invalid Input", "Please enter a single letter.")
            return

        self.guessed_letters.add(guess)

        if guess in self.word_letters:
            self.word_letters.remove(guess)
            self.score += 10
        else:
            self.lives -= 1
            self.score = max(0, self.score - 5)

        self.update_display()

        if self.lives <= 0:
            message = f"Game Over! The word was '{self.word}'."
            if self.game_mode == 'yes':
                message += f"\n\nDefinition: {self.current_definition}"
            messagebox.showinfo("Game Over", message)
            self.new_game()
            return

        if len(self.word_letters) == 0:
            self.score += 50
            message = f"Congratulations! You won! The word was '{self.word}'."
            if self.game_mode == 'yes':
                message += f"\n\nDefinition: {self.current_definition}"
            messagebox.showinfo("Congratulations", message)
            self.check_high_score()
            self.new_game()

    def update_display(self):
        self.hangman_display.config(text=self.display_hangman())
        self.word_display.config(text=self.display_word())
        self.lives_label.config(text=f"Lives: {self.lives}")
        self.score_label.config(text=f"Score: {self.score}")
        self.guessed_letters_label.config(text=f"Guessed Letters: {' '.join(sorted(self.guessed_letters))}")

    def display_hangman(self):
        stages = [
            """
  --------
  |      |
  |      O
  |     \\|/
  |      |
  |     / \\
  -
""",
            """
  --------
  |      |
  |      O
  |     \\|/
  |      |
  |     /
  -
""",
            """
  --------
  |      |
  |      O
  |     \\|/
  |      |
  |
  -
""",
            """
  --------
  |      |
  |      O
  |     \\|
  |      |
  |
  -
""",
            """
  --------
  |      |
  |      O
  |      |
  |      |
  |
  -
""",
            """
  --------
  |      |
  |      O
  |
  |
  |
  -
""",
            """
  --------
  |      |
  |
  |
  |
  |
  -
"""
        ]
        return stages[self.lives]

    def display_word(self):
        return ' '.join(letter if letter in self.guessed_letters or letter == '-' else '_' for letter in self.word)

    def load_high_scores(self):
        if os.path.exists('high_scores.json'):
            with open('high_scores.json', 'r') as f:
                return json.load(f)
        return []

    def save_high_scores(self):
        with open('high_scores.json', 'w') as f:
            json.dump(self.high_scores, f)

    def check_high_score(self):
        if len(self.high_scores) < 10 or self.score > self.high_scores[-1]['score']:
            dialog = InitialsDialog(self.master)
            self.master.wait_window(dialog)
            initials = dialog.initials
            
            if initials and len(initials) == 3:
                self.high_scores.append({'initials': initials, 'score': self.score})
                self.high_scores.sort(key=lambda x: x['score'], reverse=True)
                self.high_scores = self.high_scores[:10]  # Keep only top 10
                self.save_high_scores()

    def show_high_scores(self):
        high_scores_text = "High Scores:\n\n"
        for i, score in enumerate(self.high_scores, 1):
            high_scores_text += f"{i}. {score['initials']}: {score['score']}\n"
        messagebox.showinfo("High Scores", high_scores_text)

def main():
    root = tk.Tk()
    HangmanGame(root)
    root.mainloop()

if __name__ == "__main__":
    main()