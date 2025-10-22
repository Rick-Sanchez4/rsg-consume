local config = require 'config'
---@type boolean
local isBusy = false
---@type number
local alcoholCount = 0
---@type boolean
local effectActive = false

-- =========================================================================================
-- Helper Functions
-- =========================================================================================

---Gets the player's ped.
---@return number
local function getPed()
    return cache.ped or PlayerPedId()
end

---Plays an animation on a ped.
---@param ped number The ped to play the animation on.
---@param dict string The animation dictionary.
---@param anim string The animation name.
---@param flag number|nil The animation flag. (Default: 1)
---@param duration number|nil The duration of the animation. (Default: -1 for infinite)
local function playAnim(ped, dict, anim, flag, duration)
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration or -1, flag or 1, 0, true, false, false)
    RemoveAnimDict(dict)
end

---Applies a post-process effect.
---@param effectName string The name of the effect to apply.
local function applyEffect(effectName)
    if effectName then AnimpostfxPlay(effectName) end
end

---Stops a post-process effect.
---@param effectName string The name of the effect to stop.
local function stopEffect(effectName)
    if effectName then AnimpostfxStop(effectName) end
end

---Sets the ped's drunk level for the wobbly walk style.
---@param ped number The ped to apply the effect to.
---@param level number The drunk effect level (0.0 to 1.0).
local function setDrunkEffect(ped, level)
    Citizen.InvokeNative(0x406CCF555B04FAD3, ped, 1, level)
end

---Creates and attaches a prop to a ped's bone.
---@param ped number The ped to attach the prop to.
---@param propName string The name of the prop model.
---@param boneName string The name of the bone to attach to.
---@param x number X offset.
---@param y number Y offset.
---@param z number Z offset.
---@param rotX number X rotation.
---@param rotY number Y rotation.
---@param rotZ number Z rotation.
---@return number The created prop object.
local function attachProp(ped, propName, boneName, x, y, z, rotX, rotY, rotZ)
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(propName, coords.x, coords.y, coords.z, true, false, false)
    AttachEntityToEntity(
        prop, ped, GetEntityBoneIndexByName(ped, boneName),
        x, y, z, rotX, rotY, rotZ,
        true, true, false, true, 1, true
    )
    return prop
end

---Safely deletes an object, ensuring it exists first.
---@param obj number The object handle to delete.
local function safeDelete(obj)
    if DoesEntityExist(obj) then
        DetachEntity(obj, true, true)
        DeleteObject(obj)
    end
end

-- =========================================================================================
-- Alcohol System
-- =========================================================================================

---Handles the full pass-out sequence for the player.
---@param ped number The player ped.
local function handlePassOut(ped)
    lib.notify(config.AlcoholEffects.PassOutNotification)

    playAnim(ped, 'amb_misc@world_human_vomit@male_a@idle_b', 'idle_f', 31, config.AlcoholEffects.VomitDuration)
    ClearPedTasks(ped)

    playAnim(ped, 'amb_rest@world_human_sleep_ground@arm@male_b@idle_b', 'idle_f', 1, config.AlcoholEffects.SleepDuration)

    applyEffect(config.AlcoholEffects.PassOutEffect)
    DoScreenFadeOut(config.AlcoholEffects.FadeOutDuration)
    Wait(config.AlcoholEffects.FadeOutDuration)

    ClearPedTasks(ped)
    Citizen.InvokeNative(0x58F7DB5BD8FA2288, ped)

    alcoholCount = 0
    applyEffect(config.AlcoholEffects.GroggyEffectName)
    setDrunkEffect(ped, 0.95)

    applyEffect(config.AlcoholEffects.WakeUpEffect)
    DoScreenFadeIn(config.AlcoholEffects.FadeInDuration)
    Wait(config.AlcoholEffects.FadeInDuration)
    stopEffect(config.AlcoholEffects.WakeUpEffect)
    lib.notify(config.AlcoholEffects.WakeUpNotification)

    Wait(config.AlcoholEffects.GroggyDuration)
    stopEffect(config.AlcoholEffects.GroggyEffectName)
    setDrunkEffect(ped, 0.0)

    if effectActive then
        stopEffect(config.AlcoholEffects.DrunkEffectName)
        effectActive = false
    end

    lib.notify(config.AlcoholEffects.SoberNotification)
end

---Applies drunk effects to the ped.
---@param ped number The player ped.
local function handleDrunk(ped)
    setDrunkEffect(ped, 0.95)
    if not effectActive then
        applyEffect(config.AlcoholEffects.DrunkEffectName)
        effectActive = true
        lib.notify(config.AlcoholEffects.DrunkNotification)
    end
end

---Stops drunk effects and makes the ped sober.
---@param ped number The player ped.
local function handleSober(ped)
    setDrunkEffect(ped, 0.0)
    if effectActive then
        stopEffect(config.AlcoholEffects.DrunkEffectName)
        effectActive = false
        lib.notify(config.AlcoholEffects.SoberNotification)
    end
end

CreateThread(function()
    while true do
        local ped = getPed()
        if alcoholCount > 0 then
            Wait(config.AlcoholSystem.DecreaseInterval)
            alcoholCount = math.max(0, alcoholCount - config.AlcoholSystem.DecreaseAmount)

            if alcoholCount > config.AlcoholSystem.PassOutThreshold then
                handlePassOut(ped)
            elseif alcoholCount > config.AlcoholSystem.DrunkThreshold then
                handleDrunk(ped)
            else
                handleSober(ped)
            end
        else
            Wait(2000)
        end
    end
end)

-- =========================================================================================
-- Health Recovery System Variables
-- =========================================================================================

local playerInCombat = false
local lastDamageTime = 0
local lastHealth = 0

-- =========================================================================================
-- Needs System Variables
-- =========================================================================================

local lastHealthDamageTime = 0

-- =========================================================================================
-- Health Recovery System Functions
-- =========================================================================================

local function isPlayerResting()
    local ped = getPed()
    local velocity = GetEntitySpeed(ped)
    return velocity < config.HealthRecoverySystem.RestingSpeedThreshold
end

-- =========================================================================================
-- Needs System Functions
-- =========================================================================================

---Determines the player's current activity level for needs calculation.
---@return string The activity type.
local function getPlayerActivity()
    local ped = getPed()
    local velocity = GetEntitySpeed(ped)
    
    if IsPedSwimming(ped) then
        return "Swimming"
    elseif velocity > 3.0 then
        return "Sprinting"
    elseif velocity > 2.0 then
        return "Running"
    elseif velocity > 0.5 then
        return "Walking"
    else
        return "Idle"
    end
end

---Gets the current hunger and thirst values from player state.
---@return number, number Current hunger and thirst values.
local function getCurrentNeeds()
    local hunger = LocalPlayer.state.hunger or 100
    local thirst = LocalPlayer.state.thirst or 100
    return hunger, thirst
end

---Updates hunger and thirst values and triggers HUD updates.
---@param newHunger number New hunger value.
---@param newThirst number New thirst value.
local function updateNeeds(newHunger, newThirst)
    -- Ensure values stay within bounds
    newHunger = math.max(config.NeedsSystem.MinHunger, math.min(100, newHunger))
    newThirst = math.max(config.NeedsSystem.MinThirst, math.min(100, newThirst))
    
    -- Update player state
    LocalPlayer.state:set('hunger', newHunger, true)
    LocalPlayer.state:set('thirst', newThirst, true)
    
    -- Trigger HUD updates
    TriggerEvent('hud:client:UpdateHunger', newHunger)
    TriggerEvent('hud:client:UpdateThirst', newThirst)
    
    if config.NeedsSystem.Debug then
        print("^3[RSG-CONSUME]^7 Needs updated - Hunger: " .. math.floor(newHunger) .. ", Thirst: " .. math.floor(newThirst))
    end
end

---Shows notifications for low needs.
---@param hunger number Current hunger value.
---@param thirst number Current thirst value.
local function checkNeedsNotifications(hunger, thirst)
    -- Hunger notifications
    if hunger <= config.NeedsSystem.CriticalHungerThreshold then
        lib.notify({
            title = '🍖 Fome Crítica',
            description = 'Você está morrendo de fome! Procure comida imediatamente!',
            type = 'error',
            duration = 5000,
            position = 'top-right'
        })
    elseif hunger <= config.NeedsSystem.LowHungerThreshold then
        lib.notify({
            title = '🍖 Fome',
            description = 'Você está com fome. Procure algo para comer.',
            type = 'warning',
            duration = 3000,
            position = 'top-right'
        })
    end
    
    -- Thirst notifications
    if thirst <= config.NeedsSystem.CriticalThirstThreshold then
        lib.notify({
            title = '💧 Sede Crítica',
            description = 'Você está morrendo de sede! Procure água imediatamente!',
            type = 'error',
            duration = 5000,
            position = 'top-right'
        })
    elseif thirst <= config.NeedsSystem.LowThirstThreshold then
        lib.notify({
            title = '💧 Sede',
            description = 'Você está com sede. Procure algo para beber.',
            type = 'warning',
            duration = 3000,
            position = 'top-right'
        })
    end
end

---Applies health damage when needs are critical.
---@param hunger number Current hunger value.
---@param thirst number Current thirst value.
local function applyHealthDamage(hunger, thirst)
    if not config.NeedsSystem.EnableHealthDamage then return end
    
    local currentTime = GetGameTimer()
    if currentTime - lastHealthDamageTime < config.NeedsSystem.HealthDamageInterval then
        return
    end
    
    local isHungerCritical = hunger <= config.NeedsSystem.CriticalHungerThreshold
    local isThirstCritical = thirst <= config.NeedsSystem.CriticalThirstThreshold
    local isCritical = isHungerCritical or isThirstCritical
    
    if isCritical then
        local ped = getPed()
        local currentHealth = GetEntityHealth(ped)
        local newHealth = math.max(1, currentHealth - config.NeedsSystem.HealthDamageAmount)
        
        SetEntityHealth(ped, newHealth)
        LocalPlayer.state:set('health', newHealth, true)
        lastHealthDamageTime = currentTime
        
        if config.NeedsSystem.Debug then
            local damageReason = ""
            if isHungerCritical and isThirstCritical then
                damageReason = " (Critical hunger AND thirst)"
            elseif isHungerCritical then
                damageReason = " (Critical hunger)"
            elseif isThirstCritical then
                damageReason = " (Critical thirst)"
            end
            print("^1[RSG-CONSUME]^7 Health damage applied: " .. config.NeedsSystem.HealthDamageAmount .. damageReason)
        end
    end
end

local function canRegenerate()
    if not config.HealthRecoverySystem.EnableAutoRecovery then return false end
    if not config.HealthRecoverySystem.CombatDetection.Enabled then return true end
    
    -- Check if in combat
    if playerInCombat then return false end
    
    -- Check if needs are critical (prevent regeneration when starving/dehydrated)
    local hunger, thirst = getCurrentNeeds()
    if hunger <= config.NeedsSystem.CriticalHungerThreshold or 
       thirst <= config.NeedsSystem.CriticalThirstThreshold then
        return false
    end
    
    -- Check damage cooldown
    local currentTime = GetGameTimer()
    local timeSinceDamage = currentTime - lastDamageTime
    
    if timeSinceDamage < config.HealthRecoverySystem.CombatDetection.DamageCooldown then
        return false
    end
    
    return true
end

local function checkForCombat()
    if not config.HealthRecoverySystem.CombatDetection.Enabled then return end
    
    local currentHealth = GetEntityHealth(getPed())
    local currentTime = GetGameTimer()
    
    -- Check if player took damage
    if currentHealth < lastHealth then
        local damage = lastHealth - currentHealth
        
        if damage >= config.HealthRecoverySystem.CombatDetection.MinDamageToTrigger then
            lastDamageTime = currentTime
            
            if not playerInCombat then
                playerInCombat = true
                if config.HealthRecoverySystem.Debug then
                    print("^1[RSG-CONSUME]^7 Entered combat state - Damage: " .. damage)
                end
            end
        end
    end
    
    -- Check if combat should end
    if playerInCombat then
        local timeSinceDamage = currentTime - lastDamageTime
        if timeSinceDamage >= config.HealthRecoverySystem.CombatDetection.CombatTimeout then
            playerInCombat = false
            if config.HealthRecoverySystem.Debug then
                print("^2[RSG-CONSUME]^7 Exited combat state")
            end
        end
    end
    
    lastHealth = currentHealth
end

-- =========================================================================================
-- Health Recovery System Thread
-- =========================================================================================

CreateThread(function()
    while true do
        if config.HealthRecoverySystem.EnableAutoRecovery then
            -- Check for combat first
            checkForCombat()
            
            -- Only regenerate if not in combat and cooldown passed
            if canRegenerate() then
                local ped = getPed()
                local currentHealth = GetEntityHealth(ped)
                local maxHealth = GetEntityMaxHealth(ped)
                local healthPercentage = (currentHealth / maxHealth) * 100
                
                -- Check if player needs health recovery
                if healthPercentage < config.HealthRecoverySystem.MaxRecoveryAmount and 
                   healthPercentage > config.HealthRecoverySystem.MinHealthThreshold then
                    
                    -- Calculate recovery amount
                    local recoveryAmount = config.HealthRecoverySystem.RecoveryRate
                    
                    -- Check if player is resting (not moving much)
                    if config.HealthRecoverySystem.RecoveryWhenResting and isPlayerResting() then
                        recoveryAmount = recoveryAmount * config.HealthRecoverySystem.RestingMultiplier
                    end
                    
                    -- Apply recovery
                    local healthToAdd = math.round(maxHealth * (recoveryAmount / 100))
                    local newHealth = math.min(maxHealth, currentHealth + healthToAdd)
                    
                    if newHealth > currentHealth then
                        SetEntityHealth(ped, newHealth)
                        LocalPlayer.state:set('health', newHealth, true)
                        
                        if config.HealthRecoverySystem.Debug then
                            print("^2[RSG-CONSUME]^7 Regenerated " .. healthToAdd .. " health (" .. 
                                  math.floor(healthPercentage) .. "% -> " .. math.floor((newHealth / maxHealth) * 100) .. "%)")
                        end
                    end
                end
            end
        end
        
        Wait(config.HealthRecoverySystem.RecoveryInterval)
    end
end)

-- =========================================================================================
-- Needs System Thread
-- =========================================================================================

CreateThread(function()
    while true do
        if config.NeedsSystem.EnableAutoDecrease then
            local hunger, thirst = getCurrentNeeds()
            local activity = getPlayerActivity()
            local multiplier = config.NeedsSystem.ActivityMultipliers[activity] or 1.0
            
            -- Calculate decrease amounts based on activity
            local hungerDecrease = config.NeedsSystem.HungerDecreaseRate * multiplier
            local thirstDecrease = config.NeedsSystem.ThirstDecreaseRate * multiplier
            
            -- Apply decreases
            local newHunger = hunger - hungerDecrease
            local newThirst = thirst - thirstDecrease
            
            -- Update needs
            updateNeeds(newHunger, newThirst)
            
            -- Check for notifications
            checkNeedsNotifications(newHunger, newThirst)
            
            -- Apply health damage if critical
            applyHealthDamage(newHunger, newThirst)
            
            if config.NeedsSystem.Debug then
                print("^3[RSG-CONSUME]^7 Activity: " .. activity .. " (x" .. multiplier .. ") - Hunger: " .. 
                      math.floor(newHunger) .. ", Thirst: " .. math.floor(newThirst))
            end
        end
        
        Wait(config.NeedsSystem.DecreaseInterval)
    end
end)

-- =========================================================================================
-- Generic Consumption Handler
-- =========================================================================================

---Handles the full consumption sequence for any item.
---@param itemName string The name of the item being consumed (key in config.Consumables).
---@param type "Eat"|"Drink"|"Stew"|"Hotdrinks"|"Eatcanned" The type of consumable.
local function handleConsumption(itemName, type)
    if isBusy or not config.Consumables[type][itemName] then return end

    local ped = getPed()
    local data = config.Consumables[type][itemName]

    isBusy = true
    LocalPlayer.state:set("inv_busy", true, true)
    SetCurrentPedWeapon(ped, "WEAPON_UNARMED")

    local prop, prop2
    local taskDuration = 4000

    if type == "Eat" then
        prop = attachProp(ped, data.propname, "SKEL_L_Finger01", 0.04, -0.03, -0.01, 0.0, 19.0, 46.0)
        playAnim(ped, "mech_inventory@eating@multi_bite@sphere_d8-2_sandwich", "quick_left_hand", 31, -1)
        taskDuration = 5000

    elseif type == "Drink" then
        prop = attachProp(ped, data.propname, "PH_R_HAND", 0.0, 0.0, 0.04, 0.0, 0.0, 0.0)
        if not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped) then
            playAnim(ped, "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5", "uncork", 31, 500)
            playAnim(ped, "mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5", "chug_a", 31, -1)
            taskDuration = 5000
        else
            TaskItemInteraction_2(ped, 1737033966, prop, "p_bottleJD01x_ph_r_hand", "DRINK_Bottle_Cylinder_d1-55_H18_Neck_A8_B1-8_QUICK_RIGHT_HAND", true, 0, 0)
            taskDuration = 4000
        end

    elseif type == "Stew" then
        prop = CreateObject("p_bowl04x_stew", GetEntityCoords(ped), true, true, false, false, true)
        prop2 = CreateObject("p_spoon01x", GetEntityCoords(ped), true, true, false, false, true)
        Citizen.InvokeNative(0x669655FFB29EF1A9, prop, 0, "Stew_Fill", 1.0)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, prop, 20)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, prop2, 82)
        TaskItemInteraction_2(ped, 599184882, prop, "p_bowl04x_stew_ph_l_hand", -583731576, 1, 0, 0.0)
        TaskItemInteraction_2(ped, 599184882, prop2, "p_spoon01x_ph_r_hand", -583731576, 1, 0, 0.0)
        Citizen.InvokeNative(0xB35370D5353995CB, ped, -583731576, 1.0)
        taskDuration = 5000

    elseif type == "Hotdrinks" then
        prop = CreateObject("P_MUGCOFFEE01X", GetEntityCoords(ped), true, true, false, false, true)
        Citizen.InvokeNative(0x669655FFB29EF1A9, prop, 0, "CTRL_cupFill", 1.0)
        TaskItemInteraction_2(ped, "CONSUMABLE_COFFEE", prop, "P_MUGCOFFEE01X_PH_R_HAND", "DRINK_COFFEE_HOLD", 1, 0, -1)
        taskDuration = 5000

    elseif type == "Eatcanned" then
        prop = attachProp(ped, data.propname, "SKEL_L_Finger00", 0.10, -0.03, 0.02, 20.0, -70.0, -20.0)
        if not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped) and not IsPedUsingAnyScenario(ped) then
            playAnim(ped, "mech_inventory@eating@canned_food@cylinder@d8-2_h10-5", "left_hand", 31, -1)
            taskDuration = 2750
        else
            TaskItemInteraction(ped, nil, "EAT_CANNED_FOOD_CYLINDER@D8-2_H10-5_QUICK_LEFT", true, 0, 0)
            taskDuration = 2750
        end
    end

    Wait(taskDuration)
    ClearPedTasks(ped)
    safeDelete(prop)
    safeDelete(prop2)

    if data.alcohol then
        if data.alcohol > 0 then
            alcoholCount = math.min(config.AlcoholSystem.MaxAlcoholLevel, alcoholCount + data.alcohol)
        else
            alcoholCount = math.max(0, alcoholCount + data.alcohol)
        end
    end
    TriggerServerEvent('rsg-consume:server:removeitem', data.item, 1)
    if data.hunger and data.hunger ~= 0 then
        local currentHunger = LocalPlayer.state.hunger or 100
        local newHunger = currentHunger + data.hunger
        newHunger = math.min(100, newHunger)
        LocalPlayer.state:set('hunger', newHunger, true)
        TriggerEvent('hud:client:UpdateHunger', newHunger)
    end
    if data.thirst and data.thirst ~= 0 then
        local currentThirst = LocalPlayer.state.thirst or 100
        local newThirst = currentThirst + data.thirst
        newThirst = math.min(100, newThirst)
        LocalPlayer.state:set('thirst', newThirst, true)
        TriggerEvent('hud:client:UpdateThirst', newThirst)
    end
    if data.stress and data.stress ~= 0 then
        if data.stress > 0 then
            TriggerEvent('hud:client:RelieveStress', data.stress)
        else
            TriggerEvent('hud:server:GainStress', math.abs(data.stress))
        end
    end
    if data.health and data.health > 0 then
        TriggerEvent('rsg-consume:client:healPlayer', data.health)
    end
    TriggerEvent('rsg-consume:client:onConsume', data)
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
end

-- =========================================================================================
-- Event bindings
-- =========================================================================================

---Consumes a food item.
---@param itemName string The name of the food item.
RegisterNetEvent('rsg-consume:client:eat', function(itemName)
    handleConsumption(itemName, "Eat")
end)

---Consumes a drink item.
---@param itemName string The name of the drink item.
RegisterNetEvent('rsg-consume:client:drink', function(itemName)
    handleConsumption(itemName, "Drink")
end)

---Consumes a stew.
---@param itemName string The name of the stew item.
RegisterNetEvent('rsg-consume:client:stew', function(itemName)
    handleConsumption(itemName, "Stew")
end)

---Consumes a hot drink (e.g., coffee).
---@param itemName string The name of the hot drink item.
RegisterNetEvent('rsg-consume:client:drinkcoffee', function(itemName)
    handleConsumption(itemName, "Hotdrinks")
end)

---Consumes a canned food item.
---@param itemName string The name of the canned food item.
RegisterNetEvent('rsg-consume:client:eatcanned', function(itemName)
    handleConsumption(itemName, "Eatcanned")
end)

-- =========================================================================================
-- Health Recovery System
-- =========================================================================================

---Heals the player by the specified amount.
---@param healAmount number The amount of health to restore.
RegisterNetEvent('rsg-consume:client:healPlayer', function(healAmount)
    local ped = getPed()
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    
    -- Calculate new health (healAmount is percentage of max health)
    local healthToAdd = math.round(maxHealth * (healAmount / 100))
    local newHealth = math.min(maxHealth, currentHealth + healthToAdd)
    
    -- Apply healing
    SetEntityHealth(ped, newHealth)
    
    -- Update player state for HUD
    LocalPlayer.state:set('health', newHealth, true)
    
    -- Show notification
    lib.notify({
        title = '💚 Cura Aplicada',
        description = string.format('Você recuperou %d%% da sua vida!', healAmount),
        type = 'success',
        duration = 3000,
        position = 'top-right'
    })
end)

-- =========================================================================================
-- Commands and Integration
-- =========================================================================================

-- Command to check health regeneration status
RegisterCommand('healthstatus', function()
    local ped = getPed()
    local currentHealth = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    local healthPercentage = (currentHealth / maxHealth) * 100
    local combat = playerInCombat and "Sim" or "Não"
    local canRegen = canRegenerate() and "Sim" or "Não"
    
    print("^2=== STATUS DE REGENERAÇÃO DE VIDA ===")
    print("^7Vida Atual: ^2" .. math.floor(healthPercentage) .. "%")
    print("^7Em Combate: ^3" .. combat)
    print("^7Pode Regenerar: ^3" .. canRegen)
    print("^7Sistema Ativo: ^3" .. (config.HealthRecoverySystem.EnableAutoRecovery and "Sim" or "Não"))
    print("^7Detecção de Combate: ^3" .. (config.HealthRecoverySystem.CombatDetection.Enabled and "Sim" or "Não"))
    print("^2=====================================")
end, false)

-- Command to toggle debug mode
RegisterCommand('healthdebug', function()
    config.HealthRecoverySystem.Debug = not config.HealthRecoverySystem.Debug
    local status = config.HealthRecoverySystem.Debug and "ativado" or "desativado"
    print("^3[RSG-CONSUME]^7 Debug de regeneração " .. status)
end, false)

-- Command to check needs status
RegisterCommand('needsstatus', function()
    local hunger, thirst = getCurrentNeeds()
    local activity = getPlayerActivity()
    local multiplier = config.NeedsSystem.ActivityMultipliers[activity] or 1.0
    
    print("^2=== STATUS DE NECESSIDADES ===")
    print("^7Fome: ^3" .. math.floor(hunger) .. "%")
    print("^7Sede: ^3" .. math.floor(thirst) .. "%")
    print("^7Atividade: ^3" .. activity .. " (x" .. multiplier .. ")")
    print("^7Sistema Ativo: ^3" .. (config.NeedsSystem.EnableAutoDecrease and "Sim" or "Não"))
    print("^7Dano por Necessidades: ^3" .. (config.NeedsSystem.EnableHealthDamage and "Sim" or "Não"))
    print("^2=============================")
end, false)

-- Command to toggle needs debug mode
RegisterCommand('needsdebug', function()
    config.NeedsSystem.Debug = not config.NeedsSystem.Debug
    local status = config.NeedsSystem.Debug and "ativado" or "desativado"
    print("^3[RSG-CONSUME]^7 Debug de necessidades " .. status)
end, false)

-- Command to set hunger and thirst (admin only)
RegisterCommand('setneeds', function(source, args)
    if #args < 2 then
        print("^1[RSG-CONSUME]^7 Uso: /setneeds <fome> <sede>")
        return
    end
    
    local hunger = tonumber(args[1])
    local thirst = tonumber(args[2])
    
    if not hunger or not thirst then
        print("^1[RSG-CONSUME]^7 Valores inválidos. Use números entre 0 e 100.")
        return
    end
    
    updateNeeds(hunger, thirst)
    print("^2[RSG-CONSUME]^7 Necessidades definidas - Fome: " .. hunger .. ", Sede: " .. thirst)
end, false)

-- Integration with rex_zombies infection system
RegisterNetEvent('rex_zombies:client:infectionStarted', function()
    -- Disable regeneration during infection
    if config.HealthRecoverySystem.Debug then
        print("^1[RSG-CONSUME]^7 Infecção detectada - regeneração pausada")
    end
end)

RegisterNetEvent('rex_zombies:client:cureInfection', function()
    -- Re-enable regeneration after cure
    if config.HealthRecoverySystem.Debug then
        print("^2[RSG-CONSUME]^7 Infecção curada - regeneração reativada")
    end
end)

-- Integration with rsg-medic system
RegisterNetEvent('rsg-medic:client:healPlayer', function(healAmount)
    -- Reset combat state when healed by medic
    playerInCombat = false
    lastDamageTime = 0
    if config.HealthRecoverySystem.Debug then
        print("^2[RSG-CONSUME]^7 Curado por médico - estado de combate resetado")
    end
end)
