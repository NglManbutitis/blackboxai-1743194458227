--[[
PRACTICAL EXAMPLE: PLAYER INVENTORY SYSTEM
Demonstrates Lua 5.1 concepts in a complete Roblox system
]]

-- 1. SETUP AND CONFIGURATION
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Inventory items configuration (like PET_TYPES in HatchSystem)
local ITEM_DATABASE = {
    {
        Id = 1,
        Name = "Health Potion",
        Type = "Consumable",
        Model = "rbxassetid://123456",
        Effect = {Type = "Heal", Amount = 25}
    },
    {
        Id = 2,
        Name = "Iron Sword",
        Type = "Weapon",
        Model = "rbxassetid://123457",
        Stats = {Damage = 15, Speed = 1.2}
    },
    {
        Id = 3,
        Name = "Wooden Shield",
        Type = "Armor",
        Model = "rbxassetid://123458",
        Stats = {Defense = 10, Durability = 100}
    }
}

-- 2. CORE SYSTEMS
local InventorySystem = {}
InventorySystem.__index = InventorySystem

function InventorySystem.new(player)
    local self = setmetatable({}, InventorySystem)
    self.Player = player
    self.Items = {}
    return self
end

function InventorySystem:AddItem(itemId, quantity)
    quantity = quantity or 1
    local itemData = self:GetItemData(itemId)
    
    if not itemData then
        warn("Invalid item ID:", itemId)
        return false
    end
    
    -- Check if item already exists in inventory
    for _, invItem in pairs(self.Items) do
        if invItem.Id == itemId then
            invItem.Quantity += quantity
            self:UpdateClient()
            return true
        end
    end
    
    -- Add new item
    table.insert(self.Items, {
        Id = itemId,
        Quantity = quantity
    })
    
    self:UpdateClient()
    return true
end

function InventorySystem:GetItemData(itemId)
    for _, item in pairs(ITEM_DATABASE) do
        if item.Id == itemId then
            return item
        end
    end
    return nil
end

-- 3. NETWORK COMMUNICATION
local InventoryRemote = Instance.new("RemoteEvent")
InventoryRemote.Name = "InventoryRemote"
InventoryRemote.Parent = ReplicatedStorage

function InventorySystem:UpdateClient()
    -- Send compressed inventory data to client
    local compressedData = {}
    for _, item in pairs(self.Items) do
        table.insert(compressedData, {
            i = item.Id,  -- Item ID
            q = item.Quantity  -- Quantity
        })
    end
    
    InventoryRemote:FireClient(self.Player, "Update", compressedData)
end

-- 4. EVENT HANDLERS
local function onPlayerAdded(player)
    local inventory = InventorySystem.new(player)
    
    -- Give starter items
    inventory:AddItem(1, 3)  -- 3 Health Potions
    inventory:AddItem(3, 1)  -- 1 Wooden Shield
    
    -- Handle client requests
    InventoryRemote.OnServerEvent:Connect(function(plr, action, ...)
        if plr ~= player then return end
        
        if action == "UseItem" then
            local itemId = ...
            -- Handle item usage logic
            print(player.Name, "used item", itemId)
        end
    end)
end

-- 5. INITIALIZATION
Players.PlayerAdded:Connect(onPlayerAdded)

-- Initialize existing players
for _, player in pairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

--[[
KEY CONCEPTS DEMONSTRATED:
1. Table configuration (ITEM_DATABASE)
2. Object-oriented pattern (InventorySystem)
3. Event handling (RemoteEvents)
4. Client-server communication
5. Player lifecycle management
6. Data compression for networking
7. Error handling
]]