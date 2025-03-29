local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local hatchEvent = Instance.new("RemoteEvent")
hatchEvent.Name = "HatchEgg"
hatchEvent.Parent = ReplicatedStorage

local PET_TYPES = {
    {Name = "Warrior", Model = "rbxassetid://12345", Stats = {Attack = 10, Defense = 5}},
    {Name = "Mage", Model = "rbxassetid://12346", Stats = {Attack = 8, Defense = 3}},
    {Name = "Archer", Model = "rbxassetid://12347", Stats = {Attack = 7, Defense = 4}},
    {Name = "Tank", Model = "rbxassetid://12348", Stats = {Attack = 5, Defense = 10}}
}

local function onHatchRequest(player)
    local randomType = PET_TYPES[math.random(1, #PET_TYPES)]
    
    -- Create pet instance and assign to player
    local pet = Instance.new("Model")
    -- Configure pet properties...
    
    return randomType.Name
end

hatchEvent.OnServerEvent:Connect(onHatchRequest)