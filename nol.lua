local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

getgenv().TransparencyEnabled = getgenv().TransparencyEnabled or false

local function gradient(text, startColor, endColor)
    local result, chars = "", {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        chars[#chars + 1] = uchar
    end
    
    for i = 1, #chars do
        local t = (i - 1) / math.max(#chars - 1, 1)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', 
            math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255), 
            math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255), 
            math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255), 
            chars[i])
    end
    return result
end

local themes = {"暗色", "亮色", "摩卡", "水色"}
local currentThemeIndex = 1

local Window = WindUI:CreateWindow({
    Title = gradient("遗忘者   ", Color3.fromRGB(139, 0, 255), Color3.fromRGB(255, 0, 0)), 
    Author = gradient("被遗弃", Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255)),
    IconThemed = true,
    Folder = "NOL",
    Size = UDim2.fromOffset(150, 100),
    Transparent = getgenv().TransparencyEnabled,
    Theme = "暗色",
    Resizable = true,
    SideBarWidth = 150,
    BackgroundImageTransparency = 0.5,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            currentThemeIndex = currentThemeIndex + 1
            if currentThemeIndex > #themes then
                currentThemeIndex = 1
            end
            
            local newTheme = themes[currentThemeIndex]
            WindUI:SetTheme(newTheme)
            
            WindUI:Notify({
                Title = "主题已更改",
                Content = "切换到 " .. newTheme .. " 主题！",
                Duration = 2,
                Icon = "调色板"
            })
            print("切换到 " .. newTheme .. " 主题")
        end
    }
})

Window:EditOpenButton({
    Title = "遗忘者",
    CornerRadius = UDim.new(16,16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 0, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 0)), 
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) 
    }),
    Draggable = true,
})

Window:Tag({
    Title = "杂项",
    Radius = 5,
    Color = Color3.fromRGB(255, 255, 255),
})


Window:SetToggleKey(Enum.KeyCode.F, true)

local Tabs = {
    XiProInfo = Window:Tab({ Title = "公告", Icon = "信息" }),
    Player = Window:Tab({ Title = "玩家", Icon = "玩家" }),
    Misc = Window:Tab({ Title = "能力", Icon = "礼物" }),
    Auto_Stun = Window:Tab({ Title = "幸存者", Icon = "瞄准" }),
        kill = Window:Tab({ Title = "杀手", Icon = "骷髅" }),
    Random = Window:Tab({ Title = "通用瞄准", Icon = "准星" }),
    Anti = Window:Tab({ Title = "反效果", Icon = "处理器" }),
    Teleport = Window:Tab({ Title = "传送", Icon = "传送" }),
    Actions = Window:Tab({ Title = "动画", Icon = "动作" }),
    
    SilentAim = Window:Tab({ Title = "静默瞄准", Icon = "目标" })
}
Window:SelectTab(1)

Tabs.XiProInfo:Paragraph({
    Title = "使用说明",
    Desc = "脚本适用游戏: 被遗忘者",
    ImageSize = 30,
    Thumbnail = "rbxassetid://110237166940650",
    ThumbnailSize = 170
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local ragingPaceSavedRange = LocalPlayer:FindFirstChild("狂怒冲刺范围")
if not ragingPaceSavedRange then
    ragingPaceSavedRange = Instance.new("NumberValue")
    ragingPaceSavedRange.Name = "狂怒冲刺范围"
    ragingPaceSavedRange.Value = 19
    ragingPaceSavedRange.Parent = LocalPlayer
end

local ragingPaceSavedEnabled = LocalPlayer:FindFirstChild("狂怒冲刺启用")
if not ragingPaceSavedEnabled then
    ragingPaceSavedEnabled = Instance.new("BoolValue")
    ragingPaceSavedEnabled.Name = "狂怒冲刺启用"
    ragingPaceSavedEnabled.Value = false
    ragingPaceSavedEnabled.Parent = LocalPlayer
end

local ragingPaceRange = ragingPaceSavedRange.Value
local ragingPaceSpamDuration = 3
local ragingPaceCooldownTime = 5
local ragingPaceActiveCooldowns = {}
local ragingPaceEnabled = ragingPaceSavedEnabled.Value

local ragingPaceAnimsToDetect = {
    ["116618003477002"] = true,
    ["119462383658044"] = true,
    ["131696603025265"] = true,
    ["121255898612475"] = true,
    ["133491532453922"] = true,
    ["103601716322988"] = true,
    ["86371356500204"] = true,
    ["72722244508749"] = true,
    ["87259391926321"] = true,
    ["96959123077498"] = true,
}

local function fireRagingPace()
    game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\n\0\0\0RagingPace") })
end

local function isRagingPaceAnimationMatching(anim)
    local id = tostring(anim.Animation and anim.Animation.AnimationId or "")
    local numId = id:match("%d+")
    return ragingPaceAnimsToDetect[numId] or false
end

RunService.Heartbeat:Connect(function()
    if not ragingPaceEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local dist = (targetHRP.Position - myChar.HumanoidRootPart.Position).Magnitude
                if dist <= ragingPaceRange and (not ragingPaceActiveCooldowns[player] or tick() - ragingPaceActiveCooldowns[player] >= ragingPaceCooldownTime) then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            if isRagingPaceAnimationMatching(track) then
                                ragingPaceActiveCooldowns[player] = tick()
                                task.spawn(function()
                                    local startTime = tick()
                                    while tick() - startTime < ragingPaceSpamDuration do
                                        fireRagingPace()
                                        task.wait(0.05)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

Tabs.Misc:Section({Title = "自动狂怒"})
Tabs.Misc:Toggle({
    Title = "自动狂怒(屠夫)",
    Default = ragingPaceEnabled,
    Callback = function(state)
        ragingPaceEnabled = state
        ragingPaceSavedEnabled.Value = state
    end
})

Tabs.Misc:Slider({
    Title = "距离范围",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = ragingPaceRange},
    Suffix = "距离单位",
    Callback = function(val)
        ragingPaceRange = val
        ragingPaceSavedRange.Value = val
    end
})

Tabs.Misc:Section({Title = "自动404错误"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local antiAnimSavedEnabled = LocalPlayer:FindFirstChild("反动画启用")
if not antiAnimSavedEnabled then
    antiAnimSavedEnabled = Instance.new("BoolValue")
    antiAnimSavedEnabled.Name = "反动画启用"
    antiAnimSavedEnabled.Value = false
    antiAnimSavedEnabled.Parent = LocalPlayer
end

local antiAnimSavedRange = LocalPlayer:FindFirstChild("反动画范围")
if not antiAnimSavedRange then
    antiAnimSavedRange = Instance.new("NumberValue")
    antiAnimSavedRange.Name = "反动画范围"
    antiAnimSavedRange.Value = 19
    antiAnimSavedRange.Parent = LocalPlayer
end

local antiAnimRange = antiAnimSavedRange.Value
local antiAnimSpamDuration = 3
local antiAnimCooldownTime = 5
local antiAnimActiveCooldowns = {}
local antiAnimEnabled = antiAnimSavedEnabled.Value

local antiAnimAnimsToDetect = {
    ["116618003477002"] = true,
    ["119462383658044"] = true,
    ["131696603025265"] = true,
    ["121255898612475"] = true,
    ["133491532453922"] = true,
    ["103601716322988"] = true,
    ["86371356500204"] = true,
    ["72722244508749"] = false,
    ["87259391926321"] = true,
    ["96959123077498"] = false,
    ["86709774283672"] = true,
    ["77448521277146"] = true,
}

local function fire404Error()
    game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\5\0\0\0404Error") })
end

local function isAntiAnimAnimationMatching(anim)
    local id = tostring(anim.Animation and anim.Animation.AnimationId or "")
    local numId = id:match("%d+")
    return antiAnimAnimsToDetect[numId] or false
end

RunService.Heartbeat:Connect(function()
    if not antiAnimEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local dist = (targetHRP.Position - myChar.HumanoidRootPart.Position).Magnitude
                if dist <= antiAnimRange and (not antiAnimActiveCooldowns[player] or tick() - antiAnimActiveCooldowns[player] >= antiAnimCooldownTime) then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            if isAntiAnimAnimationMatching(track) then
                                antiAnimActiveCooldowns[player] = tick()
                                task.spawn(function()
                                    local startTime = tick()
                                    while tick() - startTime < antiAnimSpamDuration do
                                        fire404Error()
                                        task.wait(0.05)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

Tabs.Misc:Toggle({
    Title = "自动404错误 [不可阻挡]",
    Default = antiAnimEnabled,
    Callback = function(state)
        antiAnimEnabled = state
        antiAnimSavedEnabled.Value = state
    end
})

Tabs.Misc:Slider({
    Title = "距离范围",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = antiAnimRange},
    Suffix = "距离单位",
    Callback = function(val)
        antiAnimRange = val
        antiAnimSavedRange.Value = val
    end
})

local chanceAim = {
    active = false,
    duration = 1.7,
    prediction = 4,
    targets = {"屠夫", "酷小孩", "无名氏", "1x1x1x1", "诺丽", "六号", "诺斯费拉图"},
    animations = {["103601716322988"] = true, ["133491532453922"] = true, ["86371356500204"] = true, ["76649505662612"] = true, ["81698196845041"] = true},
    humanoid = nil,
    hrp = nil,
    lastTrigger = 0,
    aiming = false,
    original = {}
}

local function setupChanceAimChar(char)
    chanceAim.humanoid = char:WaitForChild("Humanoid")
    chanceAim.hrp = char:WaitForChild("HumanoidRootPart")
end

local function getValidTarget()
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("杀手")
    if killersFolder then
        local targets = chanceAim.targets
        for i = 1, #targets do
            local target = killersFolder:FindFirstChild(targets[i])
            if target and target:FindFirstChild("HumanoidRootPart") then
                return target.HumanoidRootPart
            end
        end
    end
    return nil
end

local function getPlayingAnimationIds()
    local ids = {}
    if chanceAim.humanoid then
        local tracks = chanceAim.humanoid:GetPlayingAnimationTracks()
        for i = 1, #tracks do
            local track = tracks[i]
            local anim = track.Animation
            if anim and anim.AnimationId then
                local id = anim.AnimationId:match("%d+")
                if id then ids[id] = true end
            end
        end
    end
    return ids
end

if LocalPlayer.Character then setupChanceAimChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupChanceAimChar)

Tabs.Auto_Stun:Section({Title = "机会自瞄"})

RunService.RenderStepped:Connect(function()
    if not chanceAim.active or not chanceAim.humanoid or not chanceAim.hrp then return end

    local currentTime = tick()
    local playing = getPlayingAnimationIds()
    local triggered = false
    
    for id in pairs(chanceAim.animations) do
        if playing[id] then 
            triggered = true
            break 
        end
    end

    if triggered then
        chanceAim.lastTrigger = currentTime
        chanceAim.aiming = true
    end

    if chanceAim.aiming and currentTime - chanceAim.lastTrigger <= chanceAim.duration then
        if not chanceAim.original.ws then
            chanceAim.original = {
                ws = chanceAim.humanoid.WalkSpeed,
                jp = chanceAim.humanoid.JumpPower,
                ar = chanceAim.humanoid.AutoRotate
            }
            chanceAim.humanoid.AutoRotate = false
            chanceAim.hrp.AssemblyAngularVelocity = Vector3.zero
        end
        
        local targetHRP = getValidTarget()
        if targetHRP then
            local predictedPos = targetHRP.Position + (targetHRP.CFrame.LookVector * chanceAim.prediction)
            local direction = (predictedPos - chanceAim.hrp.Position).Unit
            local yRot = math.atan2(-direction.X, -direction.Z)
            chanceAim.hrp.CFrame = CFrame.new(chanceAim.hrp.Position) * CFrame.Angles(0, yRot, 0)
        end
    elseif chanceAim.aiming then
        chanceAim.aiming = false
        if chanceAim.original.ws then
            chanceAim.humanoid.WalkSpeed = chanceAim.original.ws
            chanceAim.humanoid.JumpPower = chanceAim.original.jp
            chanceAim.humanoid.AutoRotate = chanceAim.original.ar
            chanceAim.original = {}
        end
    end
end)

local function OnRemoteEvent(eventName, eventArg)
    if not chanceAim.active then return end
    if eventName == "UseActorAbility" and type(eventArg) == "table" and eventArg[1] and tostring(eventArg[1]) == buffer.fromstring("\3\5\0\0\0Shoot") then
        chanceAim.lastTrigger = tick()
        chanceAim.aiming = true
    end
end
Auto_Stun:Toggle({
    Title = "自动瞄准",
    Default = false,
    Callback = function(v) chanceAim.active = v end
})

Tabs.Auto_Stun:Slider({
    Title = "预测系数 (高延迟 > 4)",
    Step = 1,
    Value = {Min = 1, Max = 10, Default = chanceAim.prediction},
    Suffix = "距离单位",
    Callback = function(val) chanceAim.prediction = val end
})

RunService.RenderStepped:Connect(OnRenderStep)

local AutoFlipCoins = false
local flipCoinsThread = nil

Tabs.Auto_Stun:Toggle({
    Title = "自动抛硬币 (3次)",
    Default = false,
    Callback = function(state)
        AutoFlipCoins = state
        
        if AutoFlipCoins then
            flipCoinsThread = task.spawn(function()
                while AutoFlipCoins and task.wait() do
                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    local chargesText = playerGui:FindFirstChild("主界面") and 
                                       playerGui.主界面:FindFirstChild("能力容器") and
                                       playerGui.主界面.能力容器:FindFirstChild("射击") and
                                       playerGui.主界面.能力容器.射击:FindFirstChild("充能")
                    
                    if chargesText and chargesText:IsA("TextLabel") and chargesText.Text == "3" then
                        break
                    else
                        game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\8\0\0\0CoinFlip") })
                    end
                end
            end)
        elseif flipCoinsThread then
            task.cancel(flipCoinsThread)
            flipCoinsThread = nil
        end
    end
})

Tabs.Auto_Stun:Toggle({
    Title = "自动抛硬币 (1次)",
    Default = false,
    Callback = function(state)
        AutoFlipCoins = state
        
    if AutoFlipCoins then
            flipCoinsThread = task.spawn(function()
                while AutoFlipCoins and task.wait() do
                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    local chargesText = playerGui:FindFirstChild("主界面") and 
                                       playerGui.主界面:FindFirstChild("能力容器") and
                                       playerGui.主界面.能力容器:FindFirstChild("射击") and
                                       playerGui.主界面.能力容器.射击:FindFirstChild("充能")
                    
                    if chargesText and chargesText:IsA("TextLabel") and chargesText.Text == "1" then
                        break
                    else
                                           game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\8\0\0\0CoinFlip") })
                    end
                end
            end)
        elseif flipCoinsThread then
            task.cancel(flipCoinsThread)
            flipCoinsThread = nil
        end
    end
})


game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent.OnClientEvent:Connect(OnRemoteEvent)




Tabs.Random:Section({Title = "通用瞄准"})

Tabs.Random:Toggle({
    Title = "自瞄",
    Default = false,
    Callback = function(state) aimbot.enabled = state end
})

local faceEnemy = {
    enabled = false,
    targetType = "杀手",
    autoAim = false
}

local faceEnemyConnection

Tabs.Random:Toggle({
    Title = "自动面向敌人",
    Default = false,
    Callback = function(state)
        faceEnemy.enabled = state
        
        if state then
            faceEnemyConnection = RunService.RenderStepped:Connect(function()
                if not faceEnemy.enabled then return end
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local myRoot = char.HumanoidRootPart
                
                local targetFolder = faceEnemy.targetType == "杀手" 
                    and (Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("杀手"))
                    or (Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("幸存者"))
                
                if not targetFolder then return end
                
                local closest, minDist = nil, math.huge
                for _, target in ipairs(targetFolder:GetChildren()) do
                    if target:IsA("Model") and target:FindFirstChild("HumanoidRootPart") then
                        local dist = (target.HumanoidRootPart.Position - myRoot.Position).Magnitude
                        if dist < minDist then
                            closest, minDist = target, dist
                        end
                    end
                end
                
                if closest and closest:FindFirstChild("HumanoidRootPart") then
                    local targetPos = closest.HumanoidRootPart.Position
                    local lookPos = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)
                    myRoot.CFrame = CFrame.new(myRoot.Position, lookPos)
                end
            end)
        else
            if faceEnemyConnection then
                faceEnemyConnection:Disconnect()
                faceEnemyConnection = nil
            end
        end
    end
})

Tabs.Random:Dropdown({
    Title = "面向目标类型",
    Values = {"杀手", "幸存者"},
    Multi = false,
    AllowNone = false,
    Callback = function(choice) faceEnemy.targetType = choice end
})

local orbit = {
    active = false,
    distance = 10,
    speed = 5,
    angle = 0,
    targetPlayer = nil,
    heightOffset = 0
}

RunService.RenderStepped:Connect(function(dt)
    if not orbit.active or not orbit.targetPlayer then return end

    local targetChar = orbit.targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end

    orbit.angle = orbit.angle + orbit.speed * dt
    local offset = Vector3.new(
        math.cos(orbit.angle) * orbit.distance,
        orbit.heightOffset,
        math.sin(orbit.angle) * orbit.distance
    )
    myRoot.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
end)

Tabs.Random:Toggle({
    Title = "环绕玩家",
    Default = false,
    Callback = function(state) orbit.active = state end
})

Tabs.Random:Dropdown({
    Title = "选择目标",
    Values = (function()
        local names = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then names[#names + 1] = player.Name end
        end
        return names
    end)(),
    Multi = false,
    AllowNone = true,
    Callback = function(choice)
        orbit.targetPlayer = Players:FindFirstChild(choice)
    end
})

Tabs.Random:Slider({
    Title = "旋转速度",
    Step = 0.5,
    Value = {Min = 1, Max = 50, Default = orbit.speed},
    Suffix = "/秒",
    Callback = function(val) orbit.speed = val end
})

Tabs.Random:Slider({
    Title = "环绕距离",
    Step = 1,
    Value = {Min = 1, Max = 20, Default = orbit.distance},
    Suffix = "距离单位",
    Callback = function(val) orbit.distance = val end
})

Tabs.Random:Slider({
    Title = "高度偏移",
    Step = 0.5,
    Value = {Min = -10, Max = 10, Default = orbit.heightOffset},
    Suffix = "距离单位",
    Callback = function(val) orbit.heightOffset = val end
})





Tabs.Teleport:Section({Title = "传送"})

Tabs.Teleport:Button({
    Title = "传送到杀手",
    Callback = function()
        local folder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("杀手")
        local killer = folder and folder:FindFirstChildWhichIsA("Model")
        if killer and killer.PrimaryPart then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = killer.PrimaryPart.CFrame
            end
        end
    end
})

Tabs.Teleport:Button({
    Title = "传送到最近幸存者",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local folder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("幸存者")
        if not folder then return end
        
        local myPos = char.HumanoidRootPart.Position
        local nearest, minDist = nil, math.huge
        
        for _, survivor in ipairs(folder:GetChildren()) do
            if survivor:IsA("Model") and survivor:FindFirstChild("HumanoidRootPart") then
                local dist = (survivor.HumanoidRootPart.Position - myPos).Magnitude
                if dist < minDist then
                    nearest, minDist = survivor, dist
                end
            end
        end
        
        if nearest and nearest:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

Tabs.Teleport:Button({
    Title = "传送到发电机",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "发电机" then
                local target = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
                if target then
                    char.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end
})

Tabs.Teleport:Button({
    Title = "传送到医疗包",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "物品根" and v.Parent and v.Parent.Name == "医疗包" then
                char.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                break
            end
        end
    end
})

Tabs.Teleport:Button({
    Title = "传送到可乐",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "物品根" and v.Parent and v.Parent.Name == "可乐" then
                char.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                break
            end
        end
    end
})

-- 动作系统
local emoteSystem = {
    active = false,
    currentEmote = "傻比利",
    currentTrack = nil,
    currentSound = nil,
    bodyVel = nil,
    emotes = {
        ["傻比利"] = {
            animId = "rbxassetid://107464355830477",
            soundId = "rbxassetid://77601084987544",
            volume = 0.5,
            looped = false,
            remoteName = nil,
            cleanAssets = {"表情帽", "表情灯光", "玩家表情手"}
        },
        ["傻傻的"] = {
            animId = "rbxassetid://107464355830477",
            soundId = "rbxassetid://120176009143091",
            volume = 0.5,
            looped = false,
            remoteName = nil,
            cleanAssets = {"表情帽", "表情灯光", "玩家表情手"}
        },
        ["诡计"] = {
            animId = "rbxassetid://87482480949358",
            soundId = "rbxassetid://132297506693854",
            volume = 2,
            looped = false,
            remoteName = "_诡计",
            cleanAssets = {},
            hasEffect = false
        },
        ["贵宾舞蹈"] = {
            animId = "rbxassetid://138019937280193",
            soundId = "rbxassetid://109474987384441",
            volume = 0.5,
            looped = true,
            remoteName = "贵宾舞蹈",
            cleanAssets = {},
            hasEffect = true
        },
        ["江南风"] = {
            animId = "rbxassetid://108308837970067",
            soundId = "rbxassetid://86963552203595",
            volume = 0.5,
            looped = true,
            remoteName = nil,
            cleanAssets = {"表情帽", "表情灯光", "玩家表情手"}
        }
    }
}

local function stopEmote()
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.JumpPower = 50
        
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
    
    if rootPart then
        local bodyVel = rootPart:FindFirstChildOfClass("BodyVelocity")
        if bodyVel then bodyVel:Destroy() end
        
        for _, sound in ipairs(rootPart:GetChildren()) do
            if sound:IsA("Sound") then
                sound:Stop()
                sound:Destroy()
            end
        end
    end
    
    for _, assetName in ipairs({"表情帽", "表情灯光", "玩家表情手", "玩家表情特效"}) do
        local asset = char:FindFirstChild(assetName)
        if asset then asset:Destroy() end
    end
    
    emoteSystem.currentTrack = nil
    emoteSystem.currentSound = nil
    emoteSystem.bodyVel = nil
end

local function playEmote()
    stopEmote()
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    local emoteData = emoteSystem.emotes[emoteSystem.currentEmote]
    if not emoteData then return end
    
    humanoid.PlatformStand = true
    humanoid.JumpPower = 0
    
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = rootPart
    emoteSystem.bodyVel = bodyVel
    
    local anim = Instance.new("Animation")
    anim.AnimationId = emoteData.animId
    local track = humanoid:LoadAnimation(anim)
    track:Play()
    emoteSystem.currentTrack = track
    
    local sound = Instance.new("Sound")
    sound.SoundId = emoteData.soundId
    sound.Volume = emoteData.volume
    sound.Looped = emoteData.looped
    sound.Parent = rootPart
    sound:Play()
    emoteSystem.currentSound = sound
    
    if emoteData.hasEffect then
        pcall(function()
            local effect = ReplicatedStorage.Assets.幸存者.贵宾舞蹈.贵宾光束特效:Clone()
            effect.Name = "玩家表情特效"
            effect.CFrame = rootPart.CFrame * CFrame.new(0, -1, -0.3)
            effect.WeldConstraint.Part0 = rootPart
            effect.WeldConstraint.Part1 = effect
            effect.CanCollide = false
            effect.Parent = char
        end)
    end
    
    if emoteData.remoteName then
        pcall(function()
            remoteEvent:FireServer("播放表情", "动画", emoteData.remoteName)
        end)
    end
    
    track.Stopped:Connect(function()
        if not emoteSystem.active then
            humanoid.PlatformStand = false
            if bodyVel and bodyVel.Parent then bodyVel:Destroy() end
            
            for _, assetName in ipairs(emoteData.cleanAssets) do
                local asset = char:FindFirstChild(assetName)
                if asset then asset:Destroy() end
            end
        end
    end)
end

Tabs.Actions:Section({Title = "动作表情"})

Tabs.Actions:Dropdown({
    Title = "选择动作",
    Values = {"傻比利", "傻傻的", "诡计", "贵宾舞蹈", "江南风"},
    Multi = false,
    AllowNone = false,
    Callback = function(selected)
        emoteSystem.currentEmote = selected
        if emoteSystem.active then
            playEmote()
        end
    end
})

Tabs.Actions:Toggle({
    Title = "开始动作",
    Default = false,
    Callback = function(state)
        emoteSystem.active = state
        if state then
            playEmote()
        else
            stopEmote()
        end
    end
})


local fakeDieEnabled = false
local fakeDieTrack = nil
local fakeDieConnection = nil

Tabs.Actions:Toggle({
    Title = "假死",
    Default = false,
    Callback = function(state)
        fakeDieEnabled = state
        
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        
        local plr = Players.LocalPlayer
        local char = plr.Character
        if not char then return end
        
        local hum = char:WaitForChild("Humanoid")
        
        if state then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://118795597134269"
            
            fakeDieTrack = hum:LoadAnimation(anim)
            fakeDieTrack:Play()
            
            if fakeDieTrack.Length > 0 then
                fakeDieTrack.TimePosition = fakeDieTrack.Length * 0.5
            end
            
            local stopped = false
            fakeDieConnection = RunService.Heartbeat:Connect(function()
                if fakeDieTrack.IsPlaying and not stopped and fakeDieTrack.Length > 0 then
                    local percent = fakeDieTrack.TimePosition / fakeDieTrack.Length
                    if percent >= 0.9 then
                        fakeDieTrack:AdjustSpeed(0)
                        stopped = true
                    end
                end
            end)
        else
            if fakeDieTrack then
                fakeDieTrack:Stop()
                fakeDieTrack = nil
            end
            
            if fakeDieConnection then
                fakeDieConnection:Disconnect()
                fakeDieConnection = nil
            end
            
            pcall(function()
                hum:PlayEmote("空闲")
            end)
        end
    end
})





local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local invisAnimationId = "75804462760596"
local invisLoopRunning = false
local invisLoopThread
local invisCurrentAnim = nil

local function startInvisibility()
    invisLoopRunning = true
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end

    invisLoopThread = task.spawn(function()
        while invisLoopRunning do
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. invisAnimationId
            local loadedAnim = humanoid:LoadAnimation(anim)
            invisCurrentAnim = loadedAnim
            loadedAnim.Looped = false
            loadedAnim:Play()
            loadedAnim:AdjustSpeed(0)
            task.wait(0.000001)
        end
    end)
end

local function stopInvisibility()
    invisLoopRunning = false
    if invisLoopThread then
        task.cancel(invisLoopThread)
        invisLoopThread = nil
    end
    if invisCurrentAnim then
        invisCurrentAnim:Stop()
        invisCurrentAnim = nil
    end
    local humanoid = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character:FindFirstChildOfClass("AnimationController"))
    if humanoid then
        for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
            v:AdjustSpeed(100000)
        end
    end
    local animateScript = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("动画脚本")
    if animateScript then
        animateScript.Disabled = true
        animateScript.Disabled = false
    end
end

Tabs.Actions:Toggle({
    Title = "隐身",
    Value = false,
    Tooltip = "狗爬式隐身",
    Callback = function(Value)
        if Value then
            startInvisibility()
        else
            stopInvisibility()
        end
    end
})



local v1 = game:GetService("ReplicatedStorage")
local v2 = LocalPlayer
local v3 = v2.Character or v2.CharacterAdded:Wait()
local v4 = v3:WaitForChild("HumanoidRootPart")

v2.CharacterAdded:Connect(function(newChar)
    v3 = newChar
    v4 = v3:WaitForChild("HumanoidRootPart")
end)

local SilentAimEnabled = false
local WallCheckEnabled = false
local FilterKillersEnabled = false
local FilterSurvivorsEnabled = false

local function v5()
    if not SilentAimEnabled then return nil end
    
    local v6, v7 = nil, 100
    
    local function checkTarget(v8, v10)
        if WallCheckEnabled then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {v3, v8}
            rayParams.IgnoreWater = true
            
            local rayResult = workspace:Raycast(
                v4.Position,
                (v10.Position - v4.Position).Unit * (v10.Position - v4.Position).Magnitude,
                rayParams
            )
            
            if rayResult then
                local hitPart = rayResult.Instance
                if not hitPart:IsDescendantOf(v8) then
                    return false
                end
            end
        end
        
        if FilterKillersEnabled then
            local killersFolder = workspace.Players:FindFirstChild("杀手")
            if killersFolder and v8:IsDescendantOf(killersFolder) then
                return false
            end
        end
        
        if FilterSurvivorsEnabled then
            local survivorsFolder = workspace.Players:FindFirstChild("幸存者")
            if survivorsFolder and v8:IsDescendantOf(survivorsFolder) then
                return false
            end
        end
        
        return true
    end

    for _, v8 in workspace:GetDescendants() do
        if v8:IsA("Model") and v8 ~= v3 then
            local v9 = v8:FindFirstChild("Humanoid")
            local v10 = v8:FindFirstChild("HumanoidRootPart")
            if v9 and v10 and v9.Health > 0 then
                if checkTarget(v8, v10) then
                    local v11 = (v4.Position - v10.Position).Magnitude
                    if v11 < v7 then
                        v6, v7 = v10.Position, v11
                    end
                end
            end
        end
    end
    return v6
end





Tabs.SilentAim:Section({Title = "静默瞄准设置"})

Tabs.SilentAim:Toggle({
    Title = "静默瞄准",
    Default = false,
    Callback = function(state)
        SilentAimEnabled = state
    end
})

Tabs.SilentAim:Toggle({
    Title = "墙体检测",
    Default = false,
    Callback = function(state)
        WallCheckEnabled = state
    end
})

Tabs.SilentAim:Toggle({
    Title = "排除杀手",
    Default = false,
    Callback = function(state)
        FilterKillersEnabled = state
    end
})

Tabs.SilentAim:Toggle({
    Title = "排除幸存者",
    Default = false,
    Callback = function(state)
        FilterSurvivorsEnabled = state
    end
})

Tabs.SilentAim:Button({
    Title = "启用静默瞄准",
    Callback = function()
        task.wait(1)
        
        local v12, v13 = pcall(require, v1.系统.玩家.杂项.获取玩家鼠标位置)
        
        if v12 then
            if typeof(v13) == "函数" then
                local v14 = v13
                v1.系统.玩家.杂项.获取玩家鼠标位置 = function(...)
                    return v5() or v14(...)
                end
            elseif typeof(v13) == "表格" then
                for v15, v16 in pairs(v13) do
                    if typeof(v16) == "函数" then
                        local v17 = v16
                        v13[v15] = function(...)
                            return v5() or v17(...)
                        end
                    end
                end
            end
        end
        
        WindUI:Notify({
            Title = "静默瞄准",
            Content = "支持角色: 杜塞克, 酷小孩, 诺丽 远程技能",
            Duration = 3
        })
    end
})


local ff_connection = nil
local ff_enabled = false
local ff_cd = false
local jumpHeight = 72
local jumpDistance = 35

local function Flip()
    if ff_cd then
        return
    end
    ff_cd = true
    local character = game.Players.LocalPlayer.Character
    if not character then
        ff_cd = false
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local Humanoid = character:FindFirstChildOfClass("Humanoid")
    local animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
    if not hrp or not Humanoid then
        ff_cd = false
        return
    end
    local savedTracks = {}
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            savedTracks[#savedTracks + 1] = { track = track, time = track.TimePosition }
            track:Stop(0)
        end
    end
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.掉落中, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.自由落体, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.奔跑, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.坐下, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.攀爬, false)
    local duration = 0.45
    local steps = 120
    local startCFrame = hrp.CFrame
    local forwardVector = startCFrame.LookVector
    local upVector = Vector3.new(0, 1, 0)
    task.spawn(function()
        local startTime = tick()
        for i = 1, steps do
            local t = i / steps
            local height = jumpHeight * (t - t ^ 2)
            local nextPos = startCFrame.Position + forwardVector * (jumpDistance * t) + upVector * height    
            local rotation = startCFrame.Rotation * CFrame.Angles(-math.rad(i * (360 / steps)), 0, 0)

            hrp.CFrame = CFrame.new(nextPos) * rotation
            local elapsedTime = tick() - startTime
            local expectedTime = (duration / steps) * i
            local waitTime = expectedTime - elapsedTime
            if waitTime > 0 then
                task.wait(waitTime)
            end
        end

        hrp.CFrame = CFrame.new(startCFrame.Position + forwardVector * jumpDistance) * startCFrame.Rotation
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.掉落中, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.自由落体, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.奔跑, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.坐下, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.攀爬, true)
        Humanoid:ChangeState(Enum.HumanoidStateType.奔跑)

        if animator then
            for _, data in ipairs(savedTracks) do
                local track = data.track
                track:Play()
                track.TimePosition = data.time
            end
        end
        task.wait(0.25)
        ff_cd = false
    end)
end

local sausageHolder = nil
local originalSize = nil
local ff_button = nil

local function SetFrontFlip(bool)
    ff_enabled = bool
    if ff_enabled == true then
        pcall(function()
            sausageHolder = game.CoreGui.顶部栏应用.顶部栏应用.统一栏左框.统一栏菜单["2"]
            originalSize = sausageHolder.Size.X.Offset
            ff_button = Instance.new("Frame", sausageHolder)
            ff_button.Size = UDim2.new(0, 48, 0, 44)
            ff_button.BackgroundTransparency = 1
            ff_button.BorderSizePixel = 0
            ff_button.Position = UDim2.new(0, sausageHolder.Size.X.Offset - 48, 0, 0)
            
            local imageButton = Instance.new("ImageButton", ff_button)
            imageButton.BackgroundTransparency = 1
            imageButton.BorderSizePixel = 0
            imageButton.Size = UDim2.new(0, 36, 0, 36)
            imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
            imageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
            imageButton.Image = "rbxthumb://type=Asset&id=2714338264&w=150&h=150"
            
            ff_connection = imageButton.Activated:Connect(Flip)
            sausageHolder.Size = UDim2.new(0, originalSize + 48, 0, sausageHolder.Size.Y.Offset)
            task.wait()
            ff_button.Position = UDim2.new(0, sausageHolder.Size.X.Offset - 48, 0, 0)
            
            task.spawn(function()
                pcall(function()
                    repeat
                        sausageHolder.Size = UDim2.new(0, originalSize + 48, 0, sausageHolder.Size.Y.Offset)
                        task.wait()
                        ff_button.Position = UDim2.new(0, sausageHolder.Size.X.Offset - 48, 0, 0)
                    until ff_enabled == false
                end)
            end)
        end)
    elseif ff_enabled == false then
        if ff_connection then
            ff_connection:Disconnect()
            ff_connection = nil
        end
        if ff_button then
            ff_button:Destroy()
            ff_button = nil
        end
        if sausageHolder then
            sausageHolder.Size = UDim2.new(0, originalSize, 0, sausageHolder.Size.Y.Offset)
        end
    end
end

Tabs.Player:Section({Title = "前空翻"})



Tabs.Player:Toggle({
    Title = "显示前空翻按钮",
    Default = false,
    Callback = function(state)
        SetFrontFlip(state)
    end
})

Tabs.Player:Slider({
    Title = "跳跃高度",
    Step = 1,
    Value = {Min = 20, Max = 200, Default = jumpHeight},
    Suffix = "单位",
    Callback = function(val)
        jumpHeight = val
    end
})

Tabs.Player:Slider({
    Title = "跳跃距离",
    Step = 1,
    Value = {Min = 10, Max = 100, Default = jumpDistance},
    Suffix = "单位",
    Callback = function(val)
        jumpDistance = val
    end
})


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local voidrushcontrol = false
local DASH_SPEED = 80
local ATTACK_RANGE = 6
local ATTACK_INTERVAL = 0.2

-- 添加范围变量
local aimDistance = 50

local isOverrideActive = false
local connection
local Humanoid, RootPart
local lastState = nil
local attackingLoop = nil

local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("幸存者")

local function isPriorityTarget(p)
    if not p or not p.Character then return false end
    return survivorsFolder:FindFirstChild(p.Name) ~= nil
end

local function setupCharacter(character)
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")
    Humanoid.Died:Connect(function()
        isOverrideActive = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if attackingLoop then
            task.cancel(attackingLoop)
            attackingLoop = nil
        end
        if RootPart then
            RootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

local function validTarget(p)
    if p == LocalPlayer then return false end
    local c = p.Character
    if not c then return false end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChild("Humanoid")
    return hrp and hum and hum.Health > 0
end

local function getClosestTarget()
    if not RootPart then return nil end

    local closestW, distW = nil, math.huge
    local closestA, distA = nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if validTarget(p) then
            local c = p.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - RootPart.Position).Magnitude
                -- 添加距离限制
                if d <= aimDistance then
                    if isPriorityTarget(p) and d < distW then
                        distW = d
                        closestW = p
                    end
                    if d < distA then
                        distA = d
                        closestA = p
                    end
                end
            end
        end
    end

    return closestW or closestA, distW < math.huge and distW or distA
end

local function attemptAttack()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool.Parent == char then
        pcall(function() tool:Activate() end)
    end
end

local function startOverride()
    if isOverrideActive or not Humanoid or not RootPart then return end
    isOverrideActive = true

    connection = RunService.RenderStepped:Connect(function()
        if not Humanoid or not RootPart or Humanoid.Health <= 0 then return end
        local target, dist = getClosestTarget()

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local dir = hrp.Position - RootPart.Position
            local horizontal = Vector3.new(dir.X, 0, dir.Z)

            if horizontal.Magnitude > 0.1 then
                RootPart.CFrame = CFrame.new(RootPart.Position, Vector3.new(hrp.Position.X, RootPart.Position.Y, hrp.Position.Z))
                RootPart.AssemblyLinearVelocity = horizontal.Unit * DASH_SPEED
            else
                RootPart.AssemblyLinearVelocity = Vector3.zero
            end
        else
            RootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    attackingLoop = task.spawn(function()
        while isOverrideActive do
            local target, dist = getClosestTarget()
            if target and dist and dist <= ATTACK_RANGE then
                attemptAttack()
            end
            task.wait(ATTACK_INTERVAL)
        end
    end)
end

local function stopOverride()
    if not isOverrideActive then return end
    isOverrideActive = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if attackingLoop then
        task.cancel(attackingLoop)
        attackingLoop = nil
    end
    if RootPart then
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

RunService.RenderStepped:Connect(function()
    if not voidrushcontrol or not Humanoid then return end
    local state = Humanoid.Parent and Humanoid.Parent:GetAttribute("虚空冲刺状态")
    if state ~= lastState then
        lastState = state
        if state == "冲刺中" then
            startOverride()
        else
            stopOverride()
        end
    end
end)


Tabs.kill:Section({Title = "诺丽"})

Tabs.kill:Toggle({
    Title = "虚空冲刺瞄准",
    Default = false,
    Callback = function(state)
        voidrushcontrol = state
        if not state then
            stopOverride()
        end
    end
})

Tabs.kill:Slider({
    Title = "自瞄范围",
    Step = 5,
    Value = {Min = 10, Max = 100, Default = aimDistance},
    Suffix = "距离单位",
    Callback = function(val)
        aimDistance = val
    end
})





local toggleOn = false
local toggleFlag = Instance.new("BoolValue")
toggleFlag.Name = "1x1x1x1自动瞄准_开关标志"
toggleFlag.Value = false

local aimMode = "单一目标"
local predictMovement = false
-- 添加预测系数变量
local predictFactor = 3

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local workspacePlayers = workspace:WaitForChild("Players")
local survivorsFolder = workspacePlayers:WaitForChild("幸存者")

local dangerousAnimations = {
    ["131430497821198"] = true,
    ["100592913030351"] = true,
    ["70447634862911"]  = true,
    ["83685305553364"] = true
}

local killerModels = {["1x1x1x1"] = true}

local autoRotateDisabledByScript = false
local currentTarget, isLockedOn, wasPlayingAnimation = nil, false, false

local function isKiller()
    local char = localPlayer.Character
    return char and killerModels[char.Name] or false
end

local function getMyHumanoid()
    local char = localPlayer.Character
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function restoreAutoRotate()
    local hum = getMyHumanoid()
    if hum and autoRotateDisabledByScript then
        hum.AutoRotate = true
        autoRotateDisabledByScript = false
    end
end

local function isPlayingDangerousAnimation()
    local humanoid = getMyHumanoid()
    if not humanoid then return false end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local animId = tostring(track.Animation.AnimationId):match("%d+")
        if animId and dangerousAnimations[animId] then
            return true
        end
    end
    return false
end

local function getClosestSurvivor()
    local myHumanoid = getMyHumanoid()
    if not myHumanoid then return nil end
    local myRoot = myHumanoid.Parent and myHumanoid.Parent:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest, closestDist = nil, math.huge

    for _, obj in ipairs(survivorsFolder:GetChildren()) do
        if obj:IsA("Model") then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < closestDist then
                    closest = obj
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

localPlayer.CharacterAdded:Connect(function()
    task.delay(0.1, function()
        autoRotateDisabledByScript = false
    end)
end)

RunService.RenderStepped:Connect(function()
    if not toggleFlag.Value then
        restoreAutoRotate()
        currentTarget, isLockedOn, wasPlayingAnimation = nil, false, false
        return
    end

    if not isKiller() then
        restoreAutoRotate()
        currentTarget, isLockedOn, wasPlayingAnimation = nil, false, false
        return
    end

    local myHumanoid = getMyHumanoid()
    if not myHumanoid then return end
    local myRoot = myHumanoid.Parent and myHumanoid.Parent:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local isPlaying = isPlayingDangerousAnimation()

    if isPlaying and not isLockedOn then
        currentTarget = getClosestSurvivor()
        if currentTarget then isLockedOn = true end
    end

    if isLockedOn and currentTarget then
        local tHum = currentTarget:FindFirstChildWhichIsA("Humanoid")
        local tHrp = currentTarget:FindFirstChild("HumanoidRootPart")
        if (not tHum) or (tHum and tHum.Health <= 0) or (not tHrp) then
            currentTarget, isLockedOn = nil, false
        end
    end

    if (not isPlaying) and wasPlayingAnimation then
        currentTarget, isLockedOn = nil, false
        restoreAutoRotate()
    end
    wasPlayingAnimation = isPlaying

    if isPlaying and isLockedOn and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
        local hrp = currentTarget.HumanoidRootPart
        local targetPos = hrp.Position

        if not autoRotateDisabledByScript then
            myHumanoid.AutoRotate = false
            autoRotateDisabledByScript = true
        end

        if predictMovement then
            local vel = hrp.Velocity
            if vel.Magnitude > 2 then
                -- 使用预测系数
                targetPos = targetPos + hrp.CFrame.LookVector * predictFactor
            end
        end

        local lookAt = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)

        if aimMode == "单一目标" then
            myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(myRoot.Position, lookAt), 0.99)

        elseif aimMode == "多目标" then
            local newTarget = getClosestSurvivor()
            if newTarget then currentTarget = newTarget end
            myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(myRoot.Position, lookAt), 0.99)

        elseif aimMode == "传送" then
            local behindPos = hrp.Position - hrp.CFrame.LookVector * 3
            myRoot.CFrame = CFrame.new(behindPos, targetPos)
        end
    end
end)

Tabs.kill:Section({Title = "1x1x1x1"})


Tabs.kill:Dropdown({
    Title = "瞄准模式",
    Values = {"单一目标", "多目标", "传送"},
    Multi = false,
    AllowNone = false,
    Callback = function(selected)
        aimMode = selected
    end
})

Tabs.kill:Toggle({
    Title = "大规模感染瞄准",
    Default = false,
    Callback = function(state)
        toggleOn = state
        toggleFlag.Value = state
    end
})

Tabs.kill:Toggle({
    Title = "预测移动",
    Default = false,
    Callback = function(state)
        predictMovement = state
    end
})

Tabs.kill:Slider({
    Title = "预测系数",
    Step = 0.5,
    Value = {Min = 1, Max = 10, Default = predictFactor},
    Suffix = "系数",
    Callback = function(val)
        predictFactor = val
    end
})



Tabs.Anti:Section({Title = "通用反效果"})

local antiFeatures = {
    no1x = false,
    healthGlitch = false,
    stun = false,
    slow = false,
    blindness = false,
    subspace = false,
    footsteps = false,
    hiddenStats = false
}

-- 反1x1x1x1弹窗
Tabs.Anti:Toggle({
    Title = "反1x1x1x1弹窗",
    Default = false,
    Callback = function(state)
        antiFeatures.no1x = state
        if state then
            task.spawn(function()
                while antiFeatures.no1x do
                    task.wait(0.5)
                    local temp = LocalPlayer.PlayerGui:FindFirstChild("临时界面")
                    if temp and temp:FindFirstChild("1x1x1x1弹窗") then
                        pcall(function()
                            if firesignal then
                                firesignal(temp["1x1x1x1弹窗"].MouseButton1Click)
                            end
                        end)
                    end
                end
            end)
        end
    end
})

-- 反生命值错误
Tabs.Anti:Toggle({
    Title = "反生命值错误",
    Default = false,
    Callback = function(state)
        antiFeatures.healthGlitch = state
        if state then
            task.spawn(function()
                while antiFeatures.healthGlitch do
                    task.wait(1)
                    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("临时界面")
                    if tempUI then
                        for _, v in pairs(tempUI:GetChildren()) do
                            if v.Name == "框架" and v:FindFirstChild("故障") then
                                v:Destroy()
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- 反眩晕
Tabs.Anti:Toggle({
    Title = "反眩晕",
    Default = false,
    Callback = function(state)
        antiFeatures.stun = state
        if state then
            task.spawn(function()
                while antiFeatures.stun do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("速度倍率") then
                        local stunned = char.速度倍率:FindFirstChild("眩晕")
                        if stunned and stunned.Value ~= 1 then
                            stunned.Value = 1
                        end
                    end
                end
            end)
        end
    end
})

-- 反减速
Tabs.Anti:Toggle({
    Title = "反减速",
    Default = false,
    Callback = function(state)
        antiFeatures.slow = state
        if state then
            task.spawn(function()
                while antiFeatures.slow do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("速度倍率") then
                        for _, v in pairs(char.速度倍率:GetChildren()) do
                            if v:IsA("NumberValue") and v.Value < 1 then
                                v.Value = 1
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- 反致盲
Tabs.Anti:Toggle({
    Title = "反致盲",
    Default = false,
    Callback = function(state)
        antiFeatures.blindness = state
        if state then
            task.spawn(function()
                while antiFeatures.blindness do
                    task.wait(0.5)
                    if Lighting:FindFirstChild("致盲模糊") then
                        Lighting.致盲模糊:Destroy()
                    end
                end
            end)
        end
    end
})

-- 反子空间
Tabs.Anti:Toggle({
    Title = "反子空间",
    Default = false,
    Callback = function(state)
        antiFeatures.subspace = state
        if state then
            task.spawn(function()
                while antiFeatures.subspace do
                    task.wait(0.5)
                    local subspaceEffects = {"子空间特效模糊", "子空间特效颜色校正"}
                    for _, effectName in ipairs(subspaceEffects) do
                        if Lighting:FindFirstChild(effectName) then
                            Lighting[effectName]:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

-- 反脚步声
Tabs.Anti:Toggle({
    Title = "反脚步声",
    Default = false,
    Callback = function(state)
        antiFeatures.footsteps = state
        if state then
            task.spawn(function()
                while antiFeatures.footsteps do
                    task.wait(0.5)
                    for _, sound in ipairs(Workspace:GetDescendants()) do
                        if sound:IsA("Sound") and sound.Name:find("脚步声") then
                            sound.Volume = 0
                        end
                    end
                end
            end)
        end
    end
})


local originalPlayerValues = {}

Tabs.Anti:Toggle({
    Title = "反隐藏数据",
    Default = false,
    Callback = function(state)
        antiFeatures.hiddenStats = state
        
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(function()
                if not player.PlayerData or not player.PlayerData.设置 or not player.PlayerData.设置.隐私 then return end
                
                if state then
                    -- 保存原始值
                    if not originalPlayerValues[player.UserId] then
                        originalPlayerValues[player.UserId] = {}
                    end
                    
                    local privacy = player.PlayerData.设置.隐私
                    for _, key in ipairs({"隐藏杀手胜场", "隐藏游戏时间", "隐藏幸存者胜场"}) do
                        local value = privacy:FindFirstChild(key)
                        if value then
                            originalPlayerValues[player.UserId][key] = value.Value
                            value.Value = false
                        end
                    end
                else
                    -- 恢复原始值
                    if originalPlayerValues[player.UserId] then
                        local privacy = player.PlayerData.设置.隐私
                        for key, val in pairs(originalPlayerValues[player.UserId]) do
                            local value = privacy:FindFirstChild(key)
                            if value then value.Value = val end
                        end
                    end
                end
            end)
        end
        
        -- 监听新玩家加入
        if state then
            Players.PlayerAdded:Connect(function(player)
                if antiFeatures.hiddenStats then
                    task.wait(1)
                    pcall(function()
                        if player.PlayerData and player.PlayerData.设置 and player.PlayerData.设置.隐私 then
                            local privacy = player.PlayerData.设置.隐私
                            for _, key in ipairs({"隐藏杀手胜场", "隐藏游戏时间", "隐藏幸存者胜场"}) do
                                local value = privacy:FindFirstChild(key)
                                if value then value.Value = false end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

	
	
	end,
	DoubleClick = true,
	Tooltip = "加载",
	DisabledTooltip = "已禁用！",
	Disabled = false,
	Visible = true,
	Risky = false,
})

new:AddLabel("双击加载")

new:AddLabel("[+]开发 宇宙尘")



local MainTabbox = Tabs.Main:AddLeftTabbox()
local Lighting = MainTabbox:AddTab("亮度控制")
local Camera = MainTabbox:AddTab("视野")

local lightingConnection
local cameraConnection

Lighting:AddSlider("B", {
    Text = "亮度值",
    Min = 0,
    Default = 0,
    Max = 3,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        _env.Brightness = v
    end
})

Lighting:AddCheckbox("No Shadows", {
    Text = "无阴影",
    Default = false,
    Callback = function(v)
        _env.GlobalShadows = v
    end
})

Lighting:AddCheckbox("Demisting", {
    Text = "去雾",
    Default = false,
    Callback = function(v)
        _env.NoFog = v
    end
})

Lighting:AddDivider()

Lighting:AddCheckbox("Enable Features", {
    Text = "启用功能",
    Default = false,
    Callback = function(v)
        _env.Fullbright = v
        
        if lightingConnection then
            lightingConnection:Disconnect()
            lightingConnection = nil
        end
        
        if v then
            lightingConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not game.Lighting:GetAttribute("雾起始") then 
                    game.Lighting:SetAttribute("雾起始", game.Lighting.FogStart) 
                end
                if not game.Lighting:GetAttribute("雾结束") then 
                    game.Lighting:SetAttribute("雾结束", game.Lighting.FogEnd) 
                end
                
                game.Lighting.FogStart = _env.NoFog and 0 or game.Lighting:GetAttribute("雾起始")
                game.Lighting.FogEnd = _env.NoFog and math.huge or game.Lighting:GetAttribute("雾结束")
                
                local fog = game.Lighting:FindFirstChildOfClass("Atmosphere")
                if fog then
                    if not fog:GetAttribute("密度") then 
                        fog:SetAttribute("密度", fog.Density) 
                    end
                    fog.Density = _env.NoFog and 0 or fog:GetAttribute("密度")
                end
                
                game.Lighting.OutdoorAmbient = Color3.new(1,1,1)
                game.Lighting.Brightness = _env.Brightness or 0
                game.Lighting.GlobalShadows = not _env.GlobalShadows
            end)
        else
            game.Lighting.OutdoorAmbient = Color3.fromRGB(55,55,55)
            game.Lighting.Brightness = 0
            game.Lighting.GlobalShadows = true
        end
    end
})

Camera:AddSlider("FieldOfView", {
    Text = "视野 (FOV)",
    Default = 80,
    Min = 0,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        _G.CurrentFOV = Value
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.FieldOfView = Value
        end
    end,
})


Camera:AddToggle("CustomFOVToggle", {
    Text = "启用视野",
    Default = false,
    Callback = function(Value)
        _G.CustomFOVEnabled = Value
        if Value then
            local Camera = workspace.CurrentCamera
            if Camera then
                Camera.FieldOfView = Options.FieldOfView.Value
            end
        end
    end,
})




local V = Tabs.Main:AddLeftGroupbox('圣诞节 🎄 (姜饼人)')


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local autoCandyConnection = nil
local lastTeleportTime = 0

local function teleportToRandomCandy()
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local targetFolder = Workspace:FindFirstChild("地图")
    if targetFolder then
        targetFolder = targetFolder:FindFirstChild("游戏内")
        if targetFolder then
            targetFolder = targetFolder:FindFirstChild("货币位置")
        end
    end
    
    if not targetFolder then return end
    
    local candyModels = {}
    for _, child in ipairs(targetFolder:GetChildren()) do
        if child:IsA("Model") or child:IsA("Part") or child:IsA("MeshPart") then
            table.insert(candyModels, child)
        end
    end
    
    if #candyModels > 0 then
        local randomCandy = candyModels[math.random(1, #candyModels)]
        
        local targetPosition
        if randomCandy:IsA("Model") then
            local primaryPart = randomCandy.PrimaryPart
            if primaryPart then
                targetPosition = primaryPart.Position
            else
                for _, part in ipairs(randomCandy:GetChildren()) do
                    if part:IsA("BasePart") then
                        targetPosition = part.Position
                        break
                    end
                end
            end
        else
            targetPosition = randomCandy.Position
        end
        
        if targetPosition then
            humanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))
        end
    end
end

V:AddToggle('AutoCandyToggle', {
    Text = '姜饼人农场',
    Default = false,
    Callback = function(value)
        if value then
            autoCandyConnection = RunService.Heartbeat:Connect(function()
                if tick() - lastTeleportTime >= 2 then
                    lastTeleportTime = tick()
                    teleportToRandomCandy()
                end
            end)
        else
            if autoCandyConnection then
                autoCandyConnection:Disconnect()
                autoCandyConnection = nil
            end
        end
    end
})

V:AddToggle('CandyToggle', {
    Text = '姜饼人透视',
    Default = false,
    Callback = function(state)
        if state then
            CandyConnection = workspace.DescendantAdded:Connect(function(v)
                local currencyFolder = workspace:FindFirstChild("地图")
                if currencyFolder then
                    currencyFolder = currencyFolder:FindFirstChild("游戏内")
                    if currencyFolder then
                        currencyFolder = currencyFolder:FindFirstChild("货币位置")
                        if currencyFolder and v:IsDescendantOf(currencyFolder) and v:IsA("Model") then
                            local adornee = v
                            if v.PrimaryPart then
                                adornee = v.PrimaryPart
                            elseif v:FindFirstChildOfClass("Part") then
                                adornee = v:FindFirstChildOfClass("Part")
                            end
                            
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "姜饼人标签"
                            billboard.Parent = v
                            billboard.Adornee = adornee
                            billboard.Size = UDim2.new(0, 80, 0, 30)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true

                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Parent = billboard
                            nameLabel.Size = UDim2.new(1, 0, 1, 0)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.Text = "姜饼人"
                            nameLabel.TextColor3 = _G.CandyTextColor or Color3.new(0, 0.5, 1)
                            nameLabel.TextStrokeTransparency = 0.2
                            nameLabel.TextScaled = false
                            nameLabel.TextSize = 16
                            nameLabel.Font = Enum.Font.Oswald
                            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                            
                            local cleanupConnection
                            cleanupConnection = v.AncestryChanged:Connect(function()
                                if not v.Parent then
                                    if cleanupConnection then
                                        cleanupConnection:Disconnect()
                                    end
                                    if billboard and billboard.Parent then
                                        billboard:Destroy()
                                    end
                                end
                            end)
                            
                            local removalConnection
                            removalConnection = v.Destroying:Connect(function()
                                if removalConnection then
                                    removalConnection:Disconnect()
                                end
                                if cleanupConnection then
                                    cleanupConnection:Disconnect()
                                end
                                if billboard and billboard.Parent then
                                    billboard:Destroy()
                                end
                            end)
                        end
                    end
                end
            end)

            local currencyFolder = workspace:FindFirstChild("地图")
            if currencyFolder then
                currencyFolder = currencyFolder:FindFirstChild("游戏内")
                if currencyFolder then
                    currencyFolder = currencyFolder:FindFirstChild("货币位置")
                    if currencyFolder then
                        for i, v in pairs(currencyFolder:GetDescendants()) do
                            if v:IsA("Model") then
                                local adornee = v
                                if v.PrimaryPart then
                                    adornee = v.PrimaryPart
                                elseif v:FindFirstChildOfClass("Part") then
                                    adornee = v:FindFirstChildOfClass("Part")
                                end
                                
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "姜饼人标签"
                                billboard.Parent = v
                                billboard.Adornee = adornee
                                billboard.Size = UDim2.new(0, 80, 0, 30)
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                billboard.AlwaysOnTop = true

                                local nameLabel = Instance.new("TextLabel")
                                nameLabel.Parent = billboard
                                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                                nameLabel.BackgroundTransparency = 1
                                nameLabel.Text = "饼干 [圣诞节 🎄]"
                                nameLabel.TextColor3 = _G.CandyTextColor or Color3.new(0, 0.5, 1)
                                nameLabel.TextStrokeTransparency = 0.2
                                nameLabel.TextScaled = false
                                nameLabel.TextSize = 16
                                nameLabel.Font = Enum.Font.Oswald
                                nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                                
                                local cleanupConnection
                                cleanupConnection = v.AncestryChanged:Connect(function()
                                    if not v.Parent then
                                        if cleanupConnection then
                                            cleanupConnection:Disconnect()
                                        end
                                        if billboard and billboard.Parent then
                                            billboard:Destroy()
                                        end
                                    end
                                end)
                                
                                local removalConnection
                                removalConnection = v.Destroying:Connect(function()
                                    if removalConnection then
                                        removalConnection:Disconnect()
                                    end
                                    if cleanupConnection then
                                        cleanupConnection:Disconnect()
                                    end
                                    if billboard and billboard.Parent then
                                        billboard:Destroy()
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        else
            if CandyConnection then
                CandyConnection:Disconnect()
            end
            
            for i, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("姜饼人标签") then
                    v.姜饼人标签:Destroy()
                end
            end
        end
    end
}):AddColorPicker("CandyColorPicker", {
    Default = Color3.new(0, 0.5, 1),
    Title = "饼干标记颜色",
    Transparency = 0,
    Callback = function(Value)
        _G.CandyTextColor = Value
        
        if Toggles.CandyToggle.Value then
            for i, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("姜饼人标签") then
                    local billboard = v.姜饼人标签
                    if billboard:FindFirstChildOfClass("TextLabel") then
                        billboard:FindFirstChildOfClass("TextLabel").TextColor3 = Value
                    end
                end
            end
        end
    end
})


local KillerSurvival = Tabs.Main:AddLeftGroupbox('聊天框可见')

KillerSurvival:AddCheckbox('AlwaysShowChat', {
        Text = "显示聊天框",
        Callback = function(state)
            if state then
                _G.showChat = true
                task.spawn(function()
                    while _G.showChat and task.wait() do
                        game:GetService("TextChatService"):FindFirstChildOfClass("聊天窗口配置").Enabled = true
                    end
                end)
            else
                _G.showChat = false
                if playingState ~= "观战中" then
                    game:GetService("TextChatService"):FindFirstChildOfClass("聊天窗口配置").Enabled = false
                end
            end
        end
    })

    function panic()
        for i, v in pairs(Toggles) do
            pcall(function()
                if v.Value == false then return end
                v:SetValue(false)
            end)
        end
    end

    Library:OnUnload(function()
        _G.VoidsakenExecuted = false
        panic()
        getgenv().FlipUI:Destroy()
        getgenv().AimbotUI:Destroy()
        getgenv().BlockUI:Destroy()
    end)








local ZZ = Tabs.Main:AddLeftGroupbox('自动拾取物品')


ZZ:AddCheckbox('Medical PACKAGE TRANSFER AND PICK UP', {
    Text = '医疗包传送拾取',
    Default = false,
    Tooltip = '自动传送医疗包到身边并交互',
    
    Callback = function(state)
        autoTeleportMedkitEnabled = state
        
        if autoTeleportMedkitEnabled then
            teleportMedkitThread = task.spawn(function()
                while autoTeleportMedkitEnabled and task.wait(0.5) do
                  
                    local character = game.Players.LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        
                      
                        local medkit = workspace:FindFirstChild("地图", true)
                        if medkit then
                            medkit = medkit:FindFirstChild("游戏内", true)
                            if medkit then
                                medkit = medkit:FindFirstChild("医疗包", true)
                                if medkit then
                                    local itemRoot = medkit:FindFirstChild("物品根", true)
                                    if itemRoot then
                                       
                                        itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 1
                                        
                                       
                                        local prompt = itemRoot:FindFirstChild("近距离提示", true)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        elseif teleportMedkitThread then
            task.cancel(teleportMedkitThread)
            teleportMedkitThread = nil
        end
    end
})


ZZ:AddCheckbox('Coke transfer and pick up', {
    Text = '可乐传送拾取',
    Default = false,
    Tooltip = '自动传送可乐到身边并交互',
    
    Callback = function(state)
        autoTeleportColaEnabled = state
        
        if autoTeleportColaEnabled then
            teleportColaThread = task.spawn(function()
                while autoTeleportColaEnabled and task.wait(0.5) do
                    -- 获取玩家角色
                    local character = game.Players.LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        
                        -- 查找可乐
                        local cola = workspace:FindFirstChild("地图", true)
                        if cola then
                            cola = cola:FindFirstChild("游戏内", true)
                            if cola then
                                cola = cola:FindFirstChild("可乐", true)
                                if cola then
                                    local itemRoot = cola:FindFirstChild("物品根", true)
                                    if itemRoot then
                                    
                                        itemRoot.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 1
                                        
                                       
                                        local prompt = itemRoot:FindFirstChild("近距离提示", true)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        elseif teleportColaThread then
            task.cancel(teleportColaThread)
            teleportColaThread = nil
        end
    end
})









local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MVP = Tabs.Sat:AddLeftGroupbox("体力设置")

local StaminaSettings = {
    MaxStamina = 100,
    StaminaGain = 25,
    StaminaLoss = 10,
    SprintSpeed = 28,
    InfiniteGain = 9999
}

local SettingToggles = {
    MaxStamina = false,
    StaminaGain = false,
    StaminaLoss = false,
    SprintSpeed = false
}

local SprintingModule = ReplicatedStorage:WaitForChild("系统"):WaitForChild("角色"):WaitForChild("游戏"):WaitForChild("冲刺")
local GetModule = function() return require(SprintingModule) end

task.spawn(function()
    while true do
        local m = GetModule()
        for key, value in pairs(StaminaSettings) do
            if SettingToggles[key] then
                m[key] = value
            end
        end
        task.wait(0.5)
    end
end)

local bai = {Spr = false}
local connection

MVP:AddCheckbox('MyToggle', {
    Text = '无限体力',
    Default = false,
    Tooltip = '无限体力',
    Callback = function(state)
        bai.Spr = state
        local Sprinting = GetModule()

        if state then
            Sprinting.StaminaLoss = 0
            Sprinting.StaminaGain = StaminaSettings.InfiniteGain

            if connection then connection:Disconnect() end
            connection = RunService.Heartbeat:Connect(function()
                if not bai.Spr then return end
                Sprinting.StaminaLoss = 0
                Sprinting.StaminaGain = StaminaSettings.InfiniteGain
            end)
        else
            Sprinting.StaminaLoss = 10
            Sprinting.StaminaGain = 25

            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

MVP:AddCheckbox('MaxStaminaToggle', {
    Text = '启用体力值调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.MaxStamina = Value
    end
})

MVP:AddCheckbox('StaminaGainToggle', {
    Text = '启用体力恢复调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.StaminaGain = Value
    end
})

MVP:AddCheckbox('StaminaLossToggle', {
    Text = '启用体力消耗调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.StaminaLoss = Value
    end
})

MVP:AddCheckbox('SprintSpeedToggle', {
    Text = '启用奔跑速度调整',
    Default = false,
    Callback = function(Value)
        SettingToggles.SprintSpeed = Value
    end
})

local MVP2 = Tabs.Sat:AddRightGroupbox("调试设置")

MVP2:AddSlider('InfStaminaGainSlider', {
    Text = '无限体力恢复速度',
    Default = 9999,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.InfiniteGain = Value
        if bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaGain = Value
        end
    end
})

MVP2:AddSlider('MySlider1', {
    Text = '最大体力值',
    Default = 100,
    Min = 0,
    Max = 9999,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.MaxStamina = Value
        if SettingToggles.MaxStamina then
            local Sprinting = GetModule()
            Sprinting.MaxStamina = Value
        end
    end
})

MVP2:AddSlider('MySlider2', {
    Text = '体力恢复速度',
    Default = 25,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.StaminaGain = Value
        if SettingToggles.StaminaGain and not bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaGain = Value
        end
    end
})

MVP2:AddSlider('MySlider3', {
    Text = '体力消耗速度',
    Default = 10,
    Min = 0,
    Max = 800,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.StaminaLoss = Value
        if SettingToggles.StaminaLoss and not bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaLoss = Value
        end
    end
})

MVP2:AddSlider('MySlider4', {
    Text = '奔跑速度',
    Default = 28,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.SprintSpeed = Value
        if SettingToggles.SprintSpeed then
            local Sprinting = GetModule()
            Sprinting.SprintSpeed = Value
        end
    end
})






local RunService = game:GetService("RunService")

local function getDirection(currentRow, currentCol, otherRow, otherCol)
   if otherRow < currentRow then return "上" end
   if otherRow > currentRow then return "下" end
   if otherCol < currentCol then return "左" end
   if otherCol > currentCol then return "右" end
end

local function getConnections(prev, curr, nextnode)
   local connections = {}
   if prev and curr then
       local dir = getDirection(curr.row, curr.col, prev.row, prev.col)
       if dir == "上" then dir = "下"
       elseif dir == "下" then dir = "上"
       elseif dir == "左" then dir = "右"
       elseif dir == "右" then dir = "左" end
       if dir then connections[dir] = true end
   end
   if nextnode and curr then
       local dir = getDirection(curr.row, curr.col, nextnode.row, nextnode.col)
       if dir then connections[dir] = true end
   end
   return connections
end

local function isNeighbourLocal(r1, c1, r2, c2)
   if r2 == r1 - 1 and c2 == c1 then return "上" end
   if r2 == r1 + 1 and c2 == c1 then return "下" end
   if r2 == r1 and c2 == c1 - 1 then return "左" end
   if r2 == r1 and c2 == c1 + 1 then return "右" end
   return false
end

local function coordKey(node)
   return `{node.row}-{node.col}`
end

local function orderPathFromEndpoints(path, endpoints)
   if not path or #path == 0 then return path end
   
   local startEndpoint
   for _, ep in endpoints or {} do
       for _, n in path do
           if n.row == ep.row and n.col == ep.col then
               startEndpoint = { row = ep.row, col = ep.col }
               break
           end
       end
       if startEndpoint then break end
   end
   
   if not startEndpoint then
       local inPath = {}
       for _, n in path do inPath[coordKey(n)] = n end
       
       for _, n in path do
           local neighbours = 0
           local dirs = { { n.row - 1, n.col }, { n.row + 1, n.col }, { n.row, n.col - 1 }, { n.row, n.col + 1 } }
           for _, dir in dirs do
               local r, c = dir[1], dir[2]
               if inPath[`{r}-{c}`] then neighbours += 1 end
           end
           if neighbours == 1 then
               startEndpoint = { row = n.row, col = n.col }
               break
           end
       end
   end
   
   if not startEndpoint then
       startEndpoint = { row = path[1].row, col = path[1].col }
   end
   
   local remaining = {}
   for _, n in path do remaining[coordKey(n)] = { row = n.row, col = n.col } end
   
   local ordered = {}
   local current = { row = startEndpoint.row, col = startEndpoint.col }
   table.insert(ordered, table.clone(current))
   remaining[coordKey(current)] = nil
   
   while true do
       local _size = 0
       for _ in remaining do _size += 1 end
       if not (_size > 0) then break end
       
       local foundNext = false
       for key, node in remaining do
           local _value = isNeighbourLocal(current.row, current.col, node.row, node.col)
           if _value then
               table.insert(ordered, table.clone(node))
               remaining[key] = nil
               current = node
               foundNext = true
               break
           end
       end
       if not foundNext then return path end
   end
   return ordered
end

local HintSystem = {}
do
   function HintSystem:DrawSolutionOneByOne(puzzle, delayTime)
       delayTime = delayTime or 0.05
       if not puzzle or not puzzle.解决方案 then return end
       
       local totalPaths = #puzzle.解决方案
       local indices = {}
       for i = 1, totalPaths do table.insert(indices, i) end
       
       for i = totalPaths, 2, -1 do
           local j = math.random(i)
           indices[i], indices[j] = indices[j], indices[i]
       end
       
       for _, colorIndex in indices do
           local path = puzzle.解决方案[colorIndex]
           local endpoints = puzzle.目标配对[colorIndex]
           local orderedPath = orderPathFromEndpoints(path, endpoints)
           puzzle.paths[colorIndex] = {}
           
           puzzle.gridConnections = puzzle.gridConnections or {}
           
           for i = 1, #orderedPath do
               local node = orderedPath[i]
               table.insert(puzzle.paths[colorIndex], { row = node.row, col = node.col })
               local prev = orderedPath[i - 1]
               local nextNode = orderedPath[i + 1]
               local conn = getConnections(prev, node, nextNode)
               
               puzzle.gridConnections[`{node.row}-{node.col}`] = conn
               
               if i % 5 == 0 or i == #orderedPath then
                   puzzle:更新界面()
                   task.wait(delayTime)
               end
           end
           
           puzzle:检查胜利()
           task.wait(delayTime * 0.5)
       end
       
       puzzle:更新界面()
       puzzle:检查胜利()
   end
end



local Generator = Tabs.zdx:AddLeftGroupbox("自动修机/互动 (事件)")


Generator:AddSlider("RepairSpeed", {
    Text = "修理速度 (秒)",
    Default = 4,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(v)
        _G.CustomSpeed = v
    end
})

Generator:AddToggle("AutoGenerator",{
    Text = "自动修机",
    Default = false,
    Callback = function(v)
        _G.AutoGen = v
        task.spawn(function()
            while _G.AutoGen do
                if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("拼图界面") then
                    local delayTime = _G.CustomSpeed or 4
                    
                    wait(delayTime)
                    
                    for _,v in ipairs(workspace["地图"]["游戏内"]["地图"]:GetChildren()) do
                        if v.Name == "发电机" then
                            v["远程"]["RE"]:FireServer()
                        end
                    end
                end
                wait()
            end
        end)
    end
})



local LeftGroupBox = Tabs.zdx:AddLeftGroupbox("自动修机 (连线)")
local AutoConnectEnabled = false
local ConnectionSpeed = 0.05

LeftGroupBox:AddCheckbox("AutoConnectToggle", {
   Text = "启用自动连线",
   Default = false,
   Callback = function(Value)
       AutoConnectEnabled = Value
       print("自动连线:", Value)
   end,
})

LeftGroupBox:AddSlider("ConnectionSpeed", {
   Text = "连线速度",
   Default = 0.05,
   Min = 0.001,
   Max = 0.2,
   Rounding = 3,
   Compact = false,
   Callback = function(Value)
       ConnectionSpeed = Value
       print("连线速度:", Value)
   end,
   Tooltip = "数值越小越快",
})

local _result = ReplicatedStorage:WaitForChild("模块"):FindFirstChild("杂项")
if _result then
   _result = _result:FindFirstChild("流游戏管理器")
   if _result then
       _result = _result:FindFirstChild("流游戏")
   end
end
local bb = _result
if bb then
   local FlowGameModule = require(bb)
   local old = FlowGameModule.new
   FlowGameModule.new = function(...)
       local args = { ... }
       local output = { old(unpack(args)) }
       local puzzle = output[1]
       task.spawn(function()
           if puzzle and puzzle.解决方案 and AutoConnectEnabled then
               local startTime = tick()
               while AutoConnectEnabled and tick() - startTime < 3 do 
                   if Players.LocalPlayer.PlayerGui:FindFirstChild("拼图界面") then
                       HintSystem:DrawSolutionOneByOne(puzzle, ConnectionSpeed)
                       break
                   end
                   task.wait(0.3) 
               end
           end
       end)
       return puzzle
   end
end


local KillerSurvival = Tabs.zdx:AddRightGroupbox('传送修机 [危险]')
KillerSurvival:AddButton({
    Text = '传送到发电机',
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local generators = workspace.地图.游戏内.地图:GetChildren()
        for _, generator in ipairs(generators) do
            if generator.Name == "发电机" and 
               generator:FindFirstChild("进度") and 
               generator.进度.Value < 100 then
                
                local generatorPart = generator:FindFirstChild("主体") or  
                                     generator:FindFirstChild("模型") or
                                     generator:FindFirstChild("底座")
                
                if generatorPart then
                    character.HumanoidRootPart.CFrame = generatorPart.CFrame + Vector3.new(0, 3, 0)
                    return  
                end
            end
        end
        warn("未找到可维修的发电机")
    end
})




local ZZ = Tabs.zdx:AddRightGroupbox('切换服务器')

ZZ:AddButton({
    Text = "切换服务器", 
    Func = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        
        local requestFunc = http_request or syn.request or request
        if not requestFunc then return end
            
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local response = requestFunc({Url = url, Method = "GET"})
        
        if response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.data and #data.data > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, data.data[math.random(1, #data.data)].id, Players.LocalPlayer)
            end
        end
    end
})
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MapFolder = Workspace:WaitForChild("地图"):WaitForChild("游戏内")

local Settings = {
	高级 = { Enabled = false, OutlineOnly = true, ShowNametag = false, Color = Color3.fromRGB(0, 255, 255) }
}

local Highlights = {}
local Nametags = {}

local AdvancedNames = {"建筑工放置器","建筑工哨兵","人形根投射物","剑","冲击波","虚空之星"}

local function CreateNametag(adornee, text, color)
	if Nametags[adornee] then Nametags[adornee]:Destroy() end
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = adornee
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = true
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0,0,0)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 6
	textLabel.Parent = billboard
	billboard.Parent = adornee
	Nametags[adornee] = textLabel
end

local function AddHighlight(Obj, Config)
	if Highlights[Obj] then Highlights[Obj]:Destroy() end
	local hl = Instance.new("Highlight")
	hl.Adornee = Obj
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Enabled = Config.Enabled
	hl.OutlineColor = Config.Color
	hl.FillColor = Config.Color
	hl.OutlineTransparency = 0
	local alwaysFill = table.find({"建筑工放置器","建筑工哨兵","披萨配送机器人","人形根投射物","剑","冲击波","虚空之星","暗影"}, Obj.Name)
	hl.FillTransparency = Config.OutlineOnly and 1 or (alwaysFill and 0.65 or 1)
	hl.Parent = Obj
	Highlights[Obj] = hl
	Obj.AncestryChanged:Connect(function(_, parent)
		if not parent then
			if Highlights[Obj] then Highlights[Obj]:Destroy() Highlights[Obj] = nil end
			if Nametags[Obj] then Nametags[Obj].Parent:Destroy() Nametags[Obj] = nil end
		end
	end)
end

local function ApplyToTarget(target, Config)
	if not target or not target.Parent then return end
	AddHighlight(target, Config)
end

local function HandleAdvanced(obj)
	if table.find(AdvancedNames, obj.Name) or (obj.Name == "暗影" and obj.Parent and obj.Parent.Name == "暗影") then
		ApplyToTarget(obj, Settings.高级)
	end
end

for _, v in ipairs(MapFolder:GetDescendants()) do HandleAdvanced(v) end
MapFolder.DescendantAdded:Connect(HandleAdvanced)

task.spawn(function()
	while task.wait(0.3) do
		for obj, hl in pairs(Highlights) do
			if not hl or not hl.Parent then continue end
			local config = Settings.高级
			hl.Enabled = config.Enabled
			hl.OutlineColor = config.Color
			hl.FillColor = config.Color
			hl.OutlineTransparency = 0
			hl.FillTransparency = config.OutlineOnly and 1 or 0.65
			if config.ShowNametag then
				local baseName = obj.Name
				local nameText = baseName
				if Nametags[obj] then
					Nametags[obj].Text = nameText
					Nametags[obj].TextColor3 = config.Color
				else
					CreateNametag(obj, nameText, config.Color)
				end
			else
				if Nametags[obj] then
					Nametags[obj].Parent:Destroy()
					Nametags[obj] = nil
				end
			end
		end
	end
end)

local AdvancedGroup = Tabs.Esp:AddRightGroupbox("技能透视", "boxes")

AdvancedGroup:AddCheckbox("AdvancedESP", {
	Text = "技能透视",
	Default = false,
	Callback = function(Value)
		Settings.高级.Enabled = Value
	end,
})

AdvancedGroup:AddCheckbox("AdvancedOutline", {
	Text = "轮廓",
	Default = true,
	Callback = function(Value)
		Settings.高级.OutlineOnly = Value
	end,
})

AdvancedGroup:AddCheckbox("AdvancedNametag", {
	Text = "显示名称",
	Default = false,
	Callback = function(Value)
		Settings.高级.ShowNametag = Value
	end,
})

AdvancedGroup:AddLabel("高级颜色"):AddColorPicker("AdvancedColor", {
	Default = Color3.fromRGB(0, 255, 255),
	Title = "颜色",
	Transparency = 0,
	Callback = function(Value)
		Settings.高级.Color = Value
	end,
})




local PlayerESPBox = Tabs.Esp:AddLeftGroupbox("玩家透视", "users")

PlayerESPBox:AddCheckbox("KillerESP", {
    Text = "杀手透视",
    Default = false,
    Callback = function(value)
        ESPSettings.killerESP = value
    end,
}):AddColorPicker("KillerColor", {
    Default = ESPSettings.killerColor,
    Title = "杀手颜色",
    Callback = function(value)
        ESPSettings.killerColor = value
    end,
})

PlayerESPBox:AddCheckbox("KillerSkinESP", {
    Text = "显示杀手皮肤名",
    Default = false,
    Tooltip = "在杀手名字后显示皮肤名",
    Callback = function(value)
        ESPSettings.killerSkinESP = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("KillerFillTransparency", {
    Text = "杀手填充透明度",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.killerFillTransparency = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("KillerOutlineTransparency", {
    Text = "杀手轮廓透明度",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.killerOutlineTransparency = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddDivider()

PlayerESPBox:AddCheckbox("SurvivorESP", {
    Text = "幸存者透视",
    Default = false,
    Callback = function(value)
        ESPSettings.playerESP = value
    end,
}):AddColorPicker("SurvivorColor", {
    Default = ESPSettings.survivorColor,
    Title = "幸存者颜色",
    Callback = function(value)
        ESPSettings.survivorColor = value
    end,
})

PlayerESPBox:AddCheckbox("SurvivorSkinESP", {
    Text = "显示幸存者皮肤名",
    Default = false,
    Tooltip ="在幸存者名字后显示皮肤名",
    Callback = function(value)
        ESPSettings.survivorSkinESP = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("SurvivorFillTransparency", {
    Text = "幸存者填充透明度",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.survivorFillTransparency = value
        UpdateAllPlayerESPText()
    end,
})

PlayerESPBox:AddSlider("SurvivorOutlineTransparency", {
    Text = "幸存者轮廓透明度",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = true,
    Callback = function(value)
        ESPSettings.survivorOutlineTransparency = value
        UpdateAllPlayerESPText()
    end,
})

-- 物品透视
local ObjectESPBox = Tabs.Esp:AddRightGroupbox("物品透视", "box")

ObjectESPBox:AddCheckbox("GeneratorESP", {
    Text = "发电机透视",
    Default = false,
    Callback = function(value)
        ESPSettings.generatorESP = value
    end,
}):AddColorPicker("GeneratorColor", {
    Default = ESPSettings.generatorColor,
    Title = "发电机颜色",
    Callback = function(value)
        ESPSettings.generatorColor = value
    end,
})




ObjectESPBox:AddCheckbox("ItemESP", {
    Text = "物品透视",
    Default = false,
    Callback = function(value)
        ESPSettings.itemESP = value
    end,
}):AddColorPicker("ItemColor", {
    Default = ESPSettings.itemColor,
    Title = "物品颜色",
    Callback = function(value)
        ESPSettings.itemColor = value
    end,
})

ObjectESPBox:AddCheckbox("PizzaESP", {
    Text = "披萨透视",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaEsp = value
    end,
}):AddColorPicker("PizzaColor", {
    Default = ESPSettings.pizzaColor,
    Title = "披萨颜色",
    Callback = function(value)
        ESPSettings.pizzaColor = value
    end,
})



-- 特殊透视
local SpecialESPBox = Tabs.Esp:AddRightGroupbox("特殊透视","zap")

SpecialESPBox:AddCheckbox("PizzaDeliveryESP", {
    Text = "披萨配送员 [酷小孩] 透视",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaDeliveryEsp = value
    end,
}):AddColorPicker("PizzaDeliveryColor", {
    Default = ESPSettings.pizzaDeliveryColor,
    Title = "披萨配送员颜色",
    Callback = function(value)
        ESPSettings.pizzaDeliveryColor = value
    end,
})

SpecialESPBox:AddCheckbox("ZombieESP", {
    Text = "僵尸[1x4]透视",
    Default = false,
    Callback = function(value)
        ESPSettings.zombieEsp = value
    end,
}):AddColorPicker("ZombieColor", {
    Default = ESPSettings.zombieColor,
    Title = "僵尸颜色",
    Callback = function(value)
        ESPSettings.zombieColor = value
    end,
})

SpecialESPBox:AddCheckbox("TripwireESP", {
    Text = "绊线透视",
    Default = false,
    Callback = function(value)
        ESPSettings.taphTripwireEsp = value
    end,
}):AddColorPicker("TripwireColor", {
    Default = ESPSettings.tripwireColor,
    Title = "绊线颜色",
    Callback = function(value)
        ESPSettings.tripwireColor = value
    end,
})

SpecialESPBox:AddCheckbox("TripMineESP", {
    Text = "地雷透视",
    Default = false,
    Callback = function(value)
        ESPSettings.tripMineEsp = value
    end,
}):AddColorPicker("TripMineColor", {
    Default = ESPSettings.tripMineColor,
    Title = "地雷颜色",
    Callback = function(value)
        ESPSettings.tripMineColor = value
    end,
})

SpecialESPBox:AddCheckbox("RespawnESP", {
    Text = "重生点透视",
    Default = false,
    Callback = function(value)
        ESPSettings.twoTimeRespawnEsp = value
    end,
}):AddColorPicker("RespawnColor", {
    Default = ESPSettings.respawnColor,
    Title = "重生点颜色",
    Callback = function(value)
        ESPSettings.respawnColor = value
    end,
})

-- 追踪线
local TracerBox = Tabs.Esp:AddRightGroupbox("追踪线", "spline")

TracerBox:AddCheckbox("KillerTracers", {
    Text = "杀手追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.killerTracers = value
    end,
})

TracerBox:AddCheckbox("SurvivorTracers", {
    Text = "幸存者追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.survivorTracers = value
    end,
})

TracerBox:AddCheckbox("GeneratorTracers", {
    Text = "发电机追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.generatorTracers = value
    end,
})

TracerBox:AddCheckbox("ItemTracers", {
    Text = "物品追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.itemTracers = value
    end,
})

TracerBox:AddCheckbox("PizzaTracers", {
    Text = "披萨追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaTracers = value
    end,
})

TracerBox:AddCheckbox("PizzaDeliveryTracers", {
    Text = "披萨配送员追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaDeliveryTracers = value
    end,
})

TracerBox:AddCheckbox("ZombieTracers", {
    Text = "僵尸追踪线",
    Default = false,
    Callback = function(value)
        ESPSettings.zombieTracers = value
    end,
})




local v437 = Tabs.ani:AddLeftGroupbox("通用反效果", "shield")





v437:AddToggle("AntiBlindness", {
    Text = "反致盲",
    Default = false,
    Callback = function()
        task.spawn(function()
            while Toggles.AntiBlindness.Value and task.wait() do
                if game.Lighting:FindFirstChild("致盲模糊") then
                    game.Lighting.致盲模糊:Destroy()
                end
            end
        end)
    end
})
v437:AddToggle("AntiSubspace", {
    Text = "反子空间爆炸",
    Default = false,
    Callback = function()
        task.spawn(function()
            while Toggles.AntiSubspace.Value and task.wait() do
                for _, v447 in pairs({"子空间特效模糊", "子空间特效颜色校正"}) do
                    if game.Lighting:FindFirstChild(v447) then
                        game.Lighting[v447]:Destroy()
                    end
                end
            end
        end)
    end
})


getgenv().activateRemoteHook = function(remoteName, blockedFirstArg)
   for _, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           return
       end
   end
   table.insert(getgenv().HookRules, {
       remoteName = remoteName,
       blockedFirstArg = blockedFirstArg,
       block = true
   })
end

getgenv().deactivateRemoteHook = function(remoteName, blockedFirstArg)
   for i, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           table.remove(getgenv().HookRules, i)
           break
       end
   end
end

getgenv().isFiringDusekkar = false

getgenv().EnableProtection = function()
   getgenv().activateRemoteHook("远程事件", game.Players.LocalPlayer.Name .. "杜塞克取消")
   if not getgenv().isFiringDusekkar then
       getgenv().isFiringDusekkar = true
       task.spawn(function()
           task.wait(4)
           local ReplicatedStorage = game:GetService("ReplicatedStorage")
           local RemoteEvent = ReplicatedStorage:WaitForChild("模块"):WaitForChild("网络"):WaitForChild("远程事件")
           RemoteEvent:FireServer({game.Players.LocalPlayer.Name .. "杜塞克取消"})
           getgenv().isFiringDusekkar = false
       end)
   end
end

getgenv().DisableProtection = function()
   getgenv().deactivateRemoteHook("远程事件", game.Players.LocalPlayer.Name .. "杜塞克取消")
end



local DusekkarGroup = Tabs.ani:AddLeftGroupbox("杜塞克", "user")

DusekkarGroup:AddCheckbox("ProtectionDusekkar", {
   Text = "防护",
   Default = false,
   Tooltip = "防止护盾被移除",
   Callback = function(Value)
       if Value then
           getgenv().EnableProtection()
       else
           getgenv().DisableProtection()
       end
   end
})



local ZZ2 = Tabs.ani:AddRightGroupbox('菜鸟反效果')

ZZ2:AddToggle("RemoveSlateskin", {
    Text = "反菜鸟石板减速",
    Default = false,
    Callback = function(v)
        if not _G.SlateskinCleanup then _G.SlateskinCleanup = {} end
        local connections = _G.SlateskinCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.SlateskinCleanup = {}

        if not v then return end

        local function CleanSlateskins()
            local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
            if not survivorsFolder then return end
            
            local survivorList = survivorsFolder:GetChildren()
            for i = 1, #survivorList, 5 do
                task.spawn(function()
                    for j = i, math.min(i + 4, #survivorList) do
                        local survivor = survivorList[j]
                        local slateskin = survivor:FindFirstChild("石板状态")
                        if slateskin then
                            slateskin:Destroy()
                        end
                    end
                end)
            end
        end

        task.spawn(CleanSlateskins)

        connections.heartbeat = game:GetService("RunService").心跳:Connect(function()
            task.wait(2)
            CleanSlateskins()
        end)

        local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.后代添加:Connect(function(descendant)
                if descendant.Name == "石板状态" then
                    descendant:Destroy()
                end
            end)
        end
    end
})




local Disabled = Tabs.ani:AddLeftGroupbox('访客反效果')

Disabled:AddToggle("RemoveSlowed", {
    Text = "反减速", 
    Default = false,
    Callback = function(v)
        if not _G.SlowedCleanup then _G.SlowedCleanup = {} end
        local connections = _G.SlowedCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.SlowedCleanup = {}

        if not v then return end

        local function CleanSlowedStatuses()
            local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "减速状态" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanSlowedStatuses)

        connections.heartbeat = game:GetService("RunService").心跳:Connect(function()
            task.wait(1.5)
            CleanSlowedStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.后代添加:Connect(function(descendant)
                if descendant.Name == "减速状态" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemoveBlockingSlow", {
    Text = "反阻挡减速",
    Default = false,
    Callback = function(v)
        if not _G.BlockingCleanup then _G.BlockingCleanup = {} end
        local connections = _G.BlockingCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.BlockingCleanup = {}

        if not v then return end

        local function CleanStatuses()
            local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "抵抗状态" or survivor.Name == "访客阻挡" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanStatuses)

        connections.heartbeat = game:GetService("RunService").心跳:Connect(function()
            task.wait(1.5)
            CleanStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.后代添加:Connect(function(descendant)
                if descendant.Name == "抵抗状态" or descendant.Name == "访客阻挡" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemovePunchSlow", {
    Text = "反拳击减速",
    Default = false,
    Callback = function(v)
        if not _G.PunchCleanup then _G.PunchCleanup = {} end
        local connections = _G.PunchCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.PunchCleanup = {}

        if not v then return end

        local function CleanStatuses()
            local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "抵抗状态" or survivor.Name == "拳击能力" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanStatuses)

        connections.heartbeat = game:GetService("RunService").心跳:Connect(function()
            task.wait(1.5)
            CleanStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.后代添加:Connect(function(descendant)
                if descendant.Name == "抵抗状态" or descendant.Name == "拳击能力" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemoveChargeEnded", {
    Text = "反冲刺后效果", 
    Default = false,
    Callback = function(v)
        if not _G.ChargeEndedCleanup then _G.ChargeEndedCleanup = {} end
        local connections = _G.ChargeEndedCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.ChargeEndedCleanup = {}

        if not v then return end

        local function CleanChargeEndedEffects()
            local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "访客冲刺结束" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanChargeEndedEffects)

        connections.heartbeat = game:GetService("RunService").心跳:Connect(function()
            task.wait(1.5)
            CleanChargeEndedEffects()
        end)

        local survivorsFolder = workspace:FindFirstChild("玩家") and workspace.玩家:FindFirstChild("幸存者")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.后代添加:Connect(function(descendant)
                if descendant.Name == "访客冲刺结束" then
                    descendant:Destroy()
                end
            end)
        end
    end
})









local LeftGroupBox = Tabs.ani:AddRightGroupbox("酷小孩", "user")

if not getgenv().originalNamecall then
	getgenv().HookRules = {}
	getgenv().originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		if method == "FireServer" then
			for _, rule in ipairs(getgenv().HookRules) do
				if (not rule.remoteName or self.Name == rule.remoteName) then
					if not rule.blockedFirstArg or args[1] == rule.blockedFirstArg then
						if rule.block then
							return
						end
					end
				end
			end
		end
		return getgenv().originalNamecall(self, ...)
	end)
end

getgenv().activateRemoteHook = function(remoteName, blockedFirstArg)
	for _, rule in ipairs(getgenv().HookRules) do
		if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
			return
		end
	end
	table.insert(getgenv().HookRules, {
		remoteName = remoteName,
		blockedFirstArg = blockedFirstArg,
		block = true
	})
end

getgenv().deactivateRemoteHook = function(remoteName, blockedFirstArg)
	for i, rule in ipairs(getgenv().HookRules) do
		if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
			table.remove(getgenv().HookRules, i)
			break
		end
	end
end

getgenv().EnableC00lkidd = function()
	getgenv().activateRemoteHook("远程事件", game.Players.LocalPlayer.Name .. "酷小孩碰撞")
end

getgenv().DisableC00lkidd = function()
	getgenv().deactivateRemoteHook("远程事件", game.Players.LocalPlayer.Name .. "酷小孩碰撞")
end

local globalEnv = getgenv()
globalEnv.Players = game:GetService("Players")
globalEnv.RunService = game:GetService("RunService")
globalEnv.Camera = workspace.CurrentCamera
globalEnv.Player = globalEnv.Players.LocalPlayer
globalEnv.walkSpeed = 100
globalEnv.toggle = false
globalEnv.connection = nil

function globalEnv.getCharacter()
	return globalEnv.Player.Character or globalEnv.Player.CharacterAdded:Wait()
end

function globalEnv.onHeartbeat()
	local player = globalEnv.Player
	local character = globalEnv.getCharacter()
	if character.Name ~= "酷小孩" then return end
	local char = globalEnv.getCharacter()
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local lv = rootPart and rootPart:FindFirstChild("线性速度")
	if not rootPart or not humanoid or not lv then return end
	if lv then
		lv.VectorVelocity = Vector3.new(math.huge, math.huge, math.huge)
		lv.Enabled = false
	end
	local stopMovement = false
	local validValues = {
		超时 = true,
		碰撞 = true,
		击中 = true
	}
	local function watchResult(result)
		local function checkValue()
			if validValues[result.Value] then
				stopMovement = true
			end
		end
		checkValue()
		result:GetPropertyChangedSignal("值"):Connect(checkValue)
	end
	local function onCharacterAdded(character)
		local result = character:FindFirstChild("结果")
		if result and result:IsA("StringValue") then
			watchResult(result)
		end
		character.ChildAdded:Connect(function(child)
			if child.Name == "结果" and child:IsA("StringValue") then
				watchResult(child)
			end
		end)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
	if not stopMovement then
		local lookVector = globalEnv.Camera.CFrame.LookVector
		local moveDir = Vector3.new(lookVector.X, 0, lookVector.Z)
		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit
			rootPart.Velocity = Vector3.new(moveDir.X * globalEnv.walkSpeed, rootPart.Velocity.Y, moveDir.Z * globalEnv.walkSpeed)
			rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + moveDir)
		end
	end
end



LeftGroupBox:AddToggle("WalkspeedOverrideController", {
	Text = "自由移动 (锁定视角)",
	Tooltip = "启用速度覆盖控制器",
	Default = false,
	Callback = function(value)
		if value then
			globalEnv.connection = globalEnv.RunService.心跳:Connect(globalEnv.onHeartbeat)
		else
			if globalEnv.connection then
				globalEnv.connection:Disconnect()
			end
		end
	end,
})

LeftGroupBox:AddToggle("IgnoreObjectables", {
	Text = "忽略碰撞物体",
	Tooltip = "启用忽略碰撞",
	Default = false,
	Callback = function(Value)
		if Value then
			getgenv().EnableC00lkidd()
		else
			getgenv().DisableC00lkidd()
		end
	end
})














local ZZ = Tabs.ani:AddRightGroupbox('1x4')local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AutoPopup = {
    Enabled = false,
    Task = nil,
    Connections = {},
    Interval = 0.5
}

local function deletePopups()
    if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then
        return false
    end
    
    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("临时界面")
    if not tempUI then
        return false
    end
    
    local deleted = false
    for _, popup in ipairs(tempUI:GetChildren()) do
        if popup.Name == "1x1x1x1弹窗" then
            popup:Destroy()
            deleted = true
        end
    end
    return deleted
end

local function triggerEntangled()
    pcall(function()
        ReplicatedStorage.模块.网络.远程事件:FireServer("纠缠", {})
    end)
end

local function setupPopupListener()
    if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then return end
    
    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("临时界面")
    if not tempUI then
        tempUI = Instance.new("Folder")
        tempUI.Name = "临时界面"
        tempUI.Parent = LocalPlayer.PlayerGui
    end
    
    if AutoPopup.Connections.ChildAdded then
        AutoPopup.Connections.ChildAdded:Disconnect()
    end
    
    AutoPopup.Connections.ChildAdded = tempUI.ChildAdded:Connect(function(child)
        if AutoPopup.Enabled and child.Name == "1x1x1x1弹窗" then
            task.defer(function()
                child:Destroy()
                triggerEntangled()
            end)
        end
    end)
end

local function runMainTask()
    while AutoPopup.Enabled do
        deletePopups()
        task.wait(AutoPopup.Interval)
    end
end

local function startAutoPopup()
    if AutoPopup.Enabled then return end
    
    AutoPopup.Enabled = true
    setupPopupListener()
    
    if AutoPopup.Task then
        task.cancel(AutoPopup.Task)
    end
    AutoPopup.Task = task.spawn(runMainTask)
end

local function stopAutoPopup()
    if not AutoPopup.Enabled then return end
    
    AutoPopup.Enabled = false
    
    if AutoPopup.Task then
        task.cancel(AutoPopup.Task)
        AutoPopup.Task = nil
    end
    
    for _, connection in pairs(AutoPopup.Connections) do
        connection:Disconnect()
    end
    AutoPopup.Connections = {}
end

ZZ:AddSlider('AutoPopupInterval', {
    Text = '执行间隔',
    Default = 0.5,
    Min = 0.5,
    Max = 2,
    Rounding = 0,
    Tooltip = '设置自动执行间隔 (1-5秒)',
    Callback = function(value)
        AutoPopup.Interval = value
    end
})

ZZ:AddCheckbox('AutoPopupToggle', {
    Text = '弹窗反制',
    Default = false,
    Tooltip = '移除弹窗和懒惰效果',
    Callback = function(state)
        if state then
            startAutoPopup()
        else
            stopAutoPopup()
        end
    end
})

if LocalPlayer then
    LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
        if not LocalPlayer.Parent then
            stopAutoPopup()
        end
    end)
end



local NoliGroup = Tabs.ani:AddLeftGroupbox("诺丽", "user")



local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local noliDeleterActive = false
local deletionConnection = nil
local allowedNoli = nil
local isVoidRushCrashed = false
local characterCheckLoop = nil

local function deleteNewNoli()
    local killers = workspace:WaitForChild("玩家"):WaitForChild("杀手")
    
    allowedNoli = killers:FindFirstChild("诺丽")
    if not allowedNoli then
        return
    end
    
    if deletionConnection then
        deletionConnection:Disconnect()
        deletionConnection = nil
    end
    
    deletionConnection = RunService.心跳:Connect(function()
        allowedNoli = killers:FindFirstChild("诺丽")
        
        if not allowedNoli then
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            return
        end
        
        for _, child in killers:GetChildren() do
            if child.Name == "诺丽" and child ~= allowedNoli then
                child:Destroy()
            end
        end
    end)
end

local function manageVoidRushState(character)
    while isVoidRushCrashed and character and character.Parent do
        character:SetAttribute("虚空冲刺状态", "已崩溃")
        task.wait(0.5)
    end
end



NoliGroup:AddCheckbox("NoliDeleter", {
    Text = "反假诺丽",
    Default = false,
    Callback = function(enabled)
        noliDeleterActive = enabled
        
        if enabled then
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            
            local success = pcall(deleteNewNoli)
            
            if not success then
                noliDeleterActive = false
            end
        else
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            allowedNoli = nil
        end
    end
})

NoliGroup:AddCheckbox("Ignore obstacles[Noli]", {
    Text = "诺丽无视障碍",
    Default = false,
    Callback = function(enabled)
        isVoidRushCrashed = enabled
        local character = player.Character
        
        if characterCheckLoop then
            task.cancel(characterCheckLoop)
            characterCheckLoop = nil
        end
        
        if enabled then
            if character then
                characterCheckLoop = task.spawn(function()
                    manageVoidRushState(character)
                end)
            end
        else
            if character then
                character:SetAttribute("虚空冲刺状态", nil)
            end
        end
    end
})

local killers = workspace:WaitForChild("玩家"):WaitForChild("杀手")

killers.ChildAdded:Connect(function(child)
    if noliDeleterActive and child.Name == "诺丽" and not deletionConnection then
        task.wait(0.5)
        if noliDeleterActive and not deletionConnection then
            deleteNewNoli()
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    if isVoidRushCrashed then
        if characterCheckLoop then
            task.cancel(characterCheckLoop)
        end
        characterCheckLoop = task.spawn(function()
            manageVoidRushState(newCharacter)
        end)
    end
end)












local ZZ = Tabs.Main:AddRightGroupbox('玩家移动')
local CFSpeed = 50
local CFLoop = nil
local RunService = game:GetService("RunService")


local speedValue = 0
_G.SpeedToggle = false

ZZ:AddSlider("SpeedBypass", {
    Text = "速度调节",
    Default = 16,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        speedValue = value
    end
})

ZZ:AddToggle("SpeedToggle", {
    Text = "速度破解",
    Default = false,
    Callback = function(state)
        _G.SpeedToggle = state
        task.spawn(function()
            local LocalPlayer = game.Players.LocalPlayer
            while task.wait() and _G.SpeedToggle do
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.MoveDirection ~= Vector3.zero then
                    LocalPlayer.Character:TranslateBy(humanoid.MoveDirection * speedValue * game:GetService("RunService").RenderStepped:Wait())
                end
            end
        end)
    end
})




local noclipParts = {}
_G.noclipState = false

local function enableNoclip()
    local LocalPlayer = game.Players.LocalPlayer
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                noclipParts[part] = part
                part.CanCollide = false
            end
        end
    end
end

local function disableNoclip()
    for _, part in pairs(noclipParts) do
        part.CanCollide = true
    end
end

ZZ:AddToggle("EnableNoclip", {
    Text = "穿墙",
    Default = false,
    Callback = function(state)
        _G.noclipState = state
        task.spawn(function()
            while task.wait() do
                if _G.noclipState then
                    enableNoclip()
                else
                    disableNoclip()
                    break
                end
            end
        end)
    end
})


local function StartCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    if not character or not character.Parent then return end
    
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not head then return end
    
    humanoid.PlatformStand = true
    head.Anchored = true
    
    if CFLoop then 
        CFLoop:Disconnect() 
        CFLoop = nil
    end
    
    local function isCharacterValid()
        if not character or not character.Parent then return false end
        if not humanoid or humanoid.Parent ~= character then return false end
        if not head or head.Parent ~= character then return false end
        return true
    end
    
    CFLoop = RunService.心跳:Connect(function(deltaTime)
        if not isCharacterValid() then 
            if CFLoop then 
                CFLoop:Disconnect() 
                CFLoop = nil
            end
            return 
        end
        
        local moveDirection = humanoid.MoveDirection
        local headCFrame = head.CFrame
        local camera = workspace.CurrentCamera
        
        if not camera then return end
        
        local cameraCFrame = camera.CFrame
        local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
        cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
        local cameraPosition = cameraCFrame.Position
        local headPosition = headCFrame.Position

        local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection * (CFSpeed * deltaTime))
        
        if isCharacterValid() then
            head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end
    end)
end

local function StopCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    
    if CFLoop then
        CFLoop:Disconnect()
        CFLoop = nil
    end
    
    if character and character.Parent then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local head = character:FindFirstChild("Head")
        
        if humanoid then
            humanoid.PlatformStand = false
        end
        if head then
            head.Anchored = false
        end
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    StopCFly()
end)

ZZ:AddToggle("CFlyToggle", {
    Text = "飞行",
    Default = false,
    Callback = function(Value)
        if Value then
            task.wait(0.1)
            StartCFly()
        else
            StopCFly()
        end
    end
})

ZZ:AddSlider("CFlySpeed", {
    Text = "飞行速度",
    Default = 50,
    Min = 1,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        CFSpeed = Value
    end
})






ZZ:AddLabel("以上所有功能均可绕过/暴力使用")


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local SpoofActive = false
local TargetCFrame = nil
local OriginalCallback = nil
local HookInstalled = false

local function formatCFrame(cf)
    if not cf then return nil end
    local pos, look = cf.Position, cf.LookVector
    return string.format("%0.3f/%0.3f/%0.3f/%0.3f/%0.3f/%0.3f", 
        pos.X, pos.Y, pos.Z, look.X, look.Y, look.Z)
end

local function installHook()
    if HookInstalled then return end
    
    local success, networkModule = pcall(require, ReplicatedStorage:WaitForChild("模块"):WaitForChild("网络"))
    if not success or not networkModule then return end
    
    if networkModule.设置连接 then
        local originalSetConnection = networkModule.设置连接
        
        networkModule.设置连接 = function(self, key, connType, callback)
            if key == "获取本地位置数据" and connType == "远程函数" then
                OriginalCallback = callback
                
                local wrappedCallback = function(...)
                    if SpoofActive and TargetCFrame then
                        return formatCFrame(TargetCFrame)
                    end
                    if OriginalCallback then
                        return OriginalCallback(...)
                    end
                    local char = LocalPlayer.Character
                    if char and char.PrimaryPart then
                        return formatCFrame(char.PrimaryPart.CFrame)
                    end
                    return nil
                end
                
                return originalSetConnection(self, key, connType, wrappedCallback)
            end
            return originalSetConnection(self, key, connType, callback)
        end
        
        HookInstalled = true
    end
end

local function setupSpoof()
    installHook()
    
    local char = LocalPlayer.Character
    if char and char.PrimaryPart then
        TargetCFrame = char.PrimaryPart.CFrame
        SpoofActive = true
    end
    
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        newChar:WaitForChild("HumanoidRootPart")
        if SpoofActive then
            TargetCFrame = newChar.HumanoidRootPart.CFrame
        end
    end)
end

task.spawn(function()
    task.wait(1)
    setupSpoof()
end)

local SpoofTab = Tabs.Main:AddLeftGroupbox("服务器绕过 [速度] ")

SpoofTab:AddToggle("SpoofToggle", {
    Text = "位置欺骗",
    Default = false,
    Callback = function(state)
        SpoofActive = state
        if state then
            local char = LocalPlayer.Character
            if char and char.PrimaryPart then
                TargetCFrame = char.PrimaryPart.CFrame
            end
        end
    end
})



local Visual = Tabs.Bro:AddLeftGroupbox("维罗妮卡")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getBehaviorFolder()
    return ReplicatedStorage:WaitForChild("资源")
        :WaitForChild("幸存者")
        :WaitForChild("维罗妮卡")
        :WaitForChild("行为")
end

local function getSprintingButton()
    return player.PlayerGui:WaitForChild("主界面"):WaitForChild("冲刺按钮")
end

local behaviorFolder = getBehaviorFolder()
local monitored = {}
local isEnabled = false
local descendantAddedConn = nil
local device = "PC"

local function safeConnectPropertyChanged(instance, prop, fn)
    local ok, signal = pcall(function() return instance:GetPropertyChangedSignal(prop) end)
    if ok and signal then
        return signal:Connect(fn)
    end
    return nil
end

local function monitorHighlight(h)
    if not h or monitored[h] then return end

    local connections = {}
    local prevState = false

    local function cleanup()
        for _, conn in ipairs(connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        monitored[h] = nil
    end

    local function adorneeIsPlayerCharacter(h)
        if not h then return false end
        local adornee = h.Adornee
        local char = player.Character
        if not adornee or not char then return false end
        if adornee == char then return true end
        if adornee:IsDescendantOf(char) then return true end
        return false
    end

    local function triggerSprint()
        if device == "移动端" then
            local ok, btn = pcall(getSprintingButton)
            if ok and btn then
                for i, v in pairs(getconnections(btn.MouseButton1Down)) do
                    pcall(function() v:Fire() end)
                    pcall(function() if v.Function then v:Function() end end)
                end
            end
        else
            pcall(function()
                keypress(Enum.KeyCode.Space)
                task.wait(0.1)
                keyrelease(Enum.KeyCode.Space)
            end)
        end
    end

    local function onChanged()
        if not isEnabled then return end
        if not h or not h.Parent then
            cleanup()
            return
        end

        local currState = adorneeIsPlayerCharacter(h)
        if prevState ~= currState then
            if currState then
                triggerSprint()
            end
            prevState = currState
        end
    end

    local c = safeConnectPropertyChanged(h, "Adornee", onChanged)
    if c then table.insert(connections, c) end

    table.insert(connections, h.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
        else
            onChanged()
        end
    end))

    table.insert(connections, player.CharacterAdded:Connect(onChanged))
    table.insert(connections, player.CharacterRemoving:Connect(onChanged))

    monitored[h] = cleanup
    task.spawn(onChanged)
end

local function startMonitoring()
    if descendantAddedConn then return end
    
    for _, desc in ipairs(behaviorFolder:GetDescendants()) do
        if desc:IsA("Highlight") then
            monitorHighlight(desc)
        end
    end
    
    descendantAddedConn = behaviorFolder.DescendantAdded:Connect(function(child)
        if child:IsA("Highlight") then
            monitorHighlight(child)
        end
    end)
end

local function stopMonitoring()
    if descendantAddedConn and descendantAddedConn.Connected then
        descendantAddedConn:Disconnect()
    end
    descendantAddedConn = nil

    for h, cleanup in pairs(monitored) do
        if type(cleanup) == "function" then
            pcall(cleanup)
        end
    end
    monitored = {}
end

Visual:AddCheckbox("AutoSprintToggle", {
    Text = "自动跳跃",
    Default = false,
    Callback = function(enabled)
        isEnabled = enabled
        if enabled then
            startMonitoring()
        else
            stopMonitoring()
        end
    end
})

Visual:AddDropdown("DeviceType", {
    Text = "设备",
    Default = "PC",
    Values = {"移动端", "PC"},
    Callback = function(value)
        device = value
    end
})

if not _G.VeeronicaData then
    _G.VeeronicaData = {
        characterConnection = nil
    }
end

local function setupVeeronicaCharacterConnection()
    local data = _G.VeeronicaData
    
    if data.characterConnection then
        data.characterConnection:Disconnect()
        data.characterConnection = nil
    end
    
    data.characterConnection = player.CharacterAdded:Connect(function()
        if isEnabled then
            task.wait(0.5)
            stopMonitoring()
            startMonitoring()
        end
    end)
end

setupVeeronicaCharacterConnection()

if isEnabled then
    startMonitoring()
end

local ControlCharge = {
    Enabled = false,
    Active = false,
    ShiftlockEnabled = false,
    Connection = nil,
    OverrideConnection = nil,
    ChargeAnimIds = {"117058860640843"},
    ORIGINAL_DASH_SPEED = 60,
    SavedHumanoidState = {}
}

ControlCharge.SetShiftlock = function(state)
    ControlCharge.ShiftlockEnabled = state

    if ControlCharge.Connection then
        ControlCharge.Connection:Disconnect()
        ControlCharge.Connection = nil
    end

    if ControlCharge.ShiftlockEnabled then
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

        ControlCharge.Connection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local camCF = camera.CFrame
                root.CFrame = CFrame.new(root.Position, Vector3.new(
                    camCF.LookVector.X + root.Position.X,
                    root.Position.Y,
                    camCF.LookVector.Z + root.Position.Z
                ))
            end
        end)
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
end

ControlCharge.GetHumanoid = function()
    if not player or not player.Character then return nil end
    return player.Character:FindFirstChildOfClass("Humanoid")
end

ControlCharge.SaveHumState = function(hum)
    if not hum then return end
    if ControlCharge.SavedHumanoidState[hum] then return end
    local s = {}
    pcall(function()
        s.WalkSpeed = hum.WalkSpeed
        local ok, _ = pcall(function() s.JumpPower = hum.JumpPower end)
        if not ok then
            pcall(function() s.JumpPower = hum.JumpHeight end)
        end
        local ok2, ar = pcall(function() return hum.AutoRotate end)
        if ok2 then s.AutoRotate = ar end
        s.PlatformStand = hum.PlatformStand
    end)
    ControlCharge.SavedHumanoidState[hum] = s
end

ControlCharge.RestoreHumState = function(hum)
    if not hum then return end
    local s = ControlCharge.SavedHumanoidState[hum]
    if not s then return end
    pcall(function()
        if s.WalkSpeed ~= nil then hum.WalkSpeed = s.WalkSpeed end
        if s.JumpPower ~= nil then
            local ok, _ = pcall(function() hum.JumpPower = s.JumpPower end)
            if not ok then pcall(function() hum.JumpHeight = s.JumpPower end) end
        end
        if s.AutoRotate ~= nil then pcall(function() hum.AutoRotate = s.AutoRotate end) end
        if s.PlatformStand ~= nil then hum.PlatformStand = s.PlatformStand end
    end)
    ControlCharge.SavedHumanoidState[hum] = nil
end

ControlCharge.StartOverride = function()
    if ControlCharge.Active then return end
    local hum = ControlCharge.GetHumanoid()
    if not hum then return end

    ControlCharge.Active = true
    ControlCharge.SaveHumState(hum)

    pcall(function()
        hum.WalkSpeed = ControlCharge.ORIGINAL_DASH_SPEED
        hum.AutoRotate = false
    end)
    
    ControlCharge.SetShiftlock(true)
    
    ControlCharge.OverrideConnection = RunService.RenderStepped:Connect(function()
        local humanoid = ControlCharge.GetHumanoid()
        local rootPart = humanoid and humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        pcall(function()
            humanoid.WalkSpeed = ControlCharge.ORIGINAL_DASH_SPEED
            humanoid.AutoRotate = false
        end)

        local direction = rootPart.CFrame.LookVector
        local horizontal = Vector3.new(direction.X, 0, direction.Z)
        if horizontal.Magnitude > 0 then
            humanoid:Move(horizontal.Unit)
        else
            humanoid:Move(Vector3.new(0,0,0))
        end
    end)
end

ControlCharge.StopOverride = function()
    if not ControlCharge.Active then return end
    ControlCharge.Active = false

    if ControlCharge.OverrideConnection then
        pcall(function() ControlCharge.OverrideConnection:Disconnect() end)
        ControlCharge.OverrideConnection = nil
    end

    ControlCharge.SetShiftlock(false)

    local hum = ControlCharge.GetHumanoid()
    if hum then
        pcall(function()
            ControlCharge.RestoreHumState(hum)
            hum:Move(Vector3.new(0,0,0))
        end)
    end
end

ControlCharge.DetectChargeAnimation = function()
    local hum = ControlCharge.GetHumanoid()
    if not hum then return false end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        local ok, animId = pcall(function()
            return tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
        end)
        if ok and animId and animId ~= "" then
            if ControlCharge.ChargeAnimIds and table.find(ControlCharge.ChargeAnimIds, animId) then
                return true
            end
        end
    end
    return false
end

ControlCharge.SetEnabled = function(val)
    ControlCharge.Enabled = val
    if not ControlCharge.Enabled and ControlCharge.Active then
        ControlCharge.StopOverride()
    end
end

ControlCharge.MainLoop = function()
    if not ControlCharge.Enabled then
        if ControlCharge.Active then ControlCharge.StopOverride() end
        return
    end

    local hum = ControlCharge.GetHumanoid()
    if not hum then
        if ControlCharge.Active then ControlCharge.StopOverride() end
        return
    end

    local isCharging = ControlCharge.DetectChargeAnimation()

    if isCharging then
        if not ControlCharge.Active then
            ControlCharge.StartOverride()
        end
    else
        if ControlCharge.Active then
            ControlCharge.StopOverride()
        end
    end
end

RunService.RenderStepped:Connect(function()
    ControlCharge.MainLoop()
end)

player.CharacterAdded:Connect(function(char)
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 2)
    end)
end)

player.CharacterAdded:Connect(function()
    if ControlCharge.Connection then
        ControlCharge.Connection:Disconnect()
        ControlCharge.Connection = nil
    end
end)

Visual:AddCheckbox("ControlChargeToggle", {
    Text = "移动控制",
    Default = false,
    Callback = function(state)
        ControlCharge.SetEnabled(state)
    end
})




local MenuGroup = Tabs["UI 设置"]:AddLeftGroupbox("调试")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,  
    Text = "快捷键菜单",
    Callback = function(value)
        Library.KeybindFrame.Visible = value  
    end,
})


MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "鼠标光标",
    Default = true,  
    Callback = function(Value)
        Library.ShowCustomCursor = Value  
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "左侧", "右侧" },
    Default = "右侧",  
    Text = "通知位置",
    Callback = function(Value)
        Library:SetNotifySide(Value)  
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "75%",  
    Text = "UI 大小",
    Callback = function(Value)
        Value = Value:gsub("%%", "")  
        local DPI = tonumber(Value)   
        Library:SetDPIScale(DPI)      
    end,
})


MenuGroup:AddDivider()  
MenuGroup:AddLabel("菜单快捷键")  
    :AddKeyPicker("MenuKeybind", { 
        Default = "RightShift",  
        NoUI = true,            
        Text = "菜单快捷键"    
    })


MenuGroup:AddButton("销毁界面", function()
    Library:Unload()  
end)




ThemeManager:SetLibrary(Library)  
SaveManager:SetLibrary(Library)   
SaveManager:IgnoreThemeSettings() 


SaveManager:SetIgnoreIndexes({ "MenuKeybind" })  
ThemeManager:SetFolder("我的脚本集")            
SaveManager:SetFolder("我的脚本集/特定游戏")  
SaveManager:SetSubFolder("特定地点")       
SaveManager:BuildConfigSection(Tabs["UI 设置"])  

ThemeManager:ApplyToTab(Tabs["UI 设置"])

SaveManager:LoadAutoloadConfig()





    Library:SetWatermarkVisibility(true)

    local function updateWatermark()
        local fps = 60
        local frameTimer = tick()
        local frameCounter = 0

        game:GetService('RunService').RenderStepped:Connect(function()
            frameCounter = frameCounter + 1

            if ((tick() - frameTimer) >= 1) then
                fps = frameCounter
                frameTimer = tick()
                frameCounter = 0
            end

            Library:SetWatermark(string.format('遗忘者 | %d FPS | %d 延迟', math.floor(fps), math.floor(game:GetService('Stats').Network.ServerStatsItem['数据延迟']:GetValue())))
        end)
    end

    updateWatermark()