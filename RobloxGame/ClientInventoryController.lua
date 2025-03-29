-- CLIENT-SIDE INVENTORY CONTROLLER
-- Goes in StarterPlayerScripts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local InventoryRemote = ReplicatedStorage:WaitForChild("InventoryRemote")
local InventoryUI = script.Parent:WaitForChild("InventoryGUI")

-- Inventory state
local inventory = {}

-- Update UI function
local function updateUI()
    for _, itemFrame in pairs(InventoryUI.Items:GetChildren()) do
        if itemFrame:IsA("Frame") then
            itemFrame:Destroy()
        end
    end

    for _, item in pairs(inventory) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "Item_"..item.i
        itemFrame.Size = UDim2.new(0, 100, 0, 120)
        -- ... UI setup code ...
    end
end

-- Handle server updates
InventoryRemote.OnClientEvent:Connect(function(action, data)
    if action == "Update" then
        inventory = {}
        for _, item in pairs(data) do
            table.insert(inventory, {
                i = item.i,
                q = item.q
            })
        end
        updateUI()
    end
end)

-- UI interaction
local function onItemClicked(itemId)
    InventoryRemote:FireServer("UseItem", itemId)
end