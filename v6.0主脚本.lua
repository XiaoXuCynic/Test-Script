-- 安全加载 WindUI 库
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/KingScriptAE/No-sirve-nada/main/main.lua", true))()
end)

if not success or not WindUI then
    warn("无法加载 WindUI 库")
    
    -- 尝试备用链接
    local success2, WindUI2 = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
    end)
    
    if success2 and WindUI2 then
        WindUI = WindUI2
    else
        warn("所有 WindUI 链接都不可用")
        return
    end
end

-- 本地化设置
WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "zh-CN",
    Translations = {
        ["zh-CN"] = {
            ["WINDUI_EXAMPLE"] = "旧冬脚本",
            ["WELCOME"] = "欢迎使用 旧冬",
            ["LIB_DESC"] = "超牛逼的脚本",
            ["SETTINGS"] = "设置",
            ["APPEARANCE"] = "外观",
            ["FEATURES"] = "功能",
            ["UTILITIES"] = "实用工具",
            ["UI_ELEMENTS"] = "UI 元素",
            ["CONFIGURATION"] = "配置管理",
            ["SAVE_CONFIG"] = "保存配置",
            ["LOAD_CONFIG"] = "加载配置",
            ["THEME_SELECT"] = "选择主题",
            ["TRANSPARENCY"] = "窗口透明度"
        },
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "WindUI Example",
            ["WELCOME"] = "Welcome to OWINTER",
            ["LIB_DESC"] = "谢谢你使用旧冬 我们会继续改进 此脚本如果没有特殊情况会一直更新",
            ["SETTINGS"] = "Settings",
            ["APPEARANCE"] = "Appearance",
            ["FEATURES"] = "Features",
            ["UTILITIES"] = "Utilities",
            ["UI_ELEMENTS"] = "UI Elements",
            ["CONFIGURATION"] = "Configuration",
            ["SAVE_CONFIG"] = "Save Configuration",
            ["LOAD_CONFIG"] = "Load Configuration",
            ["THEME_SELECT"] = "Select Theme",
            ["TRANSPARENCY"] = "Window Transparency"
        }
    }
})

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

-- 渐变色文本函数
function gradient(text, startColor, endColor)
    local result = ""
    local chars = {}
    
    -- 正确处理中文字符
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    
    local length = #chars
    
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = startColor.R + (endColor.R - startColor.R) * t
        local g = startColor.G + (endColor.G - startColor.G) * t
        local b = startColor.B + (endColor.B - startColor.B) * t
        
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', 
            math.floor(r * 255), 
            math.floor(g * 255), 
            math.floor(b * 255), 
            chars[i])
    end
    
    return result
end

-- 显示欢迎弹窗
WindUI:Popup({
    Title = gradient("旧冬v6.0 | SunkenBoat & TBW.TEAM", Color3.fromHex("6A11CB"), Color3.fromHex("2575FC")),
    Icon = "zap",
    Content = "loc:LIB_DESC",
    Buttons = {
        {
            Title = "开始使用",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function() end
        }
    }
})

-- 创建主窗口
local Window = WindUI:CreateWindow({
    Title = "旧冬v6.0 | TBW.TEAM",
    Icon = "crown",
    Author = "作者:小徐 | 百夜 | Break",
    Folder = "旧冬",
    Size = UDim2.fromOffset(580, 490),
    Background = "https://raw.githubusercontent.com/XiaoXuCynic/UI-Picture/refs/heads/main/Screenshot_20260211_112829_com.ss.android.ugc.aweme.png",
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            WindUI:Notify({
                Title = "用户资料",
                Content = "点击了用户资料!",
                Duration = 3
            })
        end
    },
    Acrylic = true,
    HideSearchBar = false,
    SideBarWidth = 200
})

-- 添加标签
Window:Tag({
    Title = "v6.0",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
    Title = "TBW.TEAM",
    Color = Color3.fromHex("#315dff")
})

Window:Tag({
    Title = "Sunken-Boat",
    Color = Color3.fromHex("#315dff")
})

local TimeTag = Window:Tag({
    Title = "--:--",
    Radius = 0,
    Color = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 },
    }, {
        Rotation = 45,
    }),
})

-- 顶部栏按钮
Window:CreateTopbarButton("主题切换", "moon", function()
    local currentTheme = WindUI:GetCurrentTheme()
    local newTheme = currentTheme == "Dark" and "Light" or "Dark"
    WindUI:SetTheme(newTheme)
    WindUI:Notify({
        Title = "主题已更改",
        Content = "当前主题: " .. newTheme,
        Duration = 2
    })
end, 990)

-- 创建 Sections
local MainSection = Window:Section({ Title = "主要功能/脚本", Opened = true })
local SettingsSection = Window:Section({ Title = "主题调整器", Opened = true })
local UtilitiesSection = Window:Section({ Title = "配置保存器", Opened = true })
local FESection = Window:Section({ Title = "FE脚本", Opened = true })
local ScriptSection = Window:Section({ Title = "脚本工具", Opened = true })

-- 创建选项卡 - 修复：正确创建选项卡
local ElementsTab = MainSection:Tab("功能", "layout-grid")
local AppearanceTab = SettingsSection:Tab("修改背景", "brush")
local ConfigTab = UtilitiesSection:Tab("配置", "settings")
local LiJianTab = FESection:Tab("FE脚本", "play")
local XiaoXuTab = ScriptSection:Tab("脚本工具", "crown")

-- 存储选项卡句柄
local TabHandles = {
    Elements = ElementsTab,
    Appearance = AppearanceTab,
    Config = ConfigTab,
    LiJian = LiJianTab,
    XiaoXu = XiaoXuTab
}

-- 添加调试信息
print("选项卡创建成功:")
for name, tab in pairs(TabHandles) do
    print("  " .. name .. ": " .. tostring(tab))
end

-- 安全检查函数
local function safeCreate(callback, fallback)
    local success, result = pcall(callback)
    if success and result then
        return result
    else
        warn("创建失败，使用备选方案")
        return fallback or { 
            Paragraph = function() end, 
            Divider = function() end,
            Section = function() return { 
                Slider = function() return { Set = function() end, Get = function() return 0 end } end,
                Toggle = function() return { Set = function() end, Get = function() return false end } end,
                Button = function() end 
            } end 
        }
    end
end

-- 元素选项卡内容
safeCreate(function()
    ElementsTab:Paragraph({
        Title = "旧冬脚本主群1023991438",
        Desc = "获取最新旧冬脚本",
        Image = "component",
        ImageSize = 20,
        Color = Color3.fromHex("#30ff6a"),
    })
end)

safeCreate(function()
    ElementsTab:Paragraph({
        Title = "旧冬脚本副群467989227",
        Desc = "Sunken-Boat",
        Image = "component",
        ImageSize = 20,
        Color = Color3.fromHex("#30ff6a"),
    })
end)

safeCreate(function()
    ElementsTab:Paragraph({
        Title = "旧冬脚本三群1020029537",
        Desc = "TBW.TEAM维护",
        Image = "component",
        ImageSize = 20,
        Color = Color3.fromHex("#30ff6a"),
    })
end)

safeCreate(function()
    ElementsTab:Divider()
end)

-- 创建 ElementsSection
local ElementsSection
safeCreate(function()
    ElementsSection = ElementsTab:Section({
        Title = "通用功能",
        Icon = "crown",
    })
end)

-- 如果 ElementsSection 创建失败，提供一个空对象
if not ElementsSection then
    ElementsSection = {
        Slider = function() return { Set = function() end, Get = function() return 16 end } end,
        Toggle = function() return { Set = function() end, Get = function() return false end } end,
        Button = function() end
    }
end

-- 速度滑块
local SpeedSlider = ElementsSection:Slider({
    Title = "速度",
    Min = 16,
    Max = 400,
    Default = 16,
    Value = 16,
    Increment = 1,
    Callback = function(value)
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

-- 跳跃滑块
local JumpSlider = ElementsSection:Slider({
    Title = "跳跃高度",
    Min = 50,
    Max = 200,
    Default = 50,
    Value = 50,
    Increment = 1,
    Callback = function(value)
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
})

-- 杀戮光环
local killAuraToggle = ElementsSection:Toggle({
    Title = "启用杀戮光环",
    Desc = "杀戮光环",
    Value = false,
    Callback = function(state)
        if state then
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local localPlayer = Players.LocalPlayer
            
            if not _G.killAuraConfig then
                _G.killAuraConfig = {
                    isRunning = true,
                    connection = nil
                }
            else
                _G.killAuraConfig.isRunning = true
            end
            
            if _G.killAuraConfig.connection then
                _G.killAuraConfig.connection:Disconnect()
                _G.killAuraConfig.connection = nil
            end
            
            _G.killAuraConfig.connection = RunService.Heartbeat:Connect(function()
                if not _G.killAuraConfig or not _G.killAuraConfig.isRunning then return end
                
                local localCharacter = localPlayer.Character
                if not localCharacter then return end
                
                local humanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
                local humanoid = localCharacter:FindFirstChildOfClass("Humanoid")
                
                if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then return end
                
                local tool = localCharacter:FindFirstChildOfClass("Tool")
                if not tool then return end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer then
                        local targetChar = player.Character
                        if targetChar then
                            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                            local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                            
                            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                                if distance < 20 then
                                    if tool:IsA("Tool") then
                                        tool:Activate()
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            
            WindUI:Notify({
                Title = "功能设置",
                Content = "杀戮光环已启用",
                Icon = "check",
                Duration = 2
            })
        else
            if _G.killAuraConfig then
                _G.killAuraConfig.isRunning = false
                if _G.killAuraConfig.connection then
                    _G.killAuraConfig.connection:Disconnect()
                    _G.killAuraConfig.connection = nil
                end
                _G.killAuraConfig = nil
            end
            
            WindUI:Notify({
                Title = "功能设置",
                Content = "杀戮光环已禁用",
                Icon = "x",
                Duration = 2
            })
        end
    end
})

-- 防甩飞功能
local FlyOffToggle = ElementsSection:Toggle({
    Title = "防甩飞",
    Desc = "别人想甩飞你是不可能的",
    Value = false,
    Callback = function(state)
        if state then
            local Services = setmetatable({}, {__index = function(Self, Index)
                local NewService = game:GetService(Index)
                if NewService then
                    Self[Index] = NewService
                end
                return NewService
            end})

            local LocalPlayer = Services.Players.LocalPlayer
            _G.flyOffEnabled = true
            _G.flyOffConnections = _G.flyOffConnections or {}

            local function PlayerAdded(Player)
                if Player == LocalPlayer then return end
                
                local Detected = false
                local Character
                local PrimaryPart

                local function CharacterAdded(NewCharacter)
                    Character = NewCharacter
                    repeat
                        task.wait()
                        PrimaryPart = NewCharacter:FindFirstChild("HumanoidRootPart")
                    until PrimaryPart
                    Detected = false
                end

                CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
                
                local conn = Player.CharacterAdded:Connect(CharacterAdded)
                table.insert(_G.flyOffConnections, conn)
                
                local heartbeatConn = Services.RunService.Heartbeat:Connect(function()
                    if not _G.flyOffEnabled then
                        heartbeatConn:Disconnect()
                        return
                    end
                    
                    if (Character and Character:IsDescendantOf(workspace)) and (PrimaryPart and PrimaryPart:IsDescendantOf(Character)) then
                        if PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
                            if Detected == false then
                                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                                    Text = "Fling Exploit Detected Player : "..tostring(Player);
                                    Color = Color3.fromRGB(255, 200, 0);
                                })
                            end
                            Detected = true
                            for i,v in ipairs(Character:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    v.CanCollide = false
                                    v.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                    v.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                    v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                                end
                            end
                            PrimaryPart.CanCollide = false
                            PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                        end
                    end
                end)
                table.insert(_G.flyOffConnections, heartbeatConn)
            end

            for i,v in ipairs(Services.Players:GetPlayers()) do
                if v ~= LocalPlayer then
                    PlayerAdded(v)
                end
            end
            
            local playerAddedConn = Services.Players.PlayerAdded:Connect(PlayerAdded)
            table.insert(_G.flyOffConnections, playerAddedConn)

            WindUI:Notify({
                Title = "通知",
                Content = "防甩飞功能已启用",
                Duration = 3,
                Icon = "layout-grid",
            })
        else
            _G.flyOffEnabled = false
            if _G.flyOffConnections then
                for _, conn in ipairs(_G.flyOffConnections) do
                    if conn then
                        conn:Disconnect()
                    end
                end
                _G.flyOffConnections = {}
            end
            
            WindUI:Notify({
                Title = "通知",
                Content = "防甩飞功能已禁用",
                Duration = 3,
                Icon = "layout-grid",
            })
        end
    end
})

-- ESP 功能
local espToggle = ElementsSection:Toggle({
    Title = "启用人物显示",
    Desc = "人物显示",
    Value = false,
    Callback = function(state)
        if state then
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer
            
            if not _G.espBoxes then
                _G.espBoxes = {}
                _G.espConnections = {}
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer then
                    local function createESP(char)
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            if _G.espBoxes[player.Name] then
                                _G.espBoxes[player.Name]:Destroy()
                            end
                            
                            local box = Instance.new("BoxHandleAdornment")
                            box.Adornee = char.HumanoidRootPart
                            box.AlwaysOnTop = true
                            box.ZIndex = 10
                            box.Size = Vector3.new(4, 6, 4)
                            box.Color3 = Color3.fromRGB(255, 0, 0)
                            box.Transparency = 0.5
                            box.Parent = char.HumanoidRootPart
                            
                            _G.espBoxes[player.Name] = box
                        end
                    end
                    
                    if player.Character then
                        createESP(player.Character)
                    end
                    
                    _G.espConnections[player.Name] = player.CharacterAdded:Connect(function(char)
                        task.wait(1)
                        createESP(char)
                    end)
                end
            end
            
            WindUI:Notify({
                Title = "人物显示",
                Content = "已启用",
                Icon = "bell",
                Duration = 2
            })
        else
            if _G.espBoxes then
                for name, box in pairs(_G.espBoxes) do
                    if box then
                        pcall(function() box:Destroy() end)
                    end
                end
                _G.espBoxes = nil
            end
            
            if _G.espConnections then
                for name, connection in pairs(_G.espConnections) do
                    if connection then
                        connection:Disconnect()
                    end
                end
                _G.espConnections = nil
            end
            
            WindUI:Notify({
                Title = "人物显示",
                Content = "已禁用",
                Icon = "bell",
                Duration = 2
            })
        end
    end
})

-- 飞行功能
ElementsSection:Button({
    Title = "旧冬飞行V1",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/QiuShan-UX/UnicoX/main/%E9%A3%9E%E8%A1%8C%E7%A4%BA%E4%BE%8B.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "飞行已启用",
                Content = "飞行功能已加载",
                Icon = "check",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "飞行加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

-- 穿墙功能
local noclipToggle = ElementsSection:Toggle({
    Title = "启用穿墙",
    Desc = "穿墙",
    Value = false,
    Callback = function(state)
        if state then
            _G.Noclip = true
            if _G.NoclipConnection then
                _G.NoclipConnection:Disconnect()
            end
            _G.NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if _G.Noclip then
                    local character = game.Players.LocalPlayer.Character
                    if character then
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                else
                    if _G.NoclipConnection then
                        _G.NoclipConnection:Disconnect()
                        _G.NoclipConnection = nil
                    end
                end
            end)
        else
            _G.Noclip = false
            if _G.NoclipConnection then
                _G.NoclipConnection:Disconnect()
                _G.NoclipConnection = nil
            end
        end
    end
})

-- 夜视功能
local nightVisionToggle = ElementsSection:Toggle({
    Title = "启用夜视",
    Desc = "夜视",
    Value = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            _G.originalAmbient = Lighting.Ambient
            _G.originalOutdoorAmbient = Lighting.OutdoorAmbient
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            if _G.originalAmbient then
                Lighting.Ambient = _G.originalAmbient
            else
                Lighting.Ambient = Color3.new(0, 0, 0)
            end
            
            if _G.originalOutdoorAmbient then
                Lighting.OutdoorAmbient = _G.originalOutdoorAmbient
            else
                Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            end
        end
    end
})

-- 无限跳跃功能
local infiniteJumpToggle = ElementsSection:Toggle({
    Title = "启用无限跳",
    Desc = "无限跳",
    Value = false,
    Callback = function(state)
        _G.InfiniteJumpEnabled = state
        
        if _G.InfiniteJumpConnection then
            _G.InfiniteJumpConnection:Disconnect()
            _G.InfiniteJumpConnection = nil
        end
        
        if state then
            _G.InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfiniteJumpEnabled then
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end
            end)
        end
    end
})

-- 无敌功能
local godModeToggle = ElementsSection:Toggle({
    Title = "启用无敌",
    Desc = "小概率bug",
    Value = false,
    Callback = function(state)
        if state then
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    _G.originalMaxHealth = humanoid.MaxHealth
                    _G.originalHealth = humanoid.Health
                    humanoid.MaxHealth = 9e9
                    humanoid.Health = 9e9
                end
            end
        else
            if _G.originalMaxHealth then
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.MaxHealth = _G.originalMaxHealth
                        humanoid.Health = math.min(_G.originalHealth or 100, _G.originalMaxHealth)
                        _G.originalMaxHealth = nil
                        _G.originalHealth = nil
                    end
                end
            end
        end
    end
})

-- 自杀功能
ElementsSection:Button({
    Title = "自杀",
    Icon = "bell",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end
        end
        WindUI:Notify({
            Title = "已自杀",
            Content = "角色已死亡",
            Icon = "bell",
            Duration = 3
        })
    end
})

-- FPS显示功能
local fpsToggle = ElementsSection:Toggle({
    Title = "显示FPS",
    Desc = "显示FPS",
    Value = false,
    Callback = function(state)
        if state then
            local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            
            local oldFpsGui = playerGui:FindFirstChild("FPSGui")
            if oldFpsGui then
                oldFpsGui:Destroy()
            end
            
            local fpsGui = Instance.new("ScreenGui")
            fpsGui.Name = "FPSGui"
            fpsGui.ResetOnSpawn = false
            fpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            fpsGui.DisplayOrder = 999
            fpsGui.Parent = playerGui
            
            local fpsLabel = Instance.new("TextLabel")
            fpsLabel.Name = "FPSLabel"
            fpsLabel.Size = UDim2.new(0, 100, 0, 30)
            fpsLabel.Position = UDim2.new(0.85, 0, 0.02, 0)
            fpsLabel.BackgroundTransparency = 0.7
            fpsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            fpsLabel.Font = Enum.Font.SourceSansBold
            fpsLabel.Text = "FPS: 0"
            fpsLabel.TextSize = 18
            fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            fpsLabel.TextStrokeTransparency = 0.5
            fpsLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            fpsLabel.Parent = fpsGui
            
            local lastTime = tick()
            local frameCount = 0
            
            _G.fpsConnection = game:GetService("RunService").RenderStepped:Connect(function()
                frameCount = frameCount + 1
                local currentTime = tick()
                if currentTime - lastTime >= 1 then
                    local fps = frameCount
                    fpsLabel.Text = "FPS: " .. fps
                    frameCount = 0
                    lastTime = currentTime
                end
            end)
            
            WindUI:Notify({
                Title = "FPS显示",
                Content = "FPS显示已启用",
                Duration = 2
            })
        else
            if _G.fpsConnection then
                _G.fpsConnection:Disconnect()
                _G.fpsConnection = nil
            end
            
            local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local fpsGui = playerGui:FindFirstChild("FPSGui")
                if fpsGui then
                    fpsGui:Destroy()
                end
            end
            
            WindUI:Notify({
                Title = "FPS显示",
                Content = "FPS显示已禁用",
                Duration = 2
            })
        end
    end
})

-- 游戏脚本按钮
ElementsSection:Button({
    Title = "点击加载99夜",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%2099Night99%E5%A4%9C.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "旧冬99 Night",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载无尽现实",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Endless%20reality%E6%97%A0%E5%B0%BD%E7%8E%B0%E5%AE%9E.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "无尽现实脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载Doors",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBWDoors.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "Doors脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载躲避",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Evade%20%E8%BA%B2%E9%81%BF.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "躲避脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载紧急汉堡",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Emergency%20Burger%E7%B4%A7%E6%80%A5%E6%B1%89%E5%A0%A1.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "紧急汉堡脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载在超市生活7天",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Live%20for%20seven%20days%E5%9C%A8%E8%B6%85%E5%B8%82%E7%94%9F%E5%AD%98%E4%B8%83%E5%A4%A9.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "超市生活脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载停电",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Power%20failure%E5%81%9C%E7%94%B5.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "停电脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载墨水",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Ink%20Game%E5%A2%A8%E6%B0%B4%E6%B8%B8%E6%88%8F.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "墨水脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载被遗弃",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBWForsaken.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "被遗弃脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载最强战场",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20The%20strongest%20battlefield%20%E6%9C%80%E5%BC%BA%E6%88%98%E5%9C%BA.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "最强战场脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载暴力区",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Violent%20Zone%E6%9A%B4%E5%8A%9B%E5%8C%BA.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "暴力区脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载恶魔学",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/%E6%81%B6%E9%AD%94%E5%AD%A6.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "恶魔学脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载战争大亨",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/%E6%88%98%E4%BA%89%E5%A4%A7%E4%BA%A8.lua", true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "战争大亨脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载种植花园",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/%E7%A7%8D%E6%A4%8D.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "种植花园脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载通缉",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Wanted%E9%80%9A%E7%BC%89.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "通缉脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载力量传奇",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Legend%20of%20Power%E5%8A%9B%E9%87%8F%E4%BC%A0%E5%A5%87.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "力量传奇脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载模仿者",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Copycat%E6%A8%A1%E4%BB%BF%E8%80%85.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "模仿者脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载死铁轨",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Dead%20Rail%20%E6%AD%BB%E9%93%81%E8%BD%A8.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "死铁轨脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载犯罪",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20commit%20%E7%8A%AF%E7%BD%AA.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "犯罪脚本",
                Icon = "sword",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载凹凸世界",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Concave-convex%20world%E5%87%B9%E5%87%B8%E4%B8%96%E7%95%8C.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "凹凸世界脚本",
                Icon = "crown",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

ElementsSection:Button({
    Title = "点击加载感染微笑",
    Icon = "bell",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Infected%20smile%E6%84%9F%E6%9F%93%E5%BE%AE%E7%AC%91.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "感染微笑脚本",
                Icon = "bell",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

-- 外观选项卡
safeCreate(function()
    AppearanceTab:Paragraph({
        Title = "自定义界面",
        Desc = "个性化你的体验",
        Image = "palette",
        ImageSize = 20,
        Color = Color3.fromHex("#FFFFFF")
    })
end)

-- 主题选择
local themes = {}
for themeName, _ in pairs(WindUI:GetThemes() or {}) do
    table.insert(themes, themeName)
end
table.sort(themes)

local canchangetheme = true
local canchangedropdown = true

local themeDropdown
safeCreate(function()
    themeDropdown = AppearanceTab:Dropdown({
        Title = "改颜色",
        Values = themes,
        Value = "Dark",
        Callback = function(theme)
            canchangedropdown = false
            WindUI:SetTheme(theme)
            WindUI:Notify({
                Title = "主题已应用",
                Content = theme,
                Icon = "palette",
                Duration = 2
            })
            canchangedropdown = true
        end
    })
end)

local transparencySlider
safeCreate(function()
    transparencySlider = AppearanceTab:Slider({
        Title = "背景颜色",
        Min = 0,
        Max = 1,
        Default = 0.2,
        Value = 0.2,
        Step = 0.1,
        Callback = function(value)
            WindUI.TransparencyValue = tonumber(value)
            if Window.ToggleTransparency then
                Window:ToggleTransparency(tonumber(value) > 0)
            end
        end
    })
end)

local ThemeToggle
safeCreate(function()
    ThemeToggle = AppearanceTab:Toggle({
        Title = "启用深色模式",
        Desc = "使用深色配色方案",
        Value = true,
        Callback = function(state)
            if canchangetheme then
                WindUI:SetTheme(state and "Dark" or "Light")
            end
            if canchangedropdown and themeDropdown and themeDropdown.Select then
                themeDropdown:Select(state and "Dark" or "Light")
            end
        end
    })
end)

WindUI:OnThemeChange(function(theme)
    canchangetheme = false
    if ThemeToggle and ThemeToggle.Set then
        ThemeToggle:Set(theme == "Dark")
    end
    canchangetheme = true
end)

-- 配置选项卡
safeCreate(function()
    ConfigTab:Paragraph({
        Title = "配置管理器",
        Desc = "保存和加载你的设置",
        Image = "save",
        ImageSize = 20,
        Color = Color3.fromHex("#FFFFFF")
    })
end)

-- 简单配置保存功能
local configName = "默认配置"
local savedConfigs = {}

safeCreate(function()
    ConfigTab:Input({
        Title = "配置名称",
        Desc = "输入配置文件的名称",
        Value = configName,
        Callback = function(value)
            configName = value or "默认配置"
        end
    })
end)

-- 保存配置
safeCreate(function()
    ConfigTab:Button({
        Title = "保存配置",
        Icon = "save",
        Variant = "Primary",
        Callback = function()
            local config = {
                name = configName,
                timestamp = os.date("%Y-%m-%d %H:%M:%S"),
                settings = {
                    killAura = killAuraToggle and killAuraToggle:Get() or false,
                    esp = espToggle and espToggle:Get() or false,
                    noclip = noclipToggle and noclipToggle:Get() or false,
                    nightVision = nightVisionToggle and nightVisionToggle:Get() or false,
                    infiniteJump = infiniteJumpToggle and infiniteJumpToggle:Get() or false,
                    godMode = godModeToggle and godModeToggle:Get() or false,
                    fps = fpsToggle and fpsToggle:Get() or false,
                    theme = themeDropdown and themeDropdown:Get() or "Dark",
                    speed = SpeedSlider and SpeedSlider:Get() or 16,
                    jump = JumpSlider and JumpSlider:Get() or 50,
                    flyOff = FlyOffToggle and FlyOffToggle:Get() or false
                }
            }
            
            savedConfigs[configName] = config
            
            WindUI:Notify({ 
                Title = "保存成功", 
                Content = "配置已保存为: " .. configName,
                Icon = "check",
                Duration = 3
            })
        end
    })
end)

-- 加载配置
safeCreate(function()
    ConfigTab:Button({
        Title = "加载配置",
        Icon = "folder",
        Callback = function()
            local config = savedConfigs[configName]
            
            if config then
                if config.settings then
                    if killAuraToggle and killAuraToggle.Set then killAuraToggle:Set(config.settings.killAura or false) end
                    if espToggle and espToggle.Set then espToggle:Set(config.settings.esp or false) end
                    if noclipToggle and noclipToggle.Set then noclipToggle:Set(config.settings.noclip or false) end
                    if nightVisionToggle and nightVisionToggle.Set then nightVisionToggle:Set(config.settings.nightVision or false) end
                    if infiniteJumpToggle and infiniteJumpToggle.Set then infiniteJumpToggle:Set(config.settings.infiniteJump or false) end
                    if godModeToggle and godModeToggle.Set then godModeToggle:Set(config.settings.godMode or false) end
                    if fpsToggle and fpsToggle.Set then fpsToggle:Set(config.settings.fps or false) end
                    if FlyOffToggle and FlyOffToggle.Set then FlyOffToggle:Set(config.settings.flyOff or false) end
                    
                    if config.settings.speed and SpeedSlider and SpeedSlider.Set then
                        SpeedSlider:Set(config.settings.speed)
                    end
                    
                    if config.settings.jump and JumpSlider and JumpSlider.Set then
                        JumpSlider:Set(config.settings.jump)
                    end
                    
                    if config.settings.theme and themeDropdown and themeDropdown.Select then
                        themeDropdown:Select(config.settings.theme)
                    end
                end
                
                WindUI:Notify({ 
                    Title = "加载成功", 
                    Content = "已加载: " .. configName .. "\n保存时间: " .. (config.timestamp or "未知时间"),
                    Icon = "refresh-cw",
                    Duration = 5
                })
            else
                WindUI:Notify({ 
                    Title = "加载失败", 
                    Content = "配置不存在: " .. configName,
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
end)

-- 底部信息
safeCreate(function()
    ConfigTab:Paragraph({
        Title = "旧冬主群",
        Desc = "QQ主群1081649265",
        Image = "users",
        ImageSize = 20,
        Color = Color3.fromHex("#888888"),
        Buttons = {
            {
                Title = "复制群号",
                Icon = "copy",
                Variant = "Tertiary",
                Callback = function()
                    if setclipboard then
                        setclipboard("1081649265")
                        WindUI:Notify({
                            Title = "复制成功",
                            Content = "群号已复制到剪贴板",
                            Duration = 2
                        })
                    else
                        WindUI:Notify({
                            Title = "复制失败",
                            Content = "不支持剪贴板功能",
                            Duration = 2
                        })
                    end
                end
            }
        }
    })
end)

safeCreate(function()
    ConfigTab:Paragraph({
        Title = "副群",
        Desc = "QQ副群1033860101",
        Image = "users",
        ImageSize = 20,
        Color = Color3.fromHex("#888888"),
        Buttons = {
            {
                Title = "复制群号",
                Icon = "copy",
                Variant = "Tertiary",
                Callback = function()
                    if setclipboard then
                        setclipboard("1033860101")
                        WindUI:Notify({
                            Title = "复制成功",
                            Content = "群号已复制到剪贴板",
                            Duration = 2
                        })
                    else
                        WindUI:Notify({
                            Title = "复制失败",
                            Content = "不支持剪贴板功能",
                            Duration = 2
                        })
                    end
                end
            }
        }
    })
end)

-- LiJianSection
local LiJianSection
safeCreate(function()
    LiJianSection = LiJianTab:Section({
        Title = "FE脚本",
        Icon = "crown",
    })
end)

if not LiJianSection then
    LiJianSection = { Button = function() end, Toggle = function() return { Set = function() end } end }
end

LiJianSection:Button({
    Title = "FE翻墙",
    Icon = "play",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20WallHop%20V4%20script', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "FE翻墙脚本",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

LiJianSection:Button({
    Title = "FE爬行",
    Icon = "crown",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_vZDX8j5ggfAf58QhdJ59BVEmF6nmZgq4Mcjt2l8wn16CiStIW2P6EkNc605qv9K4.lua.txt', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "FE爬行脚本",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

LiJianSection:Button({
    Title = "FE杀手",
    Icon = "play",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://pastefy.ga/d7sogwNS/raw', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "FE杀手脚本",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

LiJianSection:Toggle({
    Title = "FE R15隐身",
    Desc = "R15隐身功能",
    Value = false,
    Callback = function(state)
        if state then
            local removeNametags = false

            local plr = game:GetService("Players").LocalPlayer
            local character = plr.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local old = hrp.CFrame

            if not character:FindFirstChild("LowerTorso") or character.PrimaryPart ~= hrp then
                WindUI:Notify({
                    Title = "FE隐身",
                    Content = "不支持非R15角色",
                    Duration = 3
                })
                return
            end

            if removeNametags then
                local tag = hrp:FindFirstChildOfClass("BillboardGui")
                if tag then tag:Destroy() end

                hrp.ChildAdded:Connect(function(item)
                    if item:IsA("BillboardGui") then
                        task.wait()
                        item:Destroy()
                    end
                end)
            end

            local newroot = character.LowerTorso.Root:Clone()
            hrp.Parent = workspace
            character.PrimaryPart = hrp
            character:MoveTo(Vector3.new(old.X, 9e9, old.Z))
            hrp.Parent = character
            task.wait(0.5)
            newroot.Parent = hrp
            hrp.CFrame = old
            
            WindUI:Notify({
                Title = "FE隐身",
                Content = "R15隐身已启用",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "FE隐身",
                Content = "R15隐身已禁用",
                Duration = 3
            })
        end
    end
})

LiJianSection:Button({
    Title = "FE踢",
    Icon = "play",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/ZhenX21/FE-Kick-Ban-Script/main/source', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "FE踢脚本",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

LiJianSection:Button({
    Title = "FE闪回",
    Icon = "play",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://mscripts.vercel.app/scfiles/reverse-script.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "FE闪回脚本",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

LiJianSection:Button({
    Title = "FE被遗弃角色",
    Icon = "play",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/CyberNinja103/brodwa/refs/heads/main/ForsakationHub', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "FE被遗弃角色脚本",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

-- XiaoXuSection
local XiaoXuSection
safeCreate(function()
    XiaoXuSection = XiaoXuTab:Section({
        Title = "脚本工具",
        Icon = "crown",
    })
end)

if not XiaoXuSection then
    XiaoXuSection = { Button = function() end }
end

XiaoXuSection:Button({
    Title = "DexV3 无汉化",
    Icon = "play",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "Dex",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

XiaoXuSection:Button({
    Title = "汉化Dex",
    Icon = "play",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Xingyan777/roblox/refs/heads/main/bex.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "汉化Dex",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

XiaoXuSection:Button({
    Title = "汉化spy",
    Icon = "star",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Finaloutcome/plz/refs/heads/main/sp3hu.lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "汉化spy",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

XiaoXuSection:Button({
    Title = "抓包https spy",
    Icon = "moon",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/BS58dL/BS/refs/heads/main/请多多支持BS脚本系列.Lua', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "抓包https spy",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

XiaoXuSection:Button({
    Title = "汉化spy2",
    Icon = "zap",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/spy%E6%B1%89%E5%8C%96%20(1).txt', true))()
        end)
        
        if success then
            WindUI:Notify({
                Title = "已启用",
                Content = "汉化spy2",
                Icon = "star",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "加载失败",
                Content = "请检查网络连接",
                Icon = "x",
                Duration = 3
            })
        end
    end
})

-- 时间标签更新
task.spawn(function()
    while true do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        
        if TimeTag and TimeTag.SetTitle then
            TimeTag:SetTitle(hours .. ":" .. minutes)
        end
        
        task.wait(30)
    end
end)

-- 窗口关闭时的清理
Window:OnClose(function()
    print("旧冬v6.0 - 窗口已关闭")
    
    if _G.Noclip and _G.NoclipConnection then
        _G.Noclip = false
        _G.NoclipConnection:Disconnect()
        _G.NoclipConnection = nil
    end
    
    if _G.InfiniteJumpEnabled and _G.InfiniteJumpConnection then
        _G.InfiniteJumpEnabled = false
        _G.InfiniteJumpConnection:Disconnect()
        _G.InfiniteJumpConnection = nil
    end
    
    if _G.fpsConnection then
        _G.fpsConnection:Disconnect()
        _G.fpsConnection = nil
    end
    
    if _G.killAuraConfig then
        _G.killAuraConfig.isRunning = false
        if _G.killAuraConfig.connection then
            _G.killAuraConfig.connection:Disconnect()
        end
        _G.killAuraConfig = nil
    end
    
    if _G.espBoxes then
        for name, box in pairs(_G.espBoxes) do
            if box then
                pcall(function() box:Destroy() end)
            end
        end
        _G.espBoxes = nil
    end
    
    if _G.espConnections then
        for name, connection in pairs(_G.espConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        _G.espConnections = nil
    end
    
    if _G.flyOffEnabled then
        _G.flyOffEnabled = false
        if _G.flyOffConnections then
            for _, conn in ipairs(_G.flyOffConnections) do
                if conn then
                    conn:Disconnect()
                end
            end
            _G.flyOffConnections = nil
        end
    end
    
    local Lighting = game:GetService("Lighting")
    if _G.originalAmbient then
        Lighting.Ambient = _G.originalAmbient
        _G.originalAmbient = nil
    end
    
    if _G.originalOutdoorAmbient then
        Lighting.OutdoorAmbient = _G.originalOutdoorAmbient
        _G.originalOutdoorAmbient = nil
    end
    
    if _G.originalMaxHealth then
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = _G.originalMaxHealth
                humanoid.Health = math.min(_G.originalHealth or 100, _G.originalMaxHealth)
            end
        end
        _G.originalMaxHealth = nil
        _G.originalHealth = nil
    end
    
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local fpsGui = playerGui:FindFirstChild("FPSGui")
        if fpsGui then
            fpsGui:Destroy()
        end
    end
    
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
end)

-- 全局错误处理
local function safeCall(callback, errorMessage)
    local success, err = pcall(callback)
    if not success then
        warn(errorMessage .. ": " .. tostring(err))
        WindUI:Notify({
            Title = "错误",
            Content = errorMessage,
            Icon = "x",
            Duration = 3
        })
    end
    return success
end

-- 显示启动成功消息
task.wait(1)
safeCall(function()
    WindUI:Notify({
        Title = "旧冬v6.0",
        Content = "加载完成",
        Icon = "check",
        Duration = 3
    })
end, "启动通知失败")