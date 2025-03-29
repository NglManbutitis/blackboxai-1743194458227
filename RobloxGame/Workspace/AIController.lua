local AI_TYPES = {
    {
        Name = "Grunt",
        Health = 100,
        Damage = 10,
        Model = "rbxassetid://22345",
        Behavior = "Aggressive"
    },
    {
        Name = "Scout", 
        Health = 75,
        Damage = 15,
        Model = "rbxassetid://22346",
        Behavior = "HitAndRun"
    },
    {
        Name = "Brute",
        Health = 150,
        Damage = 20,
        Model = "rbxassetid://22347",
        Behavior = "SlowPursuit"
    },
    {
        Name = "Sniper",
        Health = 60,
        Damage = 25,
        Model = "rbxassetid://22348",
        Behavior = "Ranged"
    }
}

local function spawnAI(aiType, spawnLocation)
    local aiData = AI_TYPES[aiType]
    local ai = Instance.new("Model")
    ai.Name = aiData.Name
    
    -- Create humanoid and parts
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = aiData.Health
    humanoid.Health = aiData.Health
    humanoid.Parent = ai
    
    -- Add AI behavior
    local behaviorScript = Instance.new("Script")
    behaviorScript.Name = "AIBehavior"
    behaviorScript.Source = [[
        -- AI behavior logic here
        local humanoid = script.Parent:FindFirstChildOfClass("Humanoid")
        local target = game.Players:GetPlayers()[1].Character
        
        while humanoid.Health > 0 do
            if target then
                -- Implement behavior patterns based on type
                -- Aggressive, HitAndRun, etc.
            end
            wait(0.1)
        end
    ]]
    behaviorScript.Parent = ai
    
    ai.Parent = workspace
    ai:SetPrimaryPartCFrame(spawnLocation)
    return ai
end

-- Spawn example AI
spawnAI(1, CFrame.new(0, 0, -20))
spawnAI(2, CFrame.new(10, 0, -20))
spawnAI(3, CFrame.new(-10, 0, -20))
spawnAI(4, CFrame.new(0, 0, -30))