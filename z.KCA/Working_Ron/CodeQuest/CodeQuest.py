import io
import sys
import time
import ast
from contextlib import redirect_stdout
import json
import tkinter as tk
from tkinter import scrolledtext, messagebox
from colorama import init, Fore, Style
import sqlite3
import random
from enum import Enum, auto

init(autoreset=True)

conn = sqlite3.connect('game_data.db')
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS saves
             (id INTEGER PRIMARY KEY, player_data TEXT)''')
conn.commit()

class GameEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Character):
            character_dict = obj.__dict__.copy()
            character_dict['completed_challenges'] = list(character_dict['completed_challenges'])
            return character_dict
        elif isinstance(obj, Inventory):
            return obj.__dict__
        elif isinstance(obj, Spell):
            return {
                "class_name": obj.__class__.__name__,
                "name": obj.name,
                "cost": obj.cost,
                "effect": obj.effect,
                "element": obj.element
            }
        elif isinstance(obj, set):
            return list(obj)
        return super().default(obj)

class Character:
    def __init__(self, name, appearance, affinity):
        self.name = name
        self.appearance = appearance
        self.affinity = affinity
        self.level = 1
        self.experience = 0
        self.hp = 100
        self.max_hp = 100
        self.mp = 50
        self.max_mp = 50
        self.attack = random.randint(10, 20)
        self.defense = random.randint(5, 15)
        self.speed = random.randint(5, 15)
        self.gold = 0
        self.accuracy = 80
        self.evasion = 20
        self.melee_bonus = 5
        self.ranged_bonus = 0
        self.magic_bonus = 0
        self.dodge_threshold = 15
        self.items = {}
        self.capacity = 10
        self.spells = []
        self.inventory = Inventory()
        self.learn_affinity_spell()
        self.completed_challenges = set()
        self.skills = {"Programming": 1, "Problem Solving": 1, "Debugging": 1}

    def learn_affinity_spell(self):
        affinity_spells = {
            "Fire": FireballSpell(),
            "Water": WaterJetSpell(),
            "Earth": RockThrowSpell(),
            "Air": WindSlashSpell()
        }
        self.spells.append(affinity_spells[self.affinity])
        print(f"{Fore.GREEN}{self.name} learned {self.spells[0].name}!{Style.RESET_ALL}")

    def cast_spell(self, spell):
        if self.mp >= spell.cost:
            self.mp -= spell.cost
            print(f"{Fore.CYAN}{self.name} casts {spell.name}!{Style.RESET_ALL}")
            return spell.effect
        else:
            print(f"{Fore.RED}Not enough MP!{Style.RESET_ALL}")
            return 0

    def take_damage(self, damage):
        mitigated_damage = max(0, damage - self.defense)
        self.hp = max(0, self.hp - mitigated_damage)
        if self.hp <= 0:
            print(f"{Fore.RED}{self.name} has been defeated!{Style.RESET_ALL}")
            return False
        return True

    def gain_experience(self, exp):
        self.experience += exp
        print(f"{Fore.GREEN}{self.name} gained {exp} experience!{Style.RESET_ALL}")
        if self.experience >= self.level * 20:
            self.level_up()

    def level_up(self):
        self.level += 1
        self.max_hp += 10
        self.max_mp += 5
        self.hp = self.max_hp
        self.mp = self.max_mp
        self.attack += 3
        self.defense += 1
        self.experience = 0
        print(f"{Fore.YELLOW}{self.name} leveled up to level {self.level}!{Style.RESET_ALL}")
        self.increase_skill()

    def increase_skill(self):
        skills = list(self.skills.keys())
        skill = random.choice(skills)
        self.skills[skill] += 1
        print(f"{Fore.YELLOW}{self.name}'s {skill} skill increased to {self.skills[skill]}!{Style.RESET_ALL}")

    def __str__(self):
        return f"{self.name}, the {self.affinity} mage (Level: {self.level}, HP: {self.hp}/{self.max_hp}, MP: {self.mp}/{self.max_mp})"

class Inventory:
    def __init__(self):
        self.items = {}
        self.capacity = 10

    def add_item(self, item, quantity=1):
        if sum(self.items.values()) + quantity > self.capacity:
            print(f"{Fore.RED}Inventory full! Cannot add {item}.{Style.RESET_ALL}")
            return False
        if item in self.items:
            self.items[item] += quantity
        else:
            self.items[item] = quantity
        return True

    def remove_item(self, item, quantity=1):
        if item in self.items:
            if self.items[item] >= quantity:
                self.items[item] -= quantity
                if self.items[item] == 0:
                    del self.items[item]
                return True
        return False

    def __str__(self):
        if not self.items:
            return "Empty"
        return ", ".join([f"{item}: {quantity}" for item, quantity in self.items.items()])
    
def use_item_from_inventory(player):
    if not player.inventory.items:
        print(f"{Fore.YELLOW}Your inventory is empty!{Style.RESET_ALL}")
        return
    
    print(f"{Fore.CYAN}Available items:{Style.RESET_ALL}")
    items = list(player.inventory.items.keys())
    for i, item in enumerate(items, 1):
        quantity = player.inventory.items[item]
        print(f"{i}. {item} (x{quantity})")
    
    try:
        item_choice = int(input("Choose an item to use (0 to cancel): ")) - 1
        if item_choice == -1:
            return
        if 0 <= item_choice < len(items):
            item = items[item_choice]
            if player.inventory.remove_item(item):
                use_item(player, item)
            else:
                print(f"{Fore.RED}Failed to remove item from inventory!{Style.RESET_ALL}")
        else:
            print(f"{Fore.RED}Invalid choice!{Style.RESET_ALL}")
    except ValueError:
        print(f"{Fore.RED}Invalid input. Please enter a number.{Style.RESET_ALL}")

def use_item(player, item):
    effect = ""
    if item == "Health Potion":
        heal_amount = min(30, player.max_hp - player.hp)
        player.hp += heal_amount
        effect = f"Recovered {heal_amount} HP"
    elif item == "Mana Potion":
        mana_amount = min(20, player.max_mp - player.mp)
        player.mp += mana_amount
        effect = f"Recovered {mana_amount} MP"
    elif item == "Strength Elixir":
        player.attack += 5
        effect = f"Increased attack power by 5"
    else:
        effect = "No effect"
    return effect

def remove_item(self, item, quantity=1):
    if item in self.items:
        if self.items[item] >= quantity:
            self.items[item] -= quantity
            if self.items[item] == 0:
                del self.items[item]
            return True
    return False

def __str__(self):
    if not self.items:
        return "Empty"
    return ", ".join([f"{item}: {quantity}" for item, quantity in self.items.items()])

class StatusEffect(Enum):
    CONFUSED = auto()
    DEBUGGED = auto()

class Spell:
    def __init__(self, name, cost, effect, element):
        self.name = name
        self.cost = cost
        self.effect = effect
        self.element = element
        self.class_name = self.__class__.__name__

class FireballSpell(Spell):
    def __init__(self):
        super().__init__("Fireball", 10, 20, "Fire")

class WaterJetSpell(Spell):
    def __init__(self):
        super().__init__("Water Jet", 10, 20, "Water")

class RockThrowSpell(Spell):
    def __init__(self):
        super().__init__("Rock Throw", 10, 20, "Earth")

class WindSlashSpell(Spell):
    def __init__(self):
        super().__init__("Wind Slash", 10, 20, "Air")

class HealSpell(Spell):
    def __init__(self):
        super().__init__("Heal", 15, -30, "Neutral")

class ShieldSpell(Spell):
    def __init__(self):
        super().__init__("Shield", 5, 10, "Neutral")

class ManualisEnemy:
    def __init__(self, name, hp, attack, defense, gold_reward, exp_reward, special_ability, weakness, strength):
        self.name = name
        self.hp = hp
        self.max_hp = hp
        self.attack = attack
        self.defense = defense
        self.speed = random.randint(5, 15)
        self.gold_reward = gold_reward
        self.exp_reward = exp_reward
        self.special_ability = special_ability
        self.weakness = weakness
        self.strength = strength
        self.ability_cooldown = 0
        self.status_effects = {}

    def take_damage(self, damage, element=None):
        if element:
            if element == self.weakness:
                damage *= 1.5
                print(f"{Fore.GREEN}It's super effective! Damage increased to {damage}!{Style.RESET_ALL}")
            elif element == self.strength:
                damage *= 0.5
                print(f"{Fore.RED}It's not very effective... Damage reduced to {damage}.{Style.RESET_ALL}")
        self.hp -= max(1, damage - self.defense // 2)
        return self.hp <= 0

    def use_special_ability(self, player):
        if self.ability_cooldown > 0:
            print(f"{Fore.YELLOW}{self.name}'s {self.special_ability} is on cooldown for {self.ability_cooldown} more turns.{Style.RESET_ALL}")
            return

        print(f"{Fore.RED}{self.name} uses {self.special_ability}!{Style.RESET_ALL}")
        if self.special_ability == "Data Corruption":
            damage = player.level * 5
            player.take_damage(damage)
            print(f"{Fore.RED}{self.name} corrupts data, dealing {damage} damage!{Style.RESET_ALL}")
            self.ability_cooldown = 3
        elif self.special_ability == "Infinite Loop":
            mp_loss = player.level * 3
            player.mp = max(0, player.mp - mp_loss)
            print(f"{Fore.RED}{self.name} creates an infinite loop, draining {mp_loss} MP!{Style.RESET_ALL}")
            self.ability_cooldown = 4
        elif self.special_ability == "Syntax Terror":
            damage = player.level * 2
            player.take_damage(damage)
            print(f"{Fore.RED}{self.name} uses Syntax Terror, dealing {damage} damage!{Style.RESET_ALL}")
            if random.random() < 0.5:
                player.status_effects[StatusEffect.CONFUSED] = 2
                print(f"{Fore.YELLOW}{player.name} is confused for 2 turns!{Style.RESET_ALL}")
            self.ability_cooldown = 2
        elif self.special_ability == "Logic Bomb":
            damage = int(player.hp * 0.2)  # 20% of current HP
            player.take_damage(damage)
            print(f"{Fore.RED}{self.name} detonates a Logic Bomb, dealing {damage} damage!{Style.RESET_ALL}")
            self.ability_cooldown = 5

    def update_status(self):
        if self.ability_cooldown > 0:
            self.ability_cooldown -= 1

        for effect, duration in list(self.status_effects.items()):
            if duration > 0:
                self.status_effects[effect] -= 1
                if effect == StatusEffect.DEBUGGED:
                    self.defense = max(0, self.defense - 2)
            else:
                del self.status_effects[effect]

    def act(self, player):
        self.update_status()
        if StatusEffect.CONFUSED in self.status_effects:
            if random.random() < 0.5:
                print(f"{Fore.YELLOW}{self.name} is confused and hits itself!{Style.RESET_ALL}")
                self.take_damage(self.attack // 2)
                return

        if random.random() < 0.3 and self.ability_cooldown == 0:
            self.use_special_ability(player)
        else:
            damage = max(1, self.attack - player.defense // 2)
            player.take_damage(damage)
            print(f"{Fore.RED}{self.name} attacks for {damage} damage!{Style.RESET_ALL}")

def create_manualis_enemy(difficulty):
    enemy_types = {
        "easy": [
            ("Syntax Error Sprite", 30, 8, 2, 15, 20, "Syntax Terror"),
            ("Code Goblin", 25, 7, 1, 10, 15, "Logic Bomb")
        ],
        "medium": [
            ("Logic Bug", 40, 10, 3, 20, 25, "Data Corruption"),
            ("Repetitive Task Golem", 50, 10, 5, 20, 20, "Infinite Loop")
        ],
        "hard": [
            ("Exception Demon", 60, 15, 6, 30, 35, "Syntax Terror"),
            ("Infinite Loop Wraith", 70, 18, 8, 35, 40, "Infinite Loop")
        ]
    }

    enemy_info = random.choice(enemy_types[difficulty])
    name, hp, attack, defense, gold, exp, ability = enemy_info
    affinities = ["Fire", "Water", "Earth", "Air"]
    weakness = random.choice(affinities)
    strength = random.choice([a for a in affinities if a != weakness])

    return ManualisEnemy(name, hp, attack, defense, gold, exp, ability, weakness, strength)

def create_character():
    root = tk.Tk()
    root.title("Character Creation")
    root.geometry("400x300")  # Set window size
    root.attributes('-topmost', True)  # Keep window on top
    root.lift()  # Bring window to front

    name_var = tk.StringVar()
    appearance_var = tk.StringVar()
    affinity_var = tk.StringVar()

    tk.Label(root, text="Enter your character's name:").pack(pady=10)
    tk.Entry(root, textvariable=name_var, width=40).pack()

    tk.Label(root, text="Describe your character's appearance:").pack(pady=10)
    tk.Entry(root, textvariable=appearance_var, width=40).pack()

    tk.Label(root, text="Choose your magical affinity:").pack(pady=10)
    affinities = ["Fire", "Water", "Earth", "Air"]
    affinity_menu = tk.OptionMenu(root, affinity_var, *affinities)
    affinity_menu.config(width=35)
    affinity_menu.pack()

    character_created = False
    
    def force_focus():
        root.lift()
        root.attributes('-topmost', True)
        root.attributes('-topmost', False)
        root.focus_force()

    root.after(100, force_focus)

    def submit():
        nonlocal character_created
        if name_var.get() and appearance_var.get() and affinity_var.get():
            character_created = True
            root.quit()
        else:
            messagebox.showerror("Error", "Please fill in all fields.")

    def on_closing():
        if messagebox.askokcancel("Quit", "Are you sure you want to quit? This will exit the game."):
            root.destroy()
            sys.exit()

    tk.Button(root, text="Create Character", command=submit).pack(pady=20)

    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()

    if not character_created:
        print("Character creation cancelled. Exiting game.")
        sys.exit()

    name = name_var.get()
    appearance = appearance_var.get()
    affinity = affinity_var.get()

    root.destroy()

    return Character(name, appearance, affinity)

def delete_saved_game():
    c.execute("SELECT id, player_data FROM saves")
    saves = c.fetchall()
    
    print("Available saves:")
    for save in saves:
        save_id, save_data = save
        player_data = json.loads(save_data)
        print(f"{save_id}: {player_data['name']} (Level {player_data['level']})")

    save_id = input("Enter the ID of the save to delete, or 'c' to cancel: ")
    if save_id.lower() == 'c':
        return

    try:
        save_id = int(save_id)
        c.execute("DELETE FROM saves WHERE id = ?", (save_id,))
        conn.commit()
        print("Save deleted successfully.")
    except ValueError:
        print("Invalid save ID.")

def save_game(player):
    c.execute("SELECT COUNT(*) FROM saves")
    save_count = c.fetchone()[0]
    MAX_SAVES = 5
    
    if save_count >= MAX_SAVES:
        print(f"Maximum number of saves ({MAX_SAVES}) reached.")
        delete_save = input("Do you want to delete a save? (y/n): ").lower()
        if delete_save == 'y':
            delete_saved_game()
        else:
            return

    save_data = json.dumps(player.__dict__, cls=GameEncoder)
    c.execute("INSERT INTO saves (player_data) VALUES (?)", (save_data,))
    conn.commit()
    print("Game saved!")

def reconstruct_spell(spell_data):
    spell_classes = {
        "FireballSpell": FireballSpell,
        "WaterJetSpell": WaterJetSpell,
        "RockThrowSpell": RockThrowSpell,
        "WindSlashSpell": WindSlashSpell,
        "HealSpell": HealSpell,
        "ShieldSpell": ShieldSpell
    }
    spell_class = spell_classes[spell_data["class_name"]]
    spell = spell_class()
    spell.__dict__.update(spell_data)
    return spell

def load_game():
    c.execute("SELECT id, player_data FROM saves")
    saves = c.fetchall()
    
    if not saves:
        print(f"{Fore.RED}No saved games found.{Style.RESET_ALL}")
        return None

    print("Available saves:")
    for save in saves:
        save_id, save_data = save
        player_data = json.loads(save_data)
        print(f"{save_id}: {player_data['name']} (Level {player_data['level']})")

    save_id = input("Enter the ID of the save to load, or 'c' to cancel: ")
    if save_id.lower() == 'c':
        return None

    try:
        save_id = int(save_id)
        c.execute("SELECT player_data FROM saves WHERE id = ?", (save_id,))
        save_data = c.fetchone()
        if save_data:
            player_data = json.loads(save_data[0])
            player = Character(player_data['name'], player_data['appearance'], player_data['affinity'])
            player.__dict__.update(player_data)
            player.inventory = Inventory()
            player.inventory.items = player_data['inventory']['items']
            player.spells = [reconstruct_spell(spell_data) for spell_data in player_data['spells']]
            
            print(f"{Fore.GREEN}Game loaded!{Style.RESET_ALL}")
            print("Relearning spells:")
            for spell in player.spells:
                print(f"You relearned {spell.name}!")
            
            return player
        else:
            print(f"{Fore.RED}Save not found.{Style.RESET_ALL}")
            return None
    except ValueError:
        print(f"{Fore.RED}Invalid save ID.{Style.RESET_ALL}")
        return None

def combat(player, enemy):
    print(f"{Fore.RED}A wild {enemy.name} appears!{Style.RESET_ALL}")
    print(f"It seems weak against {enemy.weakness} and strong against {enemy.strength}.")
    
    while True:
        player_first = player.speed >= enemy.speed

        if player_first:
            if not player_turn(player, enemy):
                return False
            if enemy.hp <= 0:
                return combat_victory(player, enemy)
            if enemy_turn(enemy, player):
                return combat_defeat(player)
        else:
            if enemy_turn(enemy, player):
                return combat_defeat(player)
            if player.hp <= 0:
                return combat_defeat(player)
            if not player_turn(player, enemy):
                return False
            if enemy.hp <= 0:
                return combat_victory(player, enemy)

        print(f"\n{player.name} HP: {player.hp}/{player.max_hp}, MP: {player.mp}/{player.max_mp}")
        print(f"{enemy.name} HP: {enemy.hp}")

def determine_first_attacker(player, enemy):
    if player.speed >= enemy.speed:
        return True
    if random.random() < 0.1:  # 10% chance of surprise attack
        print("Surprise attack!")
        return not (player.speed >= enemy.speed)
    return False

def player_turn(player, enemy):
    print(f"\n{player.name} HP: {player.hp}/{player.max_hp}, MP: {player.mp}/{player.max_mp}")
    print(f"{enemy.name} HP: {enemy.hp}")
    action = input("Do you want to (1) Attack, (2) Cast a spell, (3) Use an item, or (4) Try to flee? ")
    
    if action == "1":
        damage = calculate_damage(player.attack, enemy.defense)
        print(f"{Fore.YELLOW}{player.name} attacks {enemy.name} for {damage} damage!{Style.RESET_ALL}")
        enemy.take_damage(damage)
    elif action == "2":
        if not player.spells:
            print(f"{Fore.RED}You don't know any spells yet!{Style.RESET_ALL}")
            return True
        print("Available spells:")
        for i, spell in enumerate(player.spells, 1):
            print(f"{i}. {spell.name} (MP cost: {spell.cost}, Element: {spell.element})")
        try:
            spell_choice = int(input("Choose a spell to cast: ")) - 1
            if 0 <= spell_choice < len(player.spells):
                spell = player.spells[spell_choice]
                spell_effect = player.cast_spell(spell)
                if spell_effect > 0:
                    damage = calculate_damage(spell_effect, enemy.defense)
                    print(f"{Fore.YELLOW}{player.name} casts {spell.name} for {damage} damage!{Style.RESET_ALL}")
                    enemy.take_damage(damage, spell.element)
                elif spell_effect < 0:
                    heal_amount = min(player.max_hp - player.hp, -spell_effect)
                    player.hp += heal_amount
                    print(f"{Fore.GREEN}{player.name} heals for {heal_amount} HP!{Style.RESET_ALL}")
                else:
                    print(f"{Fore.YELLOW}The spell had no effect!{Style.RESET_ALL}")
            else:
                print(f"{Fore.RED}Invalid spell choice!{Style.RESET_ALL}")
        except ValueError:
            print(f"{Fore.RED}Invalid input. Please enter a number.{Style.RESET_ALL}")
    elif action == "3":
        use_item_from_inventory(player)
    elif action == "4":
        if random.random() < 0.5:
            print(f"{Fore.GREEN}You successfully fled from the battle!{Style.RESET_ALL}")
            return False
        else:
            print(f"{Fore.RED}You failed to flee!{Style.RESET_ALL}")
    else:
        print(f"{Fore.RED}Invalid action! Turn skipped.{Style.RESET_ALL}")
    
    return True
    
def player_attack(player, enemy):
    damage = calculate_damage(player.strength, enemy.defense)
    enemy.take_damage(damage)
    return False

def player_cast_spell(player, enemy):
    if not player.spells:
        print(f"{Fore.RED}You don't know any spells yet!{Style.RESET_ALL}")
        return False
    print("Available spells:")
    for i, spell in enumerate(player.spells, 1):
        print(f"{i}. {spell.name} (MP cost: {spell.cost}, Element: {spell.element})")
    try:
        spell_choice = int(input("Choose a spell to cast: ")) - 1
        if 0 <= spell_choice < len(player.spells):
            spell = player.spells[spell_choice]
            spell_effect = player.cast_spell(spell)
            if spell_effect > 0:
                damage = calculate_damage(spell_effect, enemy.defense)
                print(f"{Fore.YELLOW}{player.name} casts {spell.name} for {damage} damage!{Style.RESET_ALL}")
                enemy.take_damage(damage, spell.element)
                print(f"{enemy.name}'s HP: {enemy.hp}")
                return False
            elif spell_effect < 0:
                heal_amount = min(player.max_hp - player.hp, -spell_effect)
                player.hp += heal_amount
                print(f"{Fore.GREEN}{player.name} heals for {heal_amount} HP!{Style.RESET_ALL}")
                print(f"{player.name}'s HP: {player.hp}/{player.max_hp}")
                return False
            else:
                print(f"{Fore.YELLOW}The spell had no effect!{Style.RESET_ALL}")
                return False
        else:
            print(f"{Fore.RED}Invalid spell choice!{Style.RESET_ALL}")
    except ValueError:
        print(f"{Fore.RED}Invalid input. Please enter a number.{Style.RESET_ALL}")
    return False

def player_use_item(player, enemy):
    if not player.inventory.items:
        print(f"{Fore.RED}Your inventory is empty!{Style.RESET_ALL}")
        return False
    print("Available items:")
    items = list(player.inventory.items.keys())
    for i, item in enumerate(items, 1):
        print(f"{i}. {item}")
    try:
        item_choice = int(input("Choose an item to use: ")) - 1
        if 0 <= item_choice < len(items):
            item = items[item_choice]
            if player.inventory.remove_item(item):
                effect = use_item(player, item)
                print(f"{Fore.GREEN}{effect}{Style.RESET_ALL}")
                return False
            else:
                print(f"{Fore.RED}Failed to use item!{Style.RESET_ALL}")
        else:
            print(f"{Fore.RED}Invalid choice!{Style.RESET_ALL}")
    except ValueError:
        print(f"{Fore.RED}Invalid input. Please enter a number.{Style.RESET_ALL}")
    return False

def player_flee(player, enemy):
    if random.random() < 0.5:
        print(f"{Fore.GREEN}You successfully fled from the battle!{Style.RESET_ALL}")
        return True
    else:
        print(f"{Fore.RED}You failed to flee!{Style.RESET_ALL}")
        return False

def enemy_turn(enemy, player):
    damage = calculate_damage(enemy.attack, player.defense)
    if random.random() < 0.1:
        damage *= 2
        print(f"{Fore.RED}Critical hit!{Style.RESET_ALL}")
    print(f"{Fore.RED}{enemy.name} attacks for {damage} damage!{Style.RESET_ALL}")
    player.take_damage(damage)
    
    # Special ability for Manualis enemies
    if isinstance(enemy, ManualisEnemy) and random.random() < 0.3:
        enemy.use_special_ability(player)
    
    print(f"{player.name}'s HP: {player.hp}/{player.max_hp}")
    return player.hp <= 0

def calculate_hit_chance(attacker, defender, attack_type):
    base_hit_chance = attacker.accuracy - defender.evasion
    if attack_type == "melee":
        hit_chance = base_hit_chance + attacker.melee_bonus
    elif attack_type == "ranged":
        hit_chance = base_hit_chance + attacker.ranged_bonus
    elif attack_type == "spell":
        hit_chance = base_hit_chance + attacker.magic_bonus
    return max(5, min(95, hit_chance))  # Ensure hit chance is between 5% and 95%

def attempt_attack(attacker, defender, attack_type):
    hit_chance = calculate_hit_chance(attacker, defender, attack_type)
    roll = random.randint(1, 100)
    
    if roll <= hit_chance:
        damage = calculate_damage(attacker.attack, defender.defense)
        defender.take_damage(damage)
        return f"{attacker.name} hits {defender.name} for {damage} damage!"
    else:
        if roll > hit_chance + defender.dodge_threshold:
            return f"{defender.name} dodges {attacker.name}'s attack!"
        else:
            return f"{attacker.name}'s attack misses {defender.name}!"

def combat_victory(player, enemy):
    player.gold += enemy.gold_reward
    player.gain_experience(enemy.exp_reward)
    print(f"{Fore.GREEN}You defeated {enemy.name} and gained {enemy.gold_reward} gold and {enemy.exp_reward} experience!{Style.RESET_ALL}")
    return True

def combat_defeat(player):
    print(f"{Fore.RED}Game Over. Your character has been defeated.{Style.RESET_ALL}")
    input("Press Enter to continue...")
    return False

def calculate_damage(attack_power, defense):
    base_damage = max(1, attack_power - defense // 2)
    return random.randint(base_damage - 2, base_damage + 2)

def camp(player):
    print(f"\n{Fore.GREEN}You set up camp in a safe area.{Style.RESET_ALL}")
    while True:
        print("\nCamp Options:")
        print("1. Rest (recover HP and MP)")
        print("2. Check Inventory")
        print("3. Check Character Status")
        print("4. Break Camp")
        
        choice = input("What would you like to do? ")
        
        if choice == "1":
            rest_time = int(input("How many hours would you like to rest? "))
            hp_recovery = min(rest_time * 5, player.max_hp - player.hp)
            mp_recovery = min(rest_time * 3, player.max_mp - player.mp)
            player.hp += hp_recovery
            player.mp += mp_recovery
            print(f"{Fore.GREEN}You rested for {rest_time} hours.{Style.RESET_ALL}")
            print(f"Recovered {hp_recovery} HP and {mp_recovery} MP.")
            print(f"Current HP: {player.hp}/{player.max_hp}, MP: {player.mp}/{player.max_mp}")
        
        elif choice == "2":
            print(f"\nInventory: {player.inventory}")
            use_item = input("Would you like to use an item? (y/n): ").lower()
            if use_item == 'y':
                item_name = input("Enter the name of the item you want to use: ")
                if player.inventory.remove_item(item_name):
                    if item_name == "Health Potion":
                        player.hp = min(player.max_hp, player.hp + 30)
                        print(f"{Fore.GREEN}You used a Health Potion and recovered 30 HP!{Style.RESET_ALL}")
                elif item_name == "Mana Potion":
                    player.mp = min(player.max_mp, player.mp + 20)
                    print(f"{Fore.GREEN}You used a Mana Potion and recovered 20 MP!{Style.RESET_ALL}")
                else:
                    print(f"{Fore.YELLOW}Item used, but no effect.{Style.RESET_ALL}")
            else:
                print(f"{Fore.RED}You don't have that item in your inventory.{Style.RESET_ALL}")
        
        elif choice == "3":
            print(player)
            print(f"Skills: {', '.join([f'{skill}: {level}' for skill, level in player.skills.items()])}")
        
        elif choice == "4":
            print("Breaking camp...")
            break
        
        else:
            print(f"{Fore.RED}Invalid choice. Please try again.{Style.RESET_ALL}")

def spell_shop(player):
    print(f"\n{Fore.CYAN}Welcome to the Spell Shop!{Style.RESET_ALL}")
    print(f"Your current gold: {player.gold}")
    available_spells = [
        FireballSpell(), WaterJetSpell(), RockThrowSpell(), WindSlashSpell(), HealSpell(), ShieldSpell()
    ]
    spell_prices = {spell.name: 50 for spell in available_spells}
    while True:
        print("\nAvailable spells:")
        for i, spell in enumerate(available_spells, 1):
            if spell.name not in [s.name for s in player.spells]:
                print(f"{i}. {spell.name} ({spell.element}) - {spell_prices[spell.name]} gold")
        print("0. Exit shop")
        try:
            choice = int(input("Enter the number of the spell you want to buy (or 0 to exit): "))
            if choice == 0:
                break
            if 1 <= choice <= len(available_spells):
                selected_spell = available_spells[choice - 1]
                if selected_spell.name in [s.name for s in player.spells]:
                    print(f"{Fore.YELLOW}You already know this spell!{Style.RESET_ALL}")
                elif player.gold >= spell_prices[selected_spell.name]:
                    player.gold -= spell_prices[selected_spell.name]
                    player.spells.append(selected_spell)
                    print(f"{Fore.GREEN}You learned {selected_spell.name}!{Style.RESET_ALL}")
                else:
                    print(f"{Fore.RED}Not enough gold!{Style.RESET_ALL}")
            else:
                print(f"{Fore.RED}Invalid choice!{Style.RESET_ALL}")
        except ValueError:
            print(f"{Fore.RED}Invalid input. Please enter a number.{Style.RESET_ALL}")

def safe_exec(code, globals=None):
    """Execute code in a safe environment."""
    try:
        tree = ast.parse(code)
        for node in ast.walk(tree):
            if isinstance(node, (ast.Import, ast.ImportFrom)):
                raise ImportError("Imports are not allowed")
        exec(code, globals)
    except Exception as e:
        return str(e)
    return None

def run_tests(user_code, test_cases):
    """Run test cases on user code."""
    globals_dict = {}
    error = safe_exec(user_code, globals_dict)
    if error:
        return False, f"Error in your code: {error}"
    
    for inputs, expected_output in test_cases:
        f = io.StringIO()
        with redirect_stdout(f):
            try:
                exec(f"{user_code}\n{inputs}", globals_dict)
            except Exception as e:
                return False, f"Error during test case: {e}"
        result = f.getvalue().strip()
        if result != str(expected_output).strip():
            return False, f"Test case failed. Expected {expected_output}, but got {result}"
    
    return True, "All test cases passed!"

def get_multiline_input(prompt):
    root = tk.Tk()
    root.title("Code Input")
    
    label = tk.Label(root, text=prompt)
    label.pack(pady=10)
    
    text_area = scrolledtext.ScrolledText(root, width=50, height=10)
    text_area.pack(pady=10)
    
    code = []
    
    def on_submit():
        code.append(text_area.get("1.0", tk.END).strip())
        root.quit()
    
    submit_button = tk.Button(root, text="Submit", command=on_submit)
    submit_button.pack(pady=10)
    
    root.mainloop()
    root.destroy()
    
    return code[0]

def coding_challenge(player, difficulty):
    challenges = {
        "easy": [
            {
                "description": "Write a function that adds two numbers and returns the result.",
                "function_name": "add_numbers",
                "test_cases": [
                    ("print(add_numbers(2, 3))", 5),
                    ("print(add_numbers(-1, 1))", 0),
                    ("print(add_numbers(10, 20))", 30),
                ],
                "hint": "Define a function that takes two parameters and use the + operator."
            },
            # Add more easy challenges...
        ],
        "medium": [
            {
                "description": "Write a function that returns the factorial of a given number.",
                "function_name": "factorial",
                "test_cases": [
                    ("print(factorial(5))", 120),
                    ("print(factorial(0))", 1),
                    ("print(factorial(3))", 6),
                ],
                "hint": "Remember that factorial of n is the product of all positive integers up to n. You can use a loop or recursion."
            },
            # Add more medium challenges...
        ],
        "hard": [
            {
                "description": "Implement a function to check if a given string is a palindrome.",
                "function_name": "is_palindrome",
                "test_cases": [
                    ("print(is_palindrome('racecar'))", True),
                    ("print(is_palindrome('hello'))", False),
                    ("print(is_palindrome('A man a plan a canal Panama'))", True),
                ],
                "hint": "Consider removing spaces and converting to lowercase. You can compare the string with its reverse."
            },
            # Add more hard challenges...
        ]
    }

    available_challenges = [c for c in challenges[difficulty] if c['function_name'] not in player.completed_challenges]
    if not available_challenges:
        print(f"No more {difficulty} challenges available. Try a different difficulty!")
        return False
    
    challenge = random.choice(available_challenges)

    print(f"\n{Fore.CYAN}Coding Challenge:{Style.RESET_ALL} {challenge['description']}")
    print(f"Define a function named '{challenge['function_name']}'")
    print(f"Hint: {challenge['hint']}")
    
    attempts = 3
    while attempts > 0:
        user_solution = get_multiline_input("Enter your solution:")
        success, message = run_tests(user_solution, challenge['test_cases'])
        
        if success:
            print(f"{Fore.GREEN}Correct! {message}{Style.RESET_ALL}")
            reward = {"easy": 10, "medium": 20, "hard": 30}[difficulty]
            player.gain_experience(reward)
            player.skills["Programming"] += 1
            print(f"You gained {reward} experience and improved your Programming skill!")
            player.completed_challenges.add(challenge['function_name'])
            print(f"Challenges completed: {len(player.completed_challenges)}/{sum(len(c) for c in challenges.values())}")
            return True
        else:
            attempts -= 1
            if attempts > 0:
                print(f"{Fore.YELLOW}{message}{Style.RESET_ALL}")
                print(f"You have {attempts} {'attempts' if attempts > 1 else 'attempt'} left. Try again!")
            else:
                print(f"{Fore.RED}Out of attempts. Here's a sample solution:{Style.RESET_ALL}")
                if difficulty == "easy":
                    print("def add_numbers(a, b):\n    return a + b")
                elif difficulty == "medium":
                    print("def factorial(n):\n    if n == 0:\n        return 1\n    return n * factorial(n-1)")
                else:
                    print("def is_palindrome(s):\n    s = ''.join(c.lower() for c in s if c.isalnum())\n    return s == s[::-1]")
                print("Keep practicing!")
                return False

def get_random_enemy():
    affinities = ["Fire", "Water", "Earth", "Air"]
    enemies = [
        ManualisEnemy("Syntax Error Sprite", 30, 8, 2, 15, 20, "Syntax Terror", 
                      random.choice(affinities), random.choice(affinities)),
        ManualisEnemy("Logic Bug", 40, 10, 3, 20, 25, "Logic Bomb", 
                      random.choice(affinities), random.choice(affinities)),
        ManualisEnemy("Exception Demon", 50, 12, 4, 25, 30, "Data Corruption", 
                      random.choice(affinities), random.choice(affinities)),
        ManualisEnemy("Code Goblin", 25, 7, 1, 10, 15, "Code Confusion", 
                      random.choice(affinities), random.choice(affinities)),
        ManualisEnemy("Repetitive Task Golem", 50, 10, 5, 20, 20, "Dreaded Repeater", 
                      random.choice(affinities), random.choice(affinities)),
        ManualisEnemy("Manual Troll", 30, 15, 3, 15, 15, "Manual Trolling",
                      random.choice(affinities), random.choice(affinities)),
        ManualisEnemy("Infinite Loop Wraith", 40, 12, 4, 25, 25, "Infinite Loop", 
                      random.choice(affinities), random.choice(affinities))
    ]
    enemy = random.choice(enemies)
    while enemy.weakness == enemy.strength:
        enemy.strength = random.choice(affinities)
    return enemy

def explore_area(player):
    areas = ["Enchanted Forest", "Data Structures Dungeon", "Function Forest", "Object-Oriented Oasis", "Algorithm Archipelago"]
    print(f"\n{Fore.CYAN}Available areas to explore:{Style.RESET_ALL}")
    for i, area in enumerate(areas, 1):
        print(f"{i}. {area}")
    
    try:
        choice = int(input("Choose an area to explore (or 0 to cancel): "))
        if choice == 0:
            return
        if 1 <= choice <= len(areas):
            area = areas[choice - 1]
            print(f"\n{Fore.YELLOW}Exploring {area}...{Style.RESET_ALL}")
            
            # Multiple random encounters
            num_encounters = random.randint(3, 7)
            for i in range(num_encounters):
                print(f"\n{Fore.CYAN}Encounter {i+1} of {num_encounters}{Style.RESET_ALL}")
                enemy = get_random_enemy()
                print(f"You encounter a {enemy.name}!")
                if not combat(player, enemy):
                    print(f"{Fore.RED}You were defeated. Retreating from {area}...{Style.RESET_ALL}")
                    return False
                
                # After each encounter, give the player a choice
                if i < num_encounters - 1:  # Don't ask after the last encounter
                    choice = input(f"{Fore.YELLOW}Do you want to continue exploring? (y/n): {Style.RESET_ALL}").lower()
                    if choice != 'y':
                        print(f"You decide to retreat from {area}.")
                        return True
            
            print(f"\n{Fore.GREEN}You've successfully navigated through {num_encounters} encounters!{Style.RESET_ALL}")
            print(f"{Fore.CYAN}Entering the heart of {area}...{Style.RESET_ALL}")
            
            # Run specific area function
            if area == "Enchanted Forest":
                return enchanted_forest_quest(player)
            elif area == "Data Structures Dungeon":
                return data_structures_dungeon(player)
            elif area == "Function Forest":
                return function_forest(player)
            elif area == "Object-Oriented Oasis":
                return object_oriented_oasis(player)
            elif area == "Algorithm Archipelago":
                return algorithm_archipelago(player)
            
        else:
            print(f"{Fore.RED}Invalid choice. Please try again.{Style.RESET_ALL}")
            return False

    except ValueError:
        print(f"{Fore.RED}Invalid input. Please enter a number.{Style.RESET_ALL}")
        return False
    
def prologue(player):
    print("You find yourself in a world where code comes to life...")
    time.sleep(10)
    print("In the tranquil village of Codria, nestled in the heart of Pylandia, life has always been harmonious.")
    time.sleep(5)
    print("However, dark forces have begun to stir in the Enchanted Forest, disrupting the peace.")
    time.sleep(5)
    print("These forces, known as the Manualis, represent manual and tedious tasks that drain the vitality of the land.")
    time.sleep(5)
    print("The village elder, an ancient mage with deep knowledge of the arcane arts, senses an opportunity to fight back using the power of automation.")
    time.sleep(5)
    print(f"You, {player.name}, a young apprentice mage with latent potential, have been chosen to embark on a journey to restore balance back to Pylandia.")
    time.sleep(5)
    print("Armed with curiosity and a desire to learn, you set out to retrieve a powerful magical artifact, the 'Hello World' script.")
    time.sleep(5)
    print("This magical artifact will be your first step towards mastering Python sorcery and achieving peace throughout the land.\n")
    print(player)
    input("Press Enter to begin your adventure...")
    return True
  

def enchanted_forest_quest(player):
    print(f"{player.name}, the village is under threat from dark forces representing manual tasks.")
    print("You must retrieve the magical artifact from the Enchanted Forest.")

    print("Congratulations! You've retrieved the 'Hello World' script.")
    print("This script will be your foundation for future coding challenges.")
    player.gain_experience(50)
    return True

def data_structures_dungeon(player):
    print("\nChapter 2: Data Structures Dungeon")
    print("You enter a mysterious dungeon filled with puzzles based on data structures.")

    # List sorting puzzle
    print("\nPuzzle 1: The Unsorted Library")
    books = ["Python Basics", "Advanced Algorithms", "Data Structures 101", "Machine Learning"]
    print("You find a shelf of unsorted books:", books)
    sorted_books = sorted(books)
    player_sort = input("Sort these books alphabetically (comma-separated): ").split(", ")
    if player_sort == sorted_books:
        print("Correct! The books magically rearrange themselves.")
        player.gain_experience(15)
    else:
        print("Incorrect. The correct order was:", sorted_books)
        player.take_damage(10)

    # Dictionary puzzle
    print("\nPuzzle 2: The Magical Inventory")
    inventory = {"sword": 1, "shield": 1, "health potion": 3}
    print("You find a magical bag. Its contents are:", inventory)
    item_to_add = input("What item would you like to add to the inventory? ")
    quantity = int(input("How many? "))
    if item_to_add in inventory:
        inventory[item_to_add] += quantity
    else:
        inventory[item_to_add] = quantity
    print("Updated inventory:", inventory)
    player.gain_experience(15)

    print("\nYou've completed the Data Structures Dungeon!")
    player.inventory.add_item("Mana Potion", 2)
    print("You found 2 Mana Potions!")
    player.gain_experience(50)
    return True

def function_forest(player):
    print("\nChapter 3: Function Forest")
    print("You enter a mystical forest where everything operates on functions.")

    def magical_echo(phrase):
        return phrase.upper() + "!"

    player_phrase = input("Speak a phrase to the Magical Echo Tree: ")
    echo = magical_echo(player_phrase)
    print("The tree echoes:", echo)
    player.gain_experience(10)

    def fibonacci(n):
        if n <= 1:
            return n
        else:
            return fibonacci(n-1) + fibonacci(n-2)

    print("\nYou encounter the Fibonacci Flower with spiraling petals.")
    n = int(input("How many petals do you see? "))
    correct_petals = fibonacci(n)
    player_answer = int(input(f"What's the {n}th Fibonacci number? "))
    if player_answer == correct_petals:
        print("Correct! The flower blooms, revealing a hidden path.")
        player.gain_experience(20)
    else:
        print(f"Incorrect. The correct answer was {correct_petals}.")
        player.take_damage(15)

    print("\nYou've navigated the Function Forest!")
    player.inventory.add_item("Health Potion", 2)
    print("You found 2 Health Potions!")
    player.gain_experience(50)
    return True

def object_oriented_oasis(player):
    print("\nChapter 4: Object-Oriented Oasis")
    print("You arrive at an oasis where everything is an object.")

    class MagicalCreature:
        def __init__(self, name, power):
            self.name = name
            self.power = power

        def special_ability(self):
            print(f"{self.name} uses its special ability!")

    class Phoenix(MagicalCreature):
        def special_ability(self):
            print(f"{self.name} rises from the ashes, restoring 20 HP!")
            player.hp = min(player.max_hp, player.hp + 20)

    class Unicorn(MagicalCreature):
        def special_ability(self):
            print(f"{self.name} grants a wish, adding a random item to your inventory!")
            items = ["Health Potion", "Mana Potion", "Strength Elixir"]
            player.inventory.add_item(random.choice(items))

    creatures = [Phoenix("Fawkes", 100), Unicorn("Starlight", 80)]
    
    print("You encounter two magical creatures.")
    for i, creature in enumerate(creatures, 1):
        print(f"{i}. {creature.name}")
    
    choice = int(input("Which creature do you approach? (1/2): ")) - 1
    if 0 <= choice < len(creatures):
        creatures[choice].special_ability()
        player.gain_experience(25)
    else:
        print("Invalid choice. Both creatures disappear.")

    print("\nYou've explored the Object-Oriented Oasis!")
    player.gain_experience(50)
    return True

def algorithm_archipelago(player):
    print("\nChapter 5: Algorithm Archipelago")
    print("You arrive at a chain of islands, each representing a different algorithm.")

    # Implement algorithm challenges here
    # For example:
    print("Island 1: Sorting Island")
    numbers = [5, 2, 8, 12, 1, 6]
    print("Unsorted numbers:", numbers)
    sorted_numbers = sorted(numbers)
    player_sort = input("Sort these numbers (comma-separated): ")
    player_sort = [int(x) for x in player_sort.split(',')]
    if player_sort == sorted_numbers:
        print("Correct! You've mastered Sorting Island.")
        player.gain_experience(20)
    else:
        print("Incorrect. The correct order was:", sorted_numbers)
        player.take_damage(10)

    # Add more algorithm challenges as needed

    print("\nYou've conquered the Algorithm Archipelago!")
    player.inventory.add_item("Strength Elixir", 1)
    print("You found a Strength Elixir!")
    player.gain_experience(50)
    return True

def main_game_loop():
    print(f"{Fore.CYAN}Welcome to Code Quest: The Manualis Menace!{Style.RESET_ALL}")
    
    while True:
        load_choice = input("Do you want to (1) Start a new game or (2) Load a saved game? ")
        if load_choice == "2":
            player = load_game()
            if player is None:
                print("No saved game found or loading cancelled. Starting a new game...")
                player = create_character()
                prologue(player)
            break
        elif load_choice == "1":
            player = create_character()
            prologue(player)
            break
        else:
            print(f"{Fore.RED}Invalid choice. Please try again.{Style.RESET_ALL}")

    while True:
        print(f"\n{Fore.YELLOW}What would you like to do?{Style.RESET_ALL}")
        print("1. Explore an area")
        print("2. Visit the spell shop")
        print("3. View character status")
        print("4. Use item from inventory")
        print("5. Save game")
        print("6. Quit game")
        
        choice = input("Enter your choice: ")
        
        if choice == "1":
            explore_area(player)
        elif choice == "2":
            spell_shop(player)
        elif choice == "3":
            print(player)
            print(f"Inventory: {player.inventory}")
            print(f"Skills: {', '.join([f'{skill}: {level}' for skill, level in player.skills.items()])}")
        elif choice == "4":
            effect = use_item_from_inventory(player)
            if effect:
                print(f"{Fore.GREEN}{effect}{Style.RESET_ALL}")
            print(player)
            print(f"Inventory: {player.inventory}")
            print(f"Skills: {', '.join([f'{skill}: {level}' for skill, level in player.skills.items()])}")
        elif choice == "5":
            save_game(player)
        elif choice == "6":
            save_choice = input("Do you want to save before quitting? (y/n): ")
            if save_choice.lower() == 'y':
                save_game(player)
            print("Thanks for playing Code Quest: The Manualis Menace!")
            break
        else:
            print(f"{Fore.RED}Invalid choice. Please try again.{Style.RESET_ALL}")

# def main_gui():
    # root = tk.Tk()
    # root.title("Adventure Game")

    # frame = tk.Frame(root)
    # frame.pack(pady=20)

    # tk.Label(frame, text="Welcome to the Adventure Game!").pack()

    # player = create_character()

    # def start_game():
        # random_encounters(player)
        # save_game(player)

    # tk.Button(frame, text="Start Game", command=start_game).pack(pady=10)
     #tk.Button(frame, text="Load Game", command=lambda: load_game()).pack(pady=10)

    # root.mainloop()

# if __name__ == "__main__":
    # main_gui()

if __name__ == "__main__":
    main_game_loop()