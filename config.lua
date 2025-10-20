return {

    Consumables = {
        Eat = { -- default food items
            ['bread'] = {
                item = 'bread',
                hunger = 25,
                thirst = 0,
                stress = -5,
                propname = 'p_bread_14_ab_s_a',
                poison = 0,
                poisonRate = 0,
            },
            -- Comidas personalizadas
            ['grilled_steak'] = {
                item = 'grilled_steak',
                hunger = 60,
                thirst = 0,
                stress = -10,
                health = 15,
                propname = 'p_meat_steak01x',
            },
            ['fish_soup'] = {
                item = 'fish_soup',
                hunger = 45,
                thirst = 20,
                stress = -15,
                health = 20,
                propname = 'p_bowl04x_stew',
            },
            ['chicken_soup'] = {
                item = 'chicken_soup',
                hunger = 50,
                thirst = 15,
                stress = -12,
                health = 18,
                propname = 'p_bowl04x_stew',
            },
            -- Frutas
            ['blueberry'] = {
                item = 'blueberry',
                hunger = 15,
                thirst = 10,
                stress = -5,
                propname = 'p_berry_black01x',
            },
            ['banana'] = {
                item = 'banana',
                hunger = 20,
                thirst = 5,
                stress = -3,
                propname = 'p_banana01x',
            },
            ['orange'] = {
                item = 'orange',
                hunger = 18,
                thirst = 15,
                stress = -4,
                propname = 'p_orange01x',
            },
            ['lemon'] = {
                item = 'lemon',
                hunger = 10,
                thirst = 20,
                stress = -2,
                propname = 'p_lemon01x',
            },
            ['black_berry'] = {
                item = 'black_berry',
                hunger = 12,
                thirst = 8,
                stress = -3,
                propname = 'p_berry_black01x',
            },
            ['golden_currant'] = {
                item = 'golden_currant',
                hunger = 25,
                thirst = 12,
                stress = -8,
                propname = 'p_berry_black01x',
            },
            -- Vegetais
            ['mushroom'] = {
                item = 'mushroom',
                hunger = 20,
                thirst = 5,
                stress = -5,
                propname = 'p_mushroom01x',
            },
            ['wild_carrot'] = {
                item = 'wild_carrot',
                hunger = 25,
                thirst = 8,
                stress = -6,
                propname = 'p_carrot01x',
            },
            -- Ervas medicinais (pequenas quantidades)
            ['ginseng'] = {
                item = 'ginseng',
                hunger = 5,
                thirst = 5,
                stress = -15,
                propname = 'p_herb_ginseng01x',
            },
            ['echinacea'] = {
                item = 'echinacea',
                hunger = 3,
                thirst = 3,
                stress = -10,
                propname = 'p_herb_echinacea01x',
            },
            ['chamomile'] = {
                item = 'chamomile',
                hunger = 2,
                thirst = 8,
                stress = -20,
                propname = 'p_herb_chamomile01x',
            },
            ['lavender'] = {
                item = 'lavender',
                hunger = 2,
                thirst = 5,
                stress = -18,
                propname = 'p_herb_lavender01x',
            },
            -- Itens de cura para zombies
            ['morphine'] = {
                item = 'morphine',
                hunger = 0,
                thirst = 0,
                stress = -30,
                health = 50,
                propname = 'p_bottleJD01x',
            },
            ['holy_water'] = {
                item = 'holy_water',
                hunger = 0,
                thirst = 20,
                stress = -25,
                health = 30,
                propname = 'p_bottle02x',
            },
            ['herbs'] = {
                item = 'herbs',
                hunger = 5,
                thirst = 5,
                stress = -20,
                health = 25,
                propname = 'p_herb_ginseng01x',
            },
            ['bandage'] = {
                item = 'bandage',
                hunger = 0,
                thirst = 0,
                stress = -15,
                health = 20,
                propname = 'p_bandage01x',
            },
        },
        Drink = { -- default drink items
            ['water'] = {
                item = 'water',
                hunger = 0,
                thirst = 25,
                stress = 5,
                alcohol = -5,
                propname = 'p_bottlebeer01a'
            },
            ['beer'] = {
                item = 'beer',
                hunger = -3,
                thirst = 0,
                stress = -10,
                alcohol = 25,
                propname = 'p_bottlebeer01a'
            },
            -- Sumos personalizados
            ['apple_juice'] = {
                item = 'apple_juice',
                hunger = 10,
                thirst = 30,
                stress = -8,
                alcohol = -3,
                propname = 'p_bottlebeer01a'
            },
            ['orange_juice'] = {
                item = 'orange_juice',
                hunger = 8,
                thirst = 35,
                stress = -10,
                alcohol = -3,
                propname = 'p_bottlebeer01a'
            },
            -- Antídoto específico para zombies (bebida)
            ['antidote'] = {
                item = 'antidote',
                hunger = 0,
                thirst = 0,
                stress = -35,
                health = 40,
                propname = 'p_bottleJD01x',
            },
            ['zombie_vaccine'] = {
                item = 'zombie_vaccine',
                hunger = 0,
                thirst = 0,
                stress = -40,
                health = 60,
                propname = 'p_bottle02x',
            },
        },
        Stew = { -- default stew items
            ['stew'] = {
                item = 'stew',
                hunger = 50,
                thirst = 25,
                stress = 20,
                alcohol = -10,
                propname = 'p_bowl04x_stew'
            },
            -- Sopas personalizadas
            ['fish_soup'] = {
                item = 'fish_soup',
                hunger = 45,
                thirst = 20,
                stress = -15,
                alcohol = -8,
                health = 20,
                propname = 'p_bowl04x_stew'
            },
            ['chicken_soup'] = {
                item = 'chicken_soup',
                hunger = 50,
                thirst = 15,
                stress = -12,
                alcohol = -8,
                health = 18,
                propname = 'p_bowl04x_stew'
            },
        },
        Hotdrinks = { -- default hot drink items
            ['coffee'] = {
                item = 'coffee',
                hunger = 0,
                thirst = 25,
                stress = 20,
                alcohol = -15,
                -- Fixed: Added a propname for the coffee item
                propname = 'p_mug01_coffee'
            },
            -- Chás de ervas medicinais
            ['ginseng'] = {
                item = 'ginseng',
                hunger = 5,
                thirst = 20,
                stress = -25,
                alcohol = -5,
                propname = 'p_mug01_coffee'
            },
            ['chamomile'] = {
                item = 'chamomile',
                hunger = 2,
                thirst = 15,
                stress = -30,
                alcohol = -5,
                propname = 'p_mug01_coffee'
            },
            ['lavender'] = {
                item = 'lavender',
                hunger = 2,
                thirst = 12,
                stress = -25,
                alcohol = -5,
                propname = 'p_mug01_coffee'
            },
        },
        Eatcanned = { -- canned food items
            ['canned_apricots'] = {
                item = 'canned_apricots',
                hunger = 50,
                thirst = 20,
                stress = 10,
                alcohol = -3,
                propname = 's_canrigapricots01x',
            },
        },
    },

    -- AlcoholSystem Configuration
    AlcoholSystem = {
        DrunkThreshold = 50,      -- Threshold to be considered drunk
        PassOutThreshold = 200,   -- Threshold to pass out
        WakeUpLevel = 55,         -- Alcohol level upon waking up (just below the drunk threshold)
        DecreaseAmount = 1,       -- Points removed per cycle
        DecreaseInterval = 5000,  -- Decrement interval (in ms)
        MaxAlcoholLevel = 500,    -- Maximum alcohol level (safety)
    },

    -- HealthRecoverySystem Configuration
    HealthRecoverySystem = {
        EnableAutoRecovery = true,    -- Enable automatic health recovery
        RecoveryRate = 0.15,          -- Health points recovered per cycle (percentage) - REDUCED for balance
        RecoveryInterval = 20000,     -- Recovery interval (in ms) - 20 seconds (slower)
        MinHealthThreshold = 25,      -- Minimum health percentage to start auto recovery
        MaxRecoveryAmount = 65,       -- Maximum health percentage that can be recovered automatically - REDUCED
        
        -- Combat Detection System
        CombatDetection = {
            Enabled = true,            -- Enable combat detection to pause regeneration
            DamageCooldown = 45000,   -- 45 seconds after taking damage before regeneration starts
            CombatTimeout = 15000,    -- 15 seconds of no damage to exit combat
            MinDamageToTrigger = 8,   -- Minimum damage to trigger combat state
        },
        
        -- Resting System (improved)
        RecoveryWhenResting = true,   -- Faster recovery when not moving
        RestingMultiplier = 1.3,      -- Multiplier for recovery when resting - REDUCED from 2.0
        RestingSpeedThreshold = 0.8,  -- Speed below this is considered "resting"
        
        -- Debug Options
        Debug = false,                -- Enable debug messages
    },

    -- Hunger and Thirst System Configuration
    NeedsSystem = {
        EnableAutoDecrease = true,    -- Enable automatic hunger/thirst decrease
        HungerDecreaseRate = 1,       -- Hunger points decreased per cycle
        ThirstDecreaseRate = 1.5,     -- Thirst points decreased per cycle (thirst decreases faster)
        DecreaseInterval = 30000,     -- Decrease interval (in ms) - 30 seconds
        
        -- Activity-based decrease rates
        ActivityMultipliers = {
            Idle = 1.0,               -- Normal decrease when idle
            Walking = 1.2,            -- 20% faster decrease when walking
            Running = 1.5,            -- 50% faster decrease when running
            Sprinting = 2.0,          -- 100% faster decrease when sprinting
            Swimming = 2.5,           -- 150% faster decrease when swimming
        },
        
        -- Minimum thresholds
        MinHunger = 0,                -- Minimum hunger level
        MinThirst = 0,                -- Minimum thirst level
        
        -- Effects when needs are low
        LowHungerThreshold = 20,      -- Hunger level to show warning
        LowThirstThreshold = 15,      -- Thirst level to show warning
        CriticalHungerThreshold = 5,  -- Critical hunger level
        CriticalThirstThreshold = 5,  -- Critical thirst level
        
        -- Health damage when needs are critical
        EnableHealthDamage = true,    -- Enable health damage from low needs
        HealthDamageAmount = 2,       -- Health damage per cycle when critical
        HealthDamageInterval = 10000, -- Health damage interval (in ms) - 10 seconds
        
        -- Debug Options
        Debug = false,                -- Enable debug messages
    },

    AlcoholEffects = {
        -- Visual Effects Configuration
        DrunkEffect = true,                      -- Enable or disable the drunk post-fx effect
        DrunkEffectName = "PlayerDrunk01",       -- The name of the visual effect for being drunk
        PassOutEffect = "PlayerDrunk01_PassOut", -- The name of the visual effect for passing out
        WakeUpEffect = "PlayerWakeUpDrunk",      -- The name of the visual effect for waking up
        GroggyEffectName = "PlayerHealthPoorCS", -- The visual effect for the hangover/groggy state

        -- Timings & Durations (in milliseconds)
        GroggyDuration = 15000,                  -- How long the hangover state lasts after waking up (ms)
        VomitDuration = 10000,                   -- How long the vomit animation plays (ms)
        SleepDuration = 20000,                   -- How long the character sleeps on the ground (ms)
        FadeOutDuration = 10000,                 -- Duration of the screen fading to black (ms)
        FadeInDuration = 10000,                  -- Duration of the screen fading back in (ms)

        -- Notifications (Translated to English)
        DrunkNotification = {
            title = '🍺 Drunk',
            description = 'You start feeling tipsy...',
            type = 'inform',
            duration = 3000,
            position = 'top-right'
        },
        PassOutNotification = {
            title = '💀 Feeling Unwell',
            description = 'You don’t feel so good...',
            type = 'error',
            duration = 5000,
            position = 'top-right'
        },
        WakeUpNotification = {
            title = '🤕 Rough Awakening',
            description = 'You wake up with a terrible headache...',
            type = 'inform',
            duration = 5000,
            position = 'top-right'
        },
        SoberNotification = {
            title = '✨ Recovered',
            description = 'You feel clear-headed again.',
            type = 'success',
            duration = 2000,
            position = 'top-right'
        }
    }
}
