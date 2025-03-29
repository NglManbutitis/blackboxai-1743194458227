# Roblox Lua 5.1 Learning Package

This package provides complete resources for learning Lua 5.1 in Roblox, including:
- Core language tutorial
- Quick-reference cheat sheet
- Practical inventory system example
- Client-server implementation
- Test suite

## File Structure

| File | Purpose |
|------|---------|
| `LuaRobloxTutorial.lua` | Core language tutorial |
| `LuaRobloxCheatSheet.lua` | Quick syntax reference |
| `PracticalExample_PlayerInventorySystem.lua` | Server-side inventory system |
| `ClientInventoryController.lua` | Client-side inventory UI controller |
| `TestInventorySystem.lua` | Test cases for inventory system |

## Implementation Guide

### 1. Setting Up the Inventory System

1. **Server Setup**:
```lua
-- In ServerScriptService
local InventorySystem = require(script.InventorySystem)
local Players = game:GetService("Players")

local function onPlayerAdded(player)
    local inventory = InventorySystem.new(player)
    inventory:AddItem(1, 3) -- Give 3 health potions
    inventory:AddItem(2, 1) -- Give 1 sword
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

2. **Client Setup**:
```lua
-- In StarterPlayerScripts
local InventoryController = require(script.Parent.ClientInventoryController)
```

### 2. Key Concepts Demonstrated

#### Configuration Tables
```lua
-- Similar to HatchSystem's PET_TYPES
local ITEM_DATABASE = {
    {
        Id = 1,
        Name = "Health Potion",
        Type = "Consumable",
        Model = "rbxassetid://123456"
    }
}
```

#### Object-Oriented Patterns
```lua
local InventorySystem = {}
InventorySystem.__index = InventorySystem

function InventorySystem.new(player)
    local self = setmetatable({}, InventorySystem)
    self.Player = player
    self.Items = {}
    return self
end
```

#### Remote Events
```lua
-- Server-side
InventoryRemote.OnServerEvent:Connect(function(player, ...)
    -- Handle client requests
end)

-- Client-side
InventoryRemote:FireServer("UseItem", itemId)
```

### 3. Testing the System

Run the test suite:
```lua
require(ServerScriptService.TestInventorySystem)
```

Expected output:
```
=== STARTING INVENTORY SYSTEM TESTS ===
=== ALL TESTS PASSED SUCCESSFULLY ===
```

## Best Practices

1. **Use Local Variables**:
   ```lua
   local player = Players.LocalPlayer
   ```

2. **Organize Code**:
   - Keep configuration tables at the top
   - Group related functions together
   - Use comments for sections

3. **Error Handling**:
   ```lua
   local success, err = pcall(function()
       -- Risky code
   end)
   ```

4. **Performance Tips**:
   - Cache frequently accessed services
   - Use table.create for large arrays
   - Avoid expensive operations in loops

## Next Steps

1. Implement additional item types
2. Add inventory persistence using DataStores
3. Create visual UI for the inventory
4. Expand test coverage