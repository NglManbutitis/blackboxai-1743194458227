--[[
ROBLOX LUA 5.1 TUTORIAL
====================================
1. BASIC LUA SYNTAX
]]

-- Variables (always use 'local' for scope control)
local playerName = "Player1"  -- String
local health = 100            -- Number
local isAlive = true          -- Boolean

-- Tables (Lua's only data structure)
local player = {
    Name = "Player1",
    Level = 5,
    Inventory = {"Sword", "Shield", "HealthPotion"}  -- Array-like table
}

-- Control flow
if health > 75 then
    print("Health is high")
elseif health > 25 then
    print("Health is medium")
else
    print("Health is critical!")
end

-- Loops
for i = 1, 5 do  -- Numeric for
    print("Count: "..i)  -- String concatenation with ..
end

for key, value in pairs(player) do  -- Generic for
    print(key..": "..tostring(value))
end

--[[
2. ROBLOX-SPECIFIC FEATURES
]]

-- Getting services (like in HatchSystem.lua)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Creating instances
local part = Instance.new("Part")
part.Size = Vector3.new(4, 1, 4)
part.Anchored = true
part.Parent = workspace  -- Adds to game world

-- Remote events (client-server communication)
local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "PlayerHurt"
remoteEvent.Parent = ReplicatedStorage

--[[
3. COMMON ROBLOX PATTERNS
]]

-- Configuration tables (like PET_TYPES in HatchSystem)
local WEAPONS = {
    {
        Name = "Sword",
        Damage = 15,
        Range = 5,
        ModelId = "rbxassetid://12345"
    },
    {
        Name = "Bow",
        Damage = 10,
        Range = 20,
        ModelId = "rbxassetid://12346"
    }
}

-- Event handling
local function onPlayerAdded(player)
    print(player.Name.." joined the game")
    
    -- Give starter items
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            print(player.Name.." died")
        end)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Random selection (like in HatchSystem)
local function getRandomWeapon()
    local index = math.random(1, #WEAPONS)
    return WEAPONS[index]
end

--[[
4. BEST PRACTICES
]]

-- Always use local variables
-- Use descriptive names for events and functions
-- Organize code with comments and sections
-- Put configuration data in tables at the top
-- Handle errors with pcall() for critical operations

-- Example error handling
local success, err = pcall(function()
    -- Risky code here
    local nonExistent = workspace.NonExistentPart.Value
end)

if not success then
    warn("Error occurred: "..err)
end

--[[
5. ADVANCED CONCEPTS
]]

-- Metatables for OOP
local Weapon = {}
Weapon.__index = Weapon

function Weapon.new(name, damage)
    local self = setmetatable({}, Weapon)
    self.Name = name
    self.Damage = damage
    return self
end

function Weapon:Attack(target)
    print(self.Name.." attacks "..target.." for "..self.Damage.." damage")
end

local sword = Weapon.new("Sword", 15)
sword:Attack("Zombie")

-- ModuleScripts for code organization
-- (Create separate ModuleScripts for different systems)