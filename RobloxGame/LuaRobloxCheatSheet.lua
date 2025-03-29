--[[
ROBLOX LUA 5.1 CHEAT SHEET
====================================
1. QUICK REFERENCE
]]

-- Variables
local x = 10          -- Number
local s = "Hello"     -- String
local b = true        -- Boolean
local t = {}          -- Table
local n = nil         -- Nil value

-- Table examples
local array = {1, 2, 3}                   -- Array-like
local dict = {key1 = "A", key2 = "B"}     -- Dictionary-like
local mixed = {1, "two", key3 = false}    -- Mixed

-- Basic operations
print("Concatenation: "..s..x)  -- String concatenation
print("Table access:", array[1], dict.key1)
print("Length:", #array)        -- Array length

--[[
2. ROBLOX ESSENTIALS
]]

-- Core Services
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local WS = game:GetService("Workspace")
local PS = game:GetService("Players")

-- Instance Management
local part = Instance.new("Part")
part.Name = "MyPart"
part.Size = Vector3.new(4, 2, 4)
part.Parent = WS

-- Finding objects
local player = PS.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

--[[
3. EVENT PATTERNS
]]

-- Remote Events (Client-Server)
local remEvent = Instance.new("RemoteEvent")
remEvent.Name = "MyEvent"
remEvent.Parent = RS

-- Server-side
remEvent.OnServerEvent:Connect(function(player, ...)
    print("Server received from", player.Name)
end)

-- Client-side
remEvent:FireServer(data)  -- Send to server
remEvent.OnClientEvent:Connect(function(...)
    print("Client received data")
end)

-- Built-in events
character.Humanoid.Died:Connect(function()
    print("Player died!")
end)

--[[
4. USEFUL SNIPPETS
]]

-- Wait for child with timeout
local function waitForChildWithTimeout(parent, childName, timeout)
    local child = parent:FindFirstChild(childName)
    local elapsed = 0
    
    while not child and elapsed < timeout do
        elapsed += wait(0.1)
        child = parent:FindFirstChild(childName)
    end
    
    return child
end

-- Table deep copy
local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = deepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

--[[
5. DEBUGGING TIPS
]]

-- Printing tables
local function printTable(t, indent)
    indent = indent or 0
    for k, v in pairs(t) do
        print(string.rep(" ", indent)..tostring(k)..": "..tostring(v))
        if type(v) == "table" then
            printTable(v, indent + 2)
        end
    end
end

-- Safe function calls
local success, result = pcall(function()
    -- Potentially error-prone code
end)

if not success then
    warn("Error:", result)
end