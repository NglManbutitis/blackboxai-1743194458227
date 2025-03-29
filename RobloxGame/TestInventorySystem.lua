--[[
COMPLETE TEST SCRIPT FOR INVENTORY SYSTEM
Tests all functionality from the practical example
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Import our inventory system
local InventorySystem = require(ServerScriptService:WaitForChild("InventorySystem"))

-- Mock player object for testing
local function createMockPlayer(name, userId)
    return {
        Name = name,
        UserId = userId,
        mockInventory = {}
    }
end

-- Test cases
local function runAllTests()
    print("=== STARTING INVENTORY SYSTEM TESTS ===")
    
    local testPlayer = createMockPlayer("TestPlayer", 999)
    local inventory = InventorySystem.new(testPlayer)
    
    -- Test 1: Adding new items
    inventory:AddItem(1, 3) -- Health Potions
    inventory:AddItem(2, 1) -- Iron Sword
    
    assert(#inventory.Items == 2, "Test 1 Failed: Should have 2 unique items")
    assert(inventory.Items[1].Quantity == 3, "Test 1 Failed: Health Potions quantity mismatch")
    assert(inventory.Items[2].Quantity == 1, "Test 1 Failed: Sword quantity mismatch")
    
    -- Test 2: Adding quantity to existing item
    inventory:AddItem(1, 2) -- More Health Potions
    assert(inventory.Items[1].Quantity == 5, "Test 2 Failed: Quantity should increase to 5")
    
    -- Test 3: Invalid item ID
    local success = inventory:AddItem(99, 1)
    assert(success == false, "Test 3 Failed: Should reject invalid item ID")
    
    -- Test 4: GetItemData validation
    local itemData = inventory:GetItemData(2)
    assert(itemData, "Test 4 Failed: Should find item data")
    assert(itemData.Name == "Iron Sword", "Test 4 Failed: Wrong item data returned")
    
    -- Test 5: Network data compression
    inventory:UpdateClient() -- Shouldn't error with mock player
    
    print("=== ALL TESTS PASSED SUCCESSFULLY ===")
end

-- Run tests with error handling
local success, err = pcall(runAllTests)
if not success then
    warn("TEST FAILURE: "..err)
else
    -- Example of how to use the system in-game
    local examplePlayer = createMockPlayer("ExamplePlayer", 1001)
    local exampleInventory = InventorySystem.new(examplePlayer)
    
    -- Add some example items
    exampleInventory:AddItem(1, 5) -- 5 Health Potions
    exampleInventory:AddItem(3, 2) -- 2 Wooden Shields
    
    print("\nExample inventory created with:")
    for _, item in pairs(exampleInventory.Items) do
        local itemData = exampleInventory:GetItemData(item.Id)
        print("- "..itemData.Name..": "..item.Quantity)
    end
end