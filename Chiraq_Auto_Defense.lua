task.spawn(function()
    local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end
task.wait(0.5)

-- hi
local function findRemoteExact()
    local Packages = ReplicatedStorage:WaitForChild("Packages", 5)
    if Packages then
        local Net = Packages:WaitForChild("Net", 5)
        if Net then
            local remote = Net:FindFirstChild("RE/352aad5B-c786-4998-886b-3e4fa390721e")
            if remote and remote:IsA("RemoteEvent") then return remote end
            for _, obj in pairs(Net:GetChildren()) do
                if obj:IsA("RemoteEvent") and obj.Name:lower() == "re/352aad5b-c786-4998-886b-3e4fa390721e" then
                    return obj
                end
            end
        end
    end
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("352aad5") then
            return obj
        end
    end
    return nil
end

local NetRemote
local remoteReady = false

task.spawn(function()
    local maxWait = 10
    local elapsed = 0
    
    while elapsed < maxWait and not remoteReady do
        NetRemote = findRemoteExact()
        
        if NetRemote and NetRemote:IsA("RemoteEvent") then
            remoteReady = true
            warn("✅ Admin remote found!")
            break
        end
        
        elapsed = elapsed + 0.1
        task.wait(0.1)
    end
    
    if not remoteReady then
        warn("❌ Admin remote not found after " .. maxWait .. " seconds")
    end
end)

-- Anti-TP Scam detection variables
local antiTPScamEnabled = false
local antiTPLastDefenseTime = 0
local antiTPCooldown = 3
local antiTPDistanceThreshold = 15 -- Distance in studs to trigger anti-TP

-- My plot information
local myPlot = nil
local myPlotAnimalPodiums = {}
local myDisplayName = localPlayer.DisplayName

-- Function to find my plot by scanning all plots for my display name
local function findMyPlot()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then
        warn("❌ Plots folder not found in Workspace!")
        return nil
    end
    
    for _, plot in pairs(plotsFolder:GetChildren()) do
        local plotSign = plot:FindFirstChild("PlotSign")
        if plotSign then
            local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
            if surfaceGui then
                local frame = surfaceGui:FindFirstChild("Frame")
                if frame then
                    local textLabel = frame:FindFirstChild("TextLabel")
                    if textLabel and textLabel:IsA("TextLabel") then
                        local plotText = textLabel.Text
                        -- Check if this plot belongs to me (contains my display name)
                        if plotText:find(myDisplayName) and plotText:find("'s Base") then
                            return plot
                        end
                    end
                end
            end
        end
    end
    
    warn("❌ Could not find plot belonging to: " .. myDisplayName)
    return nil
end

-- Function to get AnimalPodiums positions from my plot
local function getMyPlotAnimalPodiums(plot)
    local podiumPositions = {}
    
    local animalPodiumsFolder = plot:FindFirstChild("AnimalPodiums")
    if not animalPodiumsFolder then
        warn("❌ AnimalPodiums folder not found in plot: " .. plot.Name)
        return podiumPositions
    end
    
    -- Look for Models named 1 through 10
    for i = 1, 10 do
        local podium = animalPodiumsFolder:FindFirstChild(tostring(i))
        if podium and podium:IsA("Model") then
            -- Get the position of the Model itself
            podiumPositions[i] = podium:GetPivot().Position
        end
    end
    
    local count = 0
    for _ in pairs(podiumPositions) do count = count + 1 end
    
    if count == 0 then
        warn("⚠️ No AnimalPodiums found in plot: " .. plot.Name)
    else
    
    end
    
    return podiumPositions
end

-- Stealing detection variables
local stealRemote
local stealingDetected = false

-- Auto-Defense variables
local autoDefenseEnabled = false
local lastDefenseTime = 0
local defenseCooldown = 3

-- Player selection variables
local selectedPlayers = {}
local selectedSet = {}
local selectedUserIds = {}

-- Function to get player's head
local function getPlayerHead(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("Head")
end

-- Function to get player's HumanoidRootPart
local function getPlayerRootPart(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

-- Function to find closest player to position
local function findClosestPlayerToPosition(position)
    local closestPlayer
    local closestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local head = getPlayerHead(plr)
            if head then
                local dist = (head.Position - position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = plr
                end
            end
        end
    end

    return closestPlayer
end

-- Setup stealing detection
task.spawn(function()
    local function locateStealRemote()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then return nil end
        
        local net = packages:FindFirstChild("Net")
        if not net then return nil end
        
        return net:FindFirstChild("RE/NotificationService/Notify")
    end
    
    local maxAttempts = 10
    for i = 1, maxAttempts do
        stealRemote = locateStealRemote()
        if stealRemote then
            break
        end
        task.wait(0.5)
    end
    
    if stealRemote then
        stealRemote.OnClientEvent:Connect(function(msg)
            if typeof(msg) ~= "string" then return end
            if not msg:find("Someone is stealing your") then return end

            local myChar = localPlayer.Character
            if not myChar then return end

            local myHead = myChar:FindFirstChild("Head")
            if not myHead then return end

            local stealer = findClosestPlayerToPosition(myHead.Position)
            if stealer then
                print("STEALER DETECTED:", stealer.Name, stealer.DisplayName)
                stealingDetected = true
            end
        end)
    end
end)

-- Find and setup my plot at startup
task.spawn(function()
    task.wait(2) -- Wait a bit for game to load
    myPlot = findMyPlot()
    if myPlot then
        myPlotAnimalPodiums = getMyPlotAnimalPodiums(myPlot)
        
    else
        
    end
end)

-- Anti-TP Scam monitoring
task.spawn(function()
    while true do
        if antiTPScamEnabled and remoteReady and myPlot and #myPlotAnimalPodiums > 0 then
            -- Check all players
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= localPlayer and plr.Character then
                    local targetRoot = getPlayerRootPart(plr)
                    if targetRoot then
                        local playerPos = targetRoot.Position
                        
                        -- Check distance to each AnimalPodium in my plot
                        for podiumNumber, podiumPos in pairs(myPlotAnimalPodiums) do
                            local distance = (playerPos - podiumPos).Magnitude
                            if distance < antiTPDistanceThreshold then
                                if (tick() - antiTPLastDefenseTime) > antiTPCooldown then
                                    
                                    -- Execute commands on the player who got too close
                                    for _, cmd in ipairs({"balloon", "inverse", "rocket", "tiny"}) do
                                        NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", plr, cmd)
                                        task.wait(0.05)
                                    end
                                    
                                    antiTPLastDefenseTime = tick()
                                    break -- Only target one player at a time
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Auto-Defense monitoring
task.spawn(function()
    while true do
        if autoDefenseEnabled and #selectedPlayers > 0 and stealingDetected and remoteReady then
            stealingDetected = false
            
            if (tick() - lastDefenseTime) > defenseCooldown then
                local validPlayers = {}
                for _, plr in ipairs(selectedPlayers) do
                    if plr and plr.Parent == Players then
                        table.insert(validPlayers, plr)
                    end
                end
                
                if #validPlayers > 0 then
                    if #validPlayers == 1 then
                        for _, cmd in ipairs({"balloon", "inverse", "rocket", "tiny"}) do
                            NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", validPlayers[1], cmd)
                        end
                        print("🛡️ Auto-Defense: Protected from " .. validPlayers[1].Name)
                    elseif #validPlayers >= 2 then
                        local p1, p2 = validPlayers[1], validPlayers[2]
                        
                        for _, cmd in ipairs({"balloon", "inverse", "rocket", "tiny"}) do
                            NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", p1, cmd)
                            task.wait(0.05)
                        end
                        
                        for _, cmd in ipairs({"ragdoll", "jail", "jumpscare", "morph"}) do
                            NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", p2, cmd)
                            task.wait(0.05)
                        end
                        
                        print("🛡️ Auto-Defense: Protected from " .. p1.Name .. " and " .. p2.Name)
                    end
                    
                    lastDefenseTime = tick()
                end
            end
        end
        
        task.wait(0.05)
    end
end)

-- UI Creation
local activeGradients = {}
local function registerGradient(gradient)
    table.insert(activeGradients, gradient)
end

local animationAngle = 0
RunService.Heartbeat:Connect(function(dt)
    animationAngle = (animationAngle + (dt * 180)) % 360
    for i = #activeGradients, 1, -1 do
        local grad = activeGradients[i]
        if grad and grad.Parent then
            grad.Rotation = animationAngle
        else
            table.remove(activeGradients, i)
        end
    end
end)

local function addAnimatedStroke(frame, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Name = "AnimatedStroke"
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 3
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Parent = stroke
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    })
    
    registerGradient(gradient)
    return stroke
end

-- Create GUI
local playerGui = localPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminCardGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Card
local outer = Instance.new("Frame")
outer.Name = "Outer"
outer.Size = UDim2.new(0, 240, 0, 270) -- Increased height for new toggle
outer.Position = UDim2.new(1, -260, 0, 80)
outer.BackgroundTransparency = 1
outer.Parent = screenGui

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(0, 12)
outerCorner.Parent = outer

local card = Instance.new("Frame")
card.Name = "Card"
card.Size = UDim2.new(1, -12, 1, -12)
card.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
card.BackgroundTransparency = 0.1
card.BorderSizePixel = 0
card.Parent = outer

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

local cardStroke = addAnimatedStroke(card, 3)

-- Top Section
local topLeftAccent = Instance.new("Frame")
topLeftAccent.Name = "TopLeftAccent"
topLeftAccent.Size = UDim2.new(1, 0, 0, 60)
topLeftAccent.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
topLeftAccent.BackgroundTransparency = 0.1
topLeftAccent.BorderSizePixel = 0
topLeftAccent.Parent = card

local topLeftAccentCorner = Instance.new("UICorner")
topLeftAccentCorner.CornerRadius = UDim.new(0, 12)
topLeftAccentCorner.Parent = topLeftAccent

local titleStroke = addAnimatedStroke(topLeftAccent, 2)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = topLeftAccent
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 18, 0, 8)
title.Size = UDim2.new(1, -36, 0, 26)
title.Text = "chiraq Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Parent = topLeftAccent
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.new(0, 18, 0, 30)
subtitle.Size = UDim2.new(1, -36, 0, 18)
subtitle.Text = "Select players below"
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextColor3 = Color3.fromRGB(160, 160, 160)
subtitle.TextXAlignment = Enum.TextXAlignment.Left

-- Plot status label
local plotStatus = Instance.new("TextLabel")
plotStatus.Name = "PlotStatus"
plotStatus.Parent = topLeftAccent
plotStatus.BackgroundTransparency = 1
plotStatus.Position = UDim2.new(0, 18, 0, 48)
plotStatus.Size = UDim2.new(1, -36, 0, 8)
plotStatus.Text = ""
plotStatus.Font = Enum.Font.Gotham
plotStatus.TextSize = 9
plotStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
plotStatus.TextXAlignment = Enum.TextXAlignment.Left

-- Auto-Defense Toggle
local toggleFrame = Instance.new("Frame")
toggleFrame.Name = "ToggleFrame"
toggleFrame.Size = UDim2.new(1, -24, 0, 32)
toggleFrame.Position = UDim2.new(0, 12, 0, 72)
toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
toggleFrame.BackgroundTransparency = 0.1
toggleFrame.BorderSizePixel = 0
toggleFrame.Parent = card

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleFrame

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Name = "ToggleLabel"
toggleLabel.Parent = toggleFrame
toggleLabel.BackgroundTransparency = 1
toggleLabel.Position = UDim2.new(0, 12, 0, 0)
toggleLabel.Size = UDim2.new(1, -60, 1, 0)
toggleLabel.Text = "Auto-Defense"
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.TextSize = 13
toggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = toggleFrame
toggleButton.Size = UDim2.new(0, 50, 0, 24)
toggleButton.Position = UDim2.new(1, -58, 0.5, -12)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
toggleButton.Text = ""
toggleButton.BorderSizePixel = 0

local toggleBtnCorner = Instance.new("UICorner")
toggleBtnCorner.CornerRadius = UDim.new(0, 12)
toggleBtnCorner.Parent = toggleButton

local toggleIndicator = Instance.new("Frame")
toggleIndicator.Name = "Indicator"
toggleIndicator.Parent = toggleButton
toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
toggleIndicator.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
toggleIndicator.BorderSizePixel = 0

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 10)
indicatorCorner.Parent = toggleIndicator

-- Anti-TP Scam Toggle
local antiTPToggleFrame = Instance.new("Frame")
antiTPToggleFrame.Name = "AntiTPToggleFrame"
antiTPToggleFrame.Size = UDim2.new(1, -24, 0, 32)
antiTPToggleFrame.Position = UDim2.new(0, 12, 0, 114)
antiTPToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
antiTPToggleFrame.BackgroundTransparency = 0.1
antiTPToggleFrame.BorderSizePixel = 0
antiTPToggleFrame.Parent = card

local antiTPToggleCorner = Instance.new("UICorner")
antiTPToggleCorner.CornerRadius = UDim.new(0, 8)
antiTPToggleCorner.Parent = antiTPToggleFrame

local antiTPToggleLabel = Instance.new("TextLabel")
antiTPToggleLabel.Name = "AntiTPToggleLabel"
antiTPToggleLabel.Parent = antiTPToggleFrame
antiTPToggleLabel.BackgroundTransparency = 1
antiTPToggleLabel.Position = UDim2.new(0, 12, 0, 0)
antiTPToggleLabel.Size = UDim2.new(1, -60, 1, 0)
antiTPToggleLabel.Text = "Anti-TP Scam"
antiTPToggleLabel.Font = Enum.Font.GothamBold
antiTPToggleLabel.TextSize = 13
antiTPToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
antiTPToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

local antiTPToggleButton = Instance.new("TextButton")
antiTPToggleButton.Name = "AntiTPToggleButton"
antiTPToggleButton.Parent = antiTPToggleFrame
antiTPToggleButton.Size = UDim2.new(0, 50, 0, 24)
antiTPToggleButton.Position = UDim2.new(1, -58, 0.5, -12)
antiTPToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 68)
antiTPToggleButton.Text = ""
antiTPToggleButton.BorderSizePixel = 0

local antiTPToggleBtnCorner = Instance.new("UICorner")
antiTPToggleBtnCorner.CornerRadius = UDim.new(0, 12)
antiTPToggleBtnCorner.Parent = antiTPToggleButton

local antiTPToggleIndicator = Instance.new("Frame")
antiTPToggleIndicator.Name = "Indicator"
antiTPToggleIndicator.Parent = antiTPToggleButton
antiTPToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
antiTPToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
antiTPToggleIndicator.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
antiTPToggleIndicator.BorderSizePixel = 0

local antiTPIndicatorCorner = Instance.new("UICorner")
antiTPIndicatorCorner.CornerRadius = UDim.new(0, 10)
antiTPIndicatorCorner.Parent = antiTPToggleIndicator

-- Player List
local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, -24, 1, -160) -- Adjusted for new toggle and execute button
body.Position = UDim2.new(0, 12, 0, 156) -- Adjusted position
body.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
body.BackgroundTransparency = 0.1
body.BorderSizePixel = 0
body.Parent = card

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0, 12)
bodyCorner.Parent = body

local list = Instance.new("ScrollingFrame")
list.Name = "PlayersList"
list.Parent = body
list.BackgroundTransparency = 1
list.Size = UDim2.new(1, -16, 1, -16)
list.Position = UDim2.new(0, 8, 0, 8)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout")
layout.Parent = list
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.Name

-- Player Row Template
local template = Instance.new("Frame")
template.Name = "TemplateRow"
template.Size = UDim2.new(1, 0, 0, 40)
template.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
template.Visible = false
template.Parent = list

local templateCorner = Instance.new("UICorner")
templateCorner.CornerRadius = UDim.new(0, 8)
templateCorner.Parent = template

local templateStroke = Instance.new("UIStroke")
templateStroke.Color = Color3.fromRGB(60, 60, 68)
templateStroke.Thickness = 1
templateStroke.Parent = template

local avatarDot = Instance.new("Frame")
avatarDot.Name = "AvatarDot"
avatarDot.Size = UDim2.new(0, 28, 0, 28)
avatarDot.Position = UDim2.new(0, 8, 0, 6)
avatarDot.BackgroundTransparency = 1
avatarDot.Parent = template

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 14)
avatarCorner.Parent = avatarDot

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "NameLabel"
nameLabel.Parent = template
nameLabel.BackgroundTransparency = 1
nameLabel.Position = UDim2.new(0, 48, 0, 6)
nameLabel.Size = UDim2.new(1, -100, 0, 28)
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextSize = 14
nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

local checkMark = Instance.new("Frame")
checkMark.Name = "CheckMark"
checkMark.Parent = template
checkMark.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
checkMark.BackgroundTransparency = 0
checkMark.BorderSizePixel = 0
checkMark.Position = UDim2.new(1, -38, 0, 6)
checkMark.Size = UDim2.new(0, 28, 0, 28)
checkMark.Visible = false

local checkCorner = Instance.new("UICorner")
checkCorner.CornerRadius = UDim.new(0, 14)
checkCorner.Parent = checkMark

local checkStroke = Instance.new("UIStroke")
checkStroke.Name = "AnimatedStroke"
checkStroke.Color = Color3.fromRGB(255, 255, 255)
checkStroke.Thickness = 2
checkStroke.Transparency = 0
checkStroke.Parent = checkMark

local checkGradient = Instance.new("UIGradient")
checkGradient.Parent = checkStroke
checkGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.1, 0),
    NumberSequenceKeypoint.new(0.9, 0),
    NumberSequenceKeypoint.new(1, 1)
})

local checkLabel = Instance.new("TextLabel")
checkLabel.Name = "NumberLabel"
checkLabel.Parent = checkMark
checkLabel.BackgroundTransparency = 1
checkLabel.Size = UDim2.new(1, 0, 1, 0)
checkLabel.Font = Enum.Font.GothamBold
checkLabel.TextSize = 16
checkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
checkLabel.Text = ""

-- FIXED: Execute Button - Only show on mobile
local execButton = Instance.new("TextButton")
execButton.Name = "ExecuteButton"
execButton.Parent = card
execButton.Size = UDim2.new(1, -24, 0, 32)
execButton.Position = UDim2.new(0, 12, 1, -44)
execButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
execButton.Text = "EXECUTE (F)"
execButton.Font = Enum.Font.GothamBold
execButton.TextSize = 14
execButton.TextColor3 = Color3.fromRGB(255,255,255)
execButton.BorderSizePixel = 0
execButton.Visible = UserInputService.TouchEnabled -- Only show on mobile

local execCorner = Instance.new("UICorner")
execCorner.CornerRadius = UDim.new(0, 10)
execCorner.Parent = execButton

-- Toggle Functions
toggleButton.MouseButton1Click:Connect(function()
    autoDefenseEnabled = not autoDefenseEnabled
    
    local targetPos, targetColor, targetIndicatorColor
    if autoDefenseEnabled then
        targetPos = UDim2.new(1, -22, 0, 2)
        targetColor = Color3.fromRGB(76, 175, 80)
        targetIndicatorColor = Color3.fromRGB(255, 255, 255)
    else
        targetPos = UDim2.new(0, 2, 0, 2)
        targetColor = Color3.fromRGB(60, 60, 68)
        targetIndicatorColor = Color3.fromRGB(180, 180, 180)
    end
    
    TweenService:Create(toggleIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
    TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(toggleIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetIndicatorColor}):Play()
end)

antiTPToggleButton.MouseButton1Click:Connect(function()
    antiTPScamEnabled = not antiTPScamEnabled
    
    if antiTPScamEnabled and not myPlot then
        -- Try to find plot again when enabling
        myPlot = findMyPlot()
        if myPlot then
            myPlotAnimalPodiums = getMyPlotAnimalPodiums(myPlot)
        else
            antiTPScamEnabled = false
            return
        end
    end
    
    local targetPos, targetColor, targetIndicatorColor
    if antiTPScamEnabled then
        targetPos = UDim2.new(1, -22, 0, 2)
        targetColor = Color3.fromRGB(76, 175, 80)
        targetIndicatorColor = Color3.fromRGB(255, 255, 255)
        
        if myPlot then
        end
    else
        targetPos = UDim2.new(0, 2, 0, 2)
        targetColor = Color3.fromRGB(60, 60, 68)
        targetIndicatorColor = Color3.fromRGB(180, 180, 180)
    end
    
    TweenService:Create(antiTPToggleIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
    TweenService:Create(antiTPToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(antiTPToggleIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetIndicatorColor}):Play()
end)

-- Execute Function
local function executeCommands()
    if not remoteReady then
        warn("⚠️ Remote not ready yet")
        return
    end
    
    local validPlayers = {}
    for _, plr in ipairs(selectedPlayers) do
        if plr and plr.Parent == Players then
            table.insert(validPlayers, plr)
        end
    end
    
    if #validPlayers == 0 then
        return
    end
    
    if #validPlayers == 1 then
        for _, cmd in ipairs({"balloon","rocket","inverse","tiny"}) do
            NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", validPlayers[1], cmd)
        end
    elseif #validPlayers >= 2 then
        local p1, p2 = validPlayers[1], validPlayers[2]
        for _, cmd in ipairs({"balloon","rocket","inverse","tiny"}) do
            NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", p1, cmd)
        end
        for _, cmd in ipairs({"ragdoll","jail","jumpscare","morph"}) do
            NetRemote:FireServer("78a772b6-9e1c-4827-ab8b-04a07838f298", p2, cmd)
        end
    end
end

execButton.MouseButton1Click:Connect(executeCommands)

-- Player Selection Functions
local function cleanupInvalidPlayers()
    local changed = false
    local newSelectedPlayers = {}
    
    local orderedUserIds = {}
    for userId, order in pairs(selectedUserIds) do
        table.insert(orderedUserIds, {userId = userId, order = order})
    end
    table.sort(orderedUserIds, function(a, b) return a.order < b.order end)
    
    for _, data in ipairs(orderedUserIds) do
        local plr = Players:GetPlayerByUserId(data.userId)
        if plr and plr.Parent == Players and plr ~= localPlayer then
            table.insert(newSelectedPlayers, plr)
        else
            selectedUserIds[data.userId] = nil
            changed = true
        end
    end
    
    selectedPlayers = newSelectedPlayers
    
    selectedSet = {}
    for _, plr in ipairs(selectedPlayers) do
        selectedSet[plr] = true
    end
    
    return changed
end

local function updateCheckmarks()
    cleanupInvalidPlayers()
    
    for _, r in ipairs(list:GetChildren()) do
        if r:IsA("Frame") and r ~= template then
            local checkFrame = r:FindFirstChild("CheckMark")
            if checkFrame then
                checkFrame.NumberLabel.Text = ""
                checkFrame.Visible = false
            end
        end
    end
    
    for i, plr in ipairs(selectedPlayers) do
        if plr and plr.Parent == Players then
            local row = list:FindFirstChild(plr.Name.."_row")
            if row then
                local checkFrame = row:FindFirstChild("CheckMark")
                if checkFrame then
                    checkFrame.Visible = true
                    checkFrame.NumberLabel.Text = tostring(i)
                end
            end
        end
    end
end

local function refreshList()
    cleanupInvalidPlayers()
    
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") and child ~= template then
            child:Destroy()
        end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            local row = template:Clone()
            row.Visible = true
            row.Name = plr.Name.."_row"
            row.Parent = list
            row.NameLabel.Text = plr.DisplayName.." @"..plr.Name
            
            task.spawn(function()
                local success, thumb = pcall(function()
                    return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                
                if success and thumb and row and row.Parent then
                    row.AvatarDot:ClearAllChildren()
                    local img = Instance.new("ImageLabel")
                    img.Parent = row.AvatarDot
                    img.Size = UDim2.new(1,0,1,0)
                    img.BackgroundTransparency = 1
                    img.Image = thumb
                    
                    local imgCorner = Instance.new("UICorner")
                    imgCorner.CornerRadius = UDim.new(0, 14)
                    imgCorner.Parent = img
                end
            end)
            
            row.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if selectedUserIds[plr.UserId] then
                        selectedUserIds[plr.UserId] = nil
                        selectedSet[plr] = nil
                        for i, p in ipairs(selectedPlayers) do
                            if p == plr then
                                table.remove(selectedPlayers, i)
                                break
                            end
                        end
                        
                        for i, p in ipairs(selectedPlayers) do
                            selectedUserIds[p.UserId] = i
                        end
                    else
                        if #selectedPlayers < 2 then
                            local newOrder = #selectedPlayers + 1
                            selectedUserIds[plr.UserId] = newOrder
                            table.insert(selectedPlayers, plr)
                            selectedSet[plr] = true
                        end
                    end
                    updateCheckmarks()
                end
            end)
        end
    end
    
    updateCheckmarks()
    list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+12)
end

-- Initialize plot detection
task.spawn(function()
    task.wait(2) -- Wait for game to load
    myPlot = findMyPlot()
    if myPlot then
        myPlotAnimalPodiums = getMyPlotAnimalPodiums(myPlot)
    else
        plotStatus.Text = "Plot: Not found ❌"
        warn("⚠️ Anti-TP Scam: Could not find plot")
    end
end)

-- Initialize player list
task.spawn(function()
    while not remoteReady do
        task.wait(0.1)
    end
    task.wait(0.5)
    refreshList()
end)

-- Player Events
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    refreshList()
end)

Players.PlayerRemoving:Connect(function(removedPlayer)
    selectedUserIds[removedPlayer.UserId] = nil
    selectedSet[removedPlayer] = nil
    for i = #selectedPlayers, 1, -1 do
        if selectedPlayers[i] == removedPlayer then
            table.remove(selectedPlayers, i)
        end
    end
    refreshList()
end)

localPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    refreshList()
end)

-- Keybind for execute (F key)
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        executeCommands()
    end
end)

-- Dragging
local dragging = false
local dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    outer.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end

topLeftAccent.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = outer.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        update(input)
    end
end)

-- Discord bar animation
task.spawn(function()
    local discordTween1 = TweenService:Create(
        discordBar,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.1),
        {Position = UDim2.new(0.5, -130, 0, 8)}
    )
    local discordTween2 = TweenService:Create(
        discordBar,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.1),
        {BackgroundTransparency = 0.1}
    )
    discordTween1:Play()
    discordTween2:Play()
end)
    while true do
        task.wait(1)
    end
end)

-- SAINT WAS AROUND HERE

task.wait(0.5)
task.spawn(function()
    -- Services
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChiraqHubGui"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 89)
MainFrame.Position = UDim2.new(0.5, -190, 0, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.10 -- MADE MORE TRANSPARENT (Adjust this value as needed)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

-- Background Gradient (Subtle depth even when transparent)
local FrameGradient = Instance.new("UIGradient")
FrameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
FrameGradient.Transparency = NumberSequence.new(0.2) -- Adds transparency to the gradient itself
FrameGradient.Rotation = 45
FrameGradient.Parent = MainFrame

-- THE BORDER (Rich White Glow)
local WhiteStroke = Instance.new("UIStroke")
WhiteStroke.Color = Color3.fromRGB(255, 255, 255)
WhiteStroke.Thickness = 3.2
WhiteStroke.Transparency = 0 
WhiteStroke.Parent = MainFrame

TweenService:Create(WhiteStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Transparency = 0.6,
    Thickness = 2.5
}):Play()

-- Title: "ChiraqHub"
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 10) 
Title.BackgroundTransparency = 1
Title.Text = "ChiraqHub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24 
Title.Parent = MainFrame

-- FULL-TEXT METALLIC GRADIENT (Wide Spread)
local TextGradient = Instance.new("UIGradient")
TextGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 140, 140)), -- Silver Base
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 255)), -- First Shine
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 160, 160)), -- Deep Valley
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 255, 255)), -- Second Shine
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 140, 140))  -- Silver Base
})
TextGradient.Parent = Title

-- Wide Sweep Animation Loop
task.spawn(function()
    while true do
        TextGradient.Rotation = 25 -- Low angle to sweep across the whole text width
        TextGradient.Offset = Vector2.new(-1, 0)
        
        local anim = TweenService:Create(TextGradient, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Offset = Vector2.new(1, 0)
        })
        
        anim:Play()
        anim.Completed:Wait()
        task.wait(0.5)
    end
end)

-- Subtext
local Subtext = Instance.new("TextLabel")
Subtext.Size = UDim2.new(1, 0, 0, 20)
Subtext.Position = UDim2.new(0, 0, 0, 42)
Subtext.BackgroundTransparency = 1
Subtext.Text = ".gg/chiraqhub | LEAKED BY SAINT"
Subtext.TextColor3 = Color3.fromRGB(220, 220, 220)
Subtext.Font = Enum.Font.Gotham
Subtext.TextSize = 13
Subtext.Parent = MainFrame

-- Stats (FPS/Ping)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, 0, 0, 30)
StatsLabel.Position = UDim2.new(0, 0, 0, 62)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 0  PING: 0ms"
StatsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextSize = 16
StatsLabel.Parent = MainFrame

-- Live Stats Loop
RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1 / dt)
    local success, ping = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    StatsLabel.Text = string.format("FPS: %d  PING: %s", fps, success and tostring(ping).."ms" or "--")
end)
    while true do
        task.wait()
    end


end)