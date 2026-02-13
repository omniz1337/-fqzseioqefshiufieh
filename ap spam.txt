local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ACTION_UUID = "78a772b6-9e1c-4827-ab8b-04a07838f298"
local ActionRemote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/352aad58-c786-4998-886b-3e4fa390721e")

local Wave1Commands = {"rocket", "tiny", "inverse", "morph", "jumpscare"}
local Wave2Commands = {"ragdoll", "jail", "balloon"}

local function fireCommand(target, command)
    if not target or not command then return end
    ActionRemote:FireServer(ACTION_UUID, target, command)
end

local function getNearestPlayer()
    local localPlayer = Players.LocalPlayer
    local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local localRoot = localCharacter:WaitForChild("HumanoidRootPart")
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (localRoot.Position - rootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

while true do
    local targetPlayer = getNearestPlayer()
    
    if targetPlayer then
        for _, cmd in ipairs(Wave1Commands) do
            fireCommand(targetPlayer, cmd)
            task.wait(0.12)
        end
        
        task.wait(3)
        
        for _, cmd in ipairs(Wave2Commands) do
            fireCommand(targetPlayer, cmd)
            task.wait(0.12)
        end
    end
    
    task.wait(5)
end