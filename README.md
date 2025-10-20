<img width="2948" height="497" alt="rsg_framework" src="https://github.com/user-attachments/assets/638791d8-296d-4817-a596-785325c1b83a" />

# 🍞 rsg-consume
**Universal consumption system for RedM using RSG Core.**

![Platform](https://img.shields.io/badge/platform-RedM-darkred)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

> Immersive eating and drinking system for RedM servers built on RSG Core.  
> Adds configurable hunger, thirst, alcohol, stress, and poison effects with synchronized animations and props.

---

## 🛠️ Dependencies
- [**rsg-core**](https://github.com/Rexshack-RedM/rsg-core) 🤠  
- [**ox_lib**](https://github.com/Rexshack-RedM/ox_lib) ⚙️ *(notifications, locales)*  
- [**rsg-inventory**](https://github.com/Rexshack-RedM/rsg-inventory) 🎒 *(item use integration)*  

**Locales:** `en`, `fr`, `es`, `el`, `pt-br`, `it`, `ro`  
**License:** GPL‑3.0  

---

## ✨ Features

### 🍴 Food, Drink & Stew
- Configurable consumable categories:
  - `Eat` → food items (e.g., bread, steak)
  - `Drink` → drinks (e.g., water, whiskey, coffee)
  - `Stew` → soups and stews (uses bowl animation)
- Each item can modify multiple needs:
  - Hunger, Thirst, Stress, Alcohol, Poison, PoisonRate
- Items automatically become **usable** via `RSGCore.Functions.CreateUseableItem()`.

### 🍺 Alcohol System
- Each alcoholic item increases the player’s alcohol level.  
- At high levels, players experience:
  - Motion blur and camera shake
  - Drunken movement effects
- Alcohol level decays over time (`Config.AlcoholDecayRate`).

### ☠️ Poison & Stress
- Poison gradually damages the player's health over time.  
- Certain foods/drinks can reduce stress.

### ❤️ Advanced Health Recovery System
- **Smart Combat Detection**: Automatically pauses health regeneration during combat
- **Balanced Regeneration**: Realistic health recovery rates (0.15% per 20 seconds)
- **Damage Cooldown**: 45-second cooldown after taking damage before regeneration starts
- **Combat Timeout**: 15 seconds of no damage to exit combat state
- **Resting Bonus**: Slightly faster regeneration when not moving (1.3x multiplier)
- **Integration**: Works seamlessly with rsg-medic and rex_zombies systems  

### 🎬 Immersive Animations
Each consumption type has its own prop and animation:
| Type | Animation | Example Prop |
|------|------------|--------------|
| Eat | “eat_food” | bread, meat |
| Drink | “drink_bottle” | bottle, mug |
| Stew | “eat_stew” | bowl |
| HotDrink | “drink_cup” | coffee cup |

Animations sync between client and nearby players for full immersion.

---

## ⚙️ Configuration (`config.lua`)

Example structure:
```lua
Consumables = {
    Eat = {
        bread = {
            hunger = 30,
            thirst = 0,
            stress = -5,
            alcohol = 0,
            poison = 0,
            poisonRate = 0,
            propname = "p_bread01x",
        },
    },
    Drink = {
        water = {
            hunger = 0,
            thirst = 35,
            stress = -2,
            alcohol = 0,
            propname = "p_bottle02x",
        },
        whiskey = {
            hunger = 0,
            thirst = 10,
            stress = -10,
            alcohol = 25,
            propname = "p_bottleWhiskey01x",
        },
    },
    Stew = {
        stew = {
            hunger = 50,
            thirst = 10,
            stress = -10,
            propname = "p_bowl04x",
        },
    },
}
```

### 🔧 Key Configuration Fields
| Key | Description |
|------|-------------|
| `hunger` | How much hunger to restore |
| `thirst` | How much thirst to restore |
| `stress` | Stress modifier (negative reduces stress) |
| `alcohol` | Adds alcohol level (higher = stronger drunk effect) |
| `poison` | Initial poison level applied to player |
| `poisonRate` | Rate at which poison damages player |
| `propname` | Object used in animation (prop model name) |

### 🧮 System Settings (from config)
```lua
Config.AlcoholDecayRate = 0.2  -- How quickly alcohol wears off
Config.PoisonTickRate = 1.0    -- How often poison effect applies (seconds)
Config.AnimDuration = 5000     -- Default consumption animation duration (ms)
Config.Debug = false           -- Enable debug prints

-- Health Recovery System
HealthRecoverySystem = {
    EnableAutoRecovery = true,    -- Enable automatic health recovery
    RecoveryRate = 0.15,          -- Health points recovered per cycle (percentage)
    RecoveryInterval = 20000,     -- Recovery interval (in ms) - 20 seconds
    MinHealthThreshold = 25,      -- Minimum health percentage to start auto recovery
    MaxRecoveryAmount = 65,       -- Maximum health percentage that can be recovered automatically
    
    -- Combat Detection System
    CombatDetection = {
        Enabled = true,            -- Enable combat detection to pause regeneration
        DamageCooldown = 45000,   -- 45 seconds after taking damage before regeneration starts
        CombatTimeout = 15000,    -- 15 seconds of no damage to exit combat
        MinDamageToTrigger = 8,   -- Minimum damage to trigger combat state
    },
    
    -- Resting System
    RecoveryWhenResting = true,   -- Faster recovery when not moving
    RestingMultiplier = 1.3,      -- Multiplier for recovery when resting
    RestingSpeedThreshold = 0.8,  -- Speed below this is considered "resting"
    
    Debug = false,                -- Enable debug messages
}
```

---

## 🍽️ Item Examples (RSG Inventory)

```lua
bread   = { name = 'bread',   label = 'Bread',              weight = 100, type = 'item', image = 'consumable_bread_roll.png',    unique = false, useable = true, decay = 300, delete = true, shouldClose = true, description = 'A fresh piece of bread' },
water   = { name = 'water',   label = 'Water Bottle',       weight = 100, type = 'item', image = 'consumable_water_bottle.png',  unique = false, useable = true, decay = 300, delete = true, shouldClose = true, description = 'Fresh water to quench your thirst' },
whiskey = { name = 'whiskey', label = 'Whiskey Bottle',     weight = 150, type = 'item', image = 'consumable_whiskey_bottle.png',unique = false, useable = true, decay = 300, delete = true, shouldClose = true, description = 'A strong whiskey that warms you up and goes straight to your head' },
stew    = { name = 'stew',    label = 'Bowl of Stew',       weight = 200, type = 'item', image = 'consumable_stew.png',          unique = false, useable = true, decay = 300, delete = true, shouldClose = true, description = 'A hot, hearty bowl of stew' },
coffee  = { name = 'coffee',  label = 'Cup of Coffee',      weight = 80,  type = 'item', image = 'consumable_coffee.png',        unique = false, useable = true, decay = 300, delete = true, shouldClose = true, description = 'A strong black coffee to wake you up' },
```

---

## 📂 Installation
1. Place `rsg-consume` inside your `resources/[rsg]` folder.  
2. Ensure `rsg-core`, `rsg-inventory`, and `ox_lib` are installed.  
3. Add to your `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure rsg-core
   ensure rsg-inventory
   ensure rsg-consume
   ```
4. Restart your server.

---

## 🎮 Commands & Debugging

### Health Recovery System Commands
- `/healthstatus` - Shows current health regeneration status
- `/healthdebug` - Toggles debug mode for health system

### Debug Information
When debug mode is enabled, you'll see messages like:
```
[RSG-CONSUME] Entered combat state - Damage: 15
[RSG-CONSUME] Exited combat state
[RSG-CONSUME] Regenerated 3 health (45% -> 48%)
```

### Health Status Display
The `/healthstatus` command shows:
- Current health percentage
- Combat state (Yes/No)
- Can regenerate (Yes/No)
- System status (Active/Inactive)
- Combat detection status

---

## 🌍 Locales
Included: `en`, `fr`, `es`, `el`, `pt-br`, `it`, `ro`  
Loaded automatically with `lib.locale()`.

---

## 💎 Credits
- **RSG / Rexshack-RedM** — base framework & design  
- Original concept and effects adapted by **Rexshack Dev Team**  
- Alcohol system logic added by **Suu** → [github.com/suu-yoshida](https://github.com/suu-yoshida)  
- Community testers and translators  
- License: GPL‑3.0  
