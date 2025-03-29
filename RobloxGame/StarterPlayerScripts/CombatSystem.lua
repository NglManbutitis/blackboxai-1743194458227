local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Combat variables
local shieldActive = false
local maxShield = 0.5 -- 50% of health
local shieldDuration = 5
local cooldown = 10

local function activateShield()
    if not shieldActive then
        shieldActive = true
        local originalHealth = humanoid.MaxHealth
        humanoid.MaxHealth = humanoid.MaxHealth * (1 + maxShield)
        humanoid.Health = humanoid.Health * (1 + maxShield)
        
        -- Visual shield effect
        local shield = Instance.new("Part")
        shield.Name = "ShieldEffect"
        shield.Size = Vector3.new(4, 4, 4)
        shield.Transparency = 0.7
        shield.Color = Color3.fromRGB(0, 100, 255)
        shield.Shape = Enum.PartType.Ball
        shield.CanCollide = false
        shield.Anchored = false
        shield.Parent = character
        
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = character:FindFirstChild("HumanoidRootPart")
        weld.Part1 = shield
        weld.Parent = shield
        
        task.delay(shieldDuration, function()
            shieldActive = false
            shield:Destroy()
            humanoid.MaxHealth = originalHealth
            humanoid.Health = math.min(humanoid.Health, originalHealth)
            
            -- Cooldown before next use
            task.delay(cooldown - shieldDuration, function()
                -- Ready to use again
            end)
        end)
    end
end

-- Sword attack function
local function swordAttack()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        -- Play animation
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://12345678" -- Replace with actual sword swing animation ID
            local track = animator:LoadAnimation(animation)
            track:Play()
        end
        
        -- Damage logic
        -- ...
    end
end

-- Input bindings
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Q then
        activateShield()
    elseif input.KeyCode == Enum.KeyCode.E then
        swordAttack()
    end
end)