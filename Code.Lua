if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(1.5)

local Services = {
    Http = game:GetService("HttpService"),
    TP = game:GetService("TeleportService"),
    TS = game:GetService("TweenService"),
    UIS = game:GetService("UserInputService"),
    Run = game:GetService("RunService"),
    VU = game:GetService("VirtualUser"),
    Players = game:GetService("Players"),
    Core = game:GetService("CoreGui"),
    Log = game:GetService("LogService"),
    Market = game:GetService("MarketplaceService"),
    Lighting = game:GetService("Lighting")
}

local LP = Services.Players.LocalPlayer
local UI = { ActiveNotifs = {}, Pages = {}, NavBtns = {}, Connections = {}, Toggles = {} }
_G.pDrawings = {}
_G.ConfigState = {}
_G.ConfigUpdaters = {}
_G.UserBinds = {}

local Colors = {
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(22, 22, 22),
    ToggleShell = Color3.fromRGB(30, 30, 30),
    Border = Color3.fromRGB(40, 40, 40),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Active = Color3.fromRGB(220, 190, 255) 
}

_G.CurrentGradientColors = {Colors.Background, Colors.Active}
_G.NotificationAssetID = "rbxthumb://type=Asset&id=115669221263328&w=150&h=150"
_G.MainMenuLoaded = false
_G.UseNewNotifications = false
_G.NewDesignActive = false
_G.NotificationsEnabled = true

local TWEEN_INFO_FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_INFO_SMOOTH = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then instance[k] = v end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

local function makeDraggable(guiObj, dragHandle)
    dragHandle = dragHandle or guiObj
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true; dragStart = input.Position; startPos = guiObj.Position 
        end
    end)
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end
    end)
    Services.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function applyGradient(obj)
    local grad = Instance.new("UIGradient", obj)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, _G.CurrentGradientColors[1]),
        ColorSequenceKeypoint.new(1, _G.CurrentGradientColors[2])
    })
    grad.Rotation = 45
end
_G.applyGradient = applyGradient

_G.changeTheme = function(c1, c2)
    _G.CurrentGradientColors = {c1, c2}
    Colors.Active = c2
    if not UI.Screen then return end
    for _, v in pairs(UI.Screen:GetDescendants()) do
        if v:IsA("UIGradient") then 
            v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}) 
        elseif v:IsA("UIStroke") and v.Parent.Name ~= "MainFrame" then
            v.Color = c2
        elseif v.Name == "Indicator" and v.BackgroundTransparency == 0 then
            v.BackgroundColor3 = c2
        end
    end
end

local GuiParent = Services.Run:IsStudio() and LP.PlayerGui or Services.Core:FindFirstChild("RobloxGui") or LP:WaitForChild("PlayerGui")
UI.Screen = Create("ScreenGui", {
    Name = "SeptusHub_VactoryUI",
    Parent = GuiParent,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true
})

local function showNotification(message)
    if not _G.NotificationsEnabled then return end
    
    local notifFrame = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 280, 0, 65),
        Position = UDim2.new(1, 310, 1, -85),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        ZIndex = 10000
    })
    Create("UICorner", { Parent = notifFrame, CornerRadius = UDim.new(0, 6) })
    local stroke = Create("UIStroke", { Parent = notifFrame, Color = Colors.Active, Thickness = 1 })

    local girlIcon = Create("ImageLabel", {
        Parent = notifFrame,
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 10, 0.5, -22.5),
        BackgroundTransparency = 1,
        Image = _G.NotificationAssetID
    })
    Create("UICorner", { Parent = girlIcon, CornerRadius = UDim.new(0, 4) })

    local titleLabel = Create("TextLabel", {
        Parent = notifFrame,
        Size = UDim2.new(1, -75, 0, 15),
        Position = UDim2.new(0, 65, 0, 10),
        BackgroundTransparency = 1,
        Text = "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Colors.Active,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local msgLabel = Create("TextLabel", {
        Parent = notifFrame,
        Size = UDim2.new(1, -75, 0, 30),
        Position = UDim2.new(0, 65, 0, 25),
        BackgroundTransparency = 1,
        Text = message,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Colors.TextMain,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    for _, oldNotif in ipairs(UI.ActiveNotifs) do
        if oldNotif and oldNotif.Parent then
            Services.TS:Create(oldNotif, TWEEN_INFO_FAST, {Position = UDim2.new(1, -295, 1, oldNotif.Position.Y.Offset - 75)}):Play()
        end
    end

    table.insert(UI.ActiveNotifs, notifFrame)
    Services.TS:Create(notifFrame, TWEEN_INFO_FAST, {Position = UDim2.new(1, -295, 1, -85)}):Play()

    task.delay(4, function()
        if not notifFrame or not notifFrame.Parent then return end
        local outTween = Services.TS:Create(notifFrame, TWEEN_INFO_FAST, {Position = UDim2.new(1, 310, 1, notifFrame.Position.Y.Offset), BackgroundTransparency = 1})
        Services.TS:Create(titleLabel, TWEEN_INFO_FAST, {TextTransparency = 1}):Play()
        Services.TS:Create(msgLabel, TWEEN_INFO_FAST, {TextTransparency = 1}):Play()
        Services.TS:Create(girlIcon, TWEEN_INFO_FAST, {ImageTransparency = 1}):Play()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Transparency = 1}):Play()
        outTween:Play()
        outTween.Completed:Wait()
        local idx = table.find(UI.ActiveNotifs, notifFrame)
        if idx then table.remove(UI.ActiveNotifs, idx) end
        notifFrame:Destroy()
    end)
end

local function CreateStyledCard(parent, sizeY)
    local card = Create("Frame", {
        Size = UDim2.new(1, -6, 0, sizeY),
        BackgroundColor3 = Colors.Surface,
        Parent = parent,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = card, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = card, Color = Colors.Border, Thickness = 1 })
    return card
end

local function createToggle(parent, name, y, defaultState, callback)
    local card = CreateStyledCard(parent, 40)
    card.Position = UDim2.new(0, 0, 0, y)

    local lbl = Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local switchShell = Create("Frame", {
        Parent = card,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 38, 0, 22),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = switchShell, CornerRadius = UDim.new(0, 5) })
    local stroke = Create("UIStroke", { Parent = switchShell, Color = Colors.Border, Thickness = 1 })

    local knob = Create("Frame", {
        Parent = switchShell,
        Position = defaultState and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = defaultState and Colors.TextMain or Colors.TextDim,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = knob, CornerRadius = UDim.new(0, 4) })

    local clickArea = Create("TextButton", {
        Parent = switchShell,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })

    local state = defaultState or false

    local function updateVisuals(st, showNotif)
        local targetPos = st and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
        local targetColor = st and Colors.Active or Colors.TextDim
        local borderHex = st and Colors.Active or Colors.Border
        
        Services.TS:Create(knob, TWEEN_INFO_FAST, {Position = targetPos, BackgroundColor3 = targetColor}):Play()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Color = borderHex}):Play()
        
        if showNotif then 
            showNotification(name .. (st and " включен!" or " выключен.")) 
        end
    end

    local function setState(newState, isLoad)
        state = newState
        updateVisuals(state, not isLoad)
        _G.ConfigState[name] = state
        if callback then callback(state) end
    end

    clickArea.MouseButton1Click:Connect(function() setState(not state, false) end)
    _G.ConfigUpdaters[name] = function(val) setState(val, true) end
    
    updateVisuals(state, false)
    _G.ConfigState[name] = state

    return card, knob, setState
end

local function createSlider(parent, yPos, name, min, max, default, callback)
    local card = CreateStyledCard(parent, 55)
    card.Position = UDim2.new(0, 0, 0, yPos)
    
    local lbl = Create("TextLabel", {
        Parent = card,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = name .. ": " .. default,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local bg = Create("TextButton", {
        Parent = card,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 34),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = bg })

    local fill = Create("Frame", {
        Parent = bg,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Colors.Active,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = fill })

    local knob = Create("Frame", {
        Parent = bg,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Colors.TextMain,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local dragging = false
    local function update(x, isValue)
        local p, val
        if isValue then
            val = math.clamp(x, min, max)
            p = (val - min) / (max - min)
        else
            p = math.clamp((x - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            val = math.floor(min + (max - min) * p)
        end
        lbl.Text = name .. ": " .. val
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -6, 0.5, -6)
        _G.ConfigState[name] = val
        if callback then callback(val) end
    end

    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i.Position.X)
        end
    end)
    Services.UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    Services.UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    _G.ConfigUpdaters[name] = function(val) update(val, true) end
    _G.ConfigState[name] = default
    return card
end

local function createMenuBtn(parent, text, posY, showArrow)
    local btn = Create("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, -6, 0, 36),
        Position = UDim2.new(0, 3, 0, posY),
        BackgroundColor3 = Colors.Surface,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })
    local stroke = Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

    local lbl = Create("TextLabel", {
        Parent = btn,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local arrow = nil
    if showArrow then
        arrow = Create("TextLabel", {
            Parent = btn,
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Center
        })
    end

    btn.MouseEnter:Connect(function()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play()
    end)
    btn.MouseLeave:Connect(function()
        Services.TS:Create(stroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play()
    end)

    return btn, arrow, lbl
end

local function createFloatingMenu(titleText, sizeX, sizeY)
    sizeX = sizeX or 320
    sizeY = sizeY or 280
    
    local win = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, sizeX, 0, sizeY),
        Position = UDim2.new(0.5, -sizeX/2, 0.5, -sizeY/2),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Create("UICorner", { Parent = win, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = win, Color = Colors.Border, Thickness = 1 })

    local topBar = Create("Frame", {
        Parent = win,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1
    })
    makeDraggable(win, topBar)

    local title = Create("TextLabel", {
        Parent = topBar,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = titleText,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local minBtn = Create("TextButton", {
        Parent = topBar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -55, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "—",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 14
    })

    local closeBtn = Create("TextButton", {
        Parent = topBar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 18
    })

    local scroll = Create("ScrollingFrame", {
        Parent = win,
        Size = UDim2.new(1, -20, 1, -85),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local layout = Create("UIListLayout", { Parent = scroll, Padding = UDim.new(0, 6) })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local actionBtn = Create("TextButton", {
        Parent = win,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 1, -40),
        BackgroundColor3 = Colors.Surface,
        Text = "",
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = actionBtn, CornerRadius = UDim.new(0, 6) })
    local actStroke = Create("UIStroke", { Parent = actionBtn, Color = Colors.Border, Thickness = 1 })

    local actionLbl = Create("TextLabel", {
        Parent = actionBtn,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = titleText .. ": [None]",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12
    })

    actionBtn.MouseEnter:Connect(function() Services.TS:Create(actStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
    actionBtn.MouseLeave:Connect(function() Services.TS:Create(actStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

    local isMin = false
    minBtn.MouseButton1Click:Connect(function()
        isMin = not isMin
        Services.TS:Create(win, TWEEN_INFO_FAST, {Size = UDim2.new(0, sizeX, 0, isMin and 36 or sizeY)}):Play()
        scroll.Visible = not isMin
        actionBtn.Visible = not isMin
    end)

    return win, closeBtn, scroll, layout, actionBtn, actionLbl
end

local function populatePlayers(scroll, layout, actionLbl, defaultText, targetCallback)
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        if plr ~= LP then
            local btn = Create("TextButton", {
                Parent = scroll,
                Size = UDim2.new(1, -5, 0, 26),
                BackgroundColor3 = Colors.Surface,
                Text = plr.Name,
                TextColor3 = Colors.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                BorderSizePixel = 0
            })
            Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
            local bStroke = Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

            btn.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
            btn.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

            btn.MouseButton1Click:Connect(function() 
                targetCallback(plr)
                actionLbl.Text = defaultText .. ": " .. plr.Name 
            end)
        end
    end
end

local WelcomeGui = Create("Frame", {
    Parent = UI.Screen,
    Size = UDim2.new(0, 400, 0, 180),
    Position = UDim2.new(0.5, -200, 0.5, -90),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ZIndex = 50000
})
Create("UICorner", { Parent = WelcomeGui, CornerRadius = UDim.new(0, 8) })
Create("UIStroke", { Parent = WelcomeGui, Color = Colors.Border, Thickness = 1 })

local welcomeSnow = Create("Frame", { Parent = WelcomeGui, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 0 })
local wRNG = Random.new()
task.spawn(function()
    while WelcomeGui and WelcomeGui.Parent do
        local size = wRNG:NextNumber(2, 4)
        local fl = Create("Frame", {
            Parent = welcomeSnow,
            Size = UDim2.new(0, size, 0, size),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = wRNG:NextNumber(0.4, 0.8),
            BorderSizePixel = 0,
            Position = UDim2.new(wRNG:NextNumber(0, 1), 0, -0.05, 0)
        })
        Create("UICorner", { Parent = fl, CornerRadius = UDim.new(1, 0) })
        Services.TS:Create(fl, TweenInfo.new(wRNG:NextNumber(3, 7), Enum.EasingStyle.Linear), {Position = UDim2.new(fl.Position.X.Scale + wRNG:NextNumber(-0.1, 0.1), 0, 1.05, 0)}):Play()
        task.wait(0.4)
    end
end)

local wTxt = Create("TextLabel", {
    Parent = WelcomeGui,
    Size = UDim2.new(1, -40, 0, 60),
    Position = UDim2.new(0, 20, 0, 25),
    BackgroundTransparency = 1,
    Text = "Скрипт находится на стадии бета-тестирования, возможны небольшие баги и недоработки.",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Colors.TextMain,
    TextWrapped = true,
    ZIndex = 1
})

local GithubBtn = Create("TextButton", {
    Parent = WelcomeGui,
    Size = UDim2.new(0, 170, 0, 36),
    Position = UDim2.new(0, 20, 0, 110),
    BackgroundColor3 = Colors.Surface,
    Text = "Наш GitHub",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    ZIndex = 1
})
Create("UICorner", { Parent = GithubBtn, CornerRadius = UDim.new(0, 6) })
local ghStroke = Create("UIStroke", { Parent = GithubBtn, Color = Colors.Border, Thickness = 1 })
GithubBtn.MouseButton1Click:Connect(function() 
    pcall(function() setclipboard("https://github.com/CherryCalCor") end) 
    showNotification("Ссылка скопирована в буфер обмена!")
end)

local LaunchBtn = Create("TextButton", {
    Parent = WelcomeGui,
    Size = UDim2.new(0, 170, 0, 36),
    Position = UDim2.new(1, -190, 0, 110),
    BackgroundColor3 = Colors.Active,
    Text = "Запустить меню",
    TextColor3 = Colors.Background,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    ZIndex = 1
})
Create("UICorner", { Parent = LaunchBtn, CornerRadius = UDim.new(0, 6) })

local welcomeDone = false
LaunchBtn.MouseButton1Click:Connect(function() 
    welcomeDone = true 
    WelcomeGui:Destroy() 
end)
makeDraggable(WelcomeGui)
repeat task.wait() until welcomeDone

local LoadingFrame = Create("Frame", {
    Parent = UI.Screen,
    Size = UDim2.new(0, 460, 0, 260),
    Position = UDim2.new(0.5, -230, 0.5, -130),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ZIndex = 60000
})
Create("UICorner", { Parent = LoadingFrame, CornerRadius = UDim.new(0, 10) })
Create("UIStroke", { Parent = LoadingFrame, Color = Colors.Border, Thickness = 1 })

local loadSnow = Create("Frame", { Parent = LoadingFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 0 })
task.spawn(function()
    while LoadingFrame and LoadingFrame.Parent do
        local size = wRNG:NextNumber(2, 4)
        local fl = Create("Frame", {
            Parent = loadSnow,
            Size = UDim2.new(0, size, 0, size),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = wRNG:NextNumber(0.4, 0.8),
            BorderSizePixel = 0,
            Position = UDim2.new(wRNG:NextNumber(0, 1), 0, -0.05, 0)
        })
        Create("UICorner", { Parent = fl, CornerRadius = UDim.new(1, 0) })
        Services.TS:Create(fl, TweenInfo.new(wRNG:NextNumber(3, 7), Enum.EasingStyle.Linear), {Position = UDim2.new(fl.Position.X.Scale + wRNG:NextNumber(-0.1, 0.1), 0, 1.05, 0)}):Play()
        task.wait(0.3)
    end
end)

local LoadingTitle = Create("TextLabel", {
    Parent = LoadingFrame,
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0.55, -20),
    BackgroundTransparency = 1,
    Text = "SEPTUS HUB",
    Font = Enum.Font.GothamBlack,
    TextSize = 28,
    TextColor3 = Colors.Active,
    ZIndex = 1
})

local LoadingLogo = Create("ImageLabel", {
    Parent = LoadingFrame,
    Size = UDim2.new(0, 70, 0, 70),
    Position = UDim2.new(0.5, -35, 0.35, -45),
    BackgroundTransparency = 1,
    Image = _G.NotificationAssetID,
    ZIndex = 1
})
Create("UICorner", { Parent = LoadingLogo, CornerRadius = UDim.new(0, 8) })

local LoadingBarBG = Create("Frame", {
    Parent = LoadingFrame,
    Size = UDim2.new(0, 220, 0, 6),
    Position = UDim2.new(0.5, -110, 0.72, 0),
    BackgroundColor3 = Colors.ToggleShell,
    BorderSizePixel = 0,
    ZIndex = 1
})
Create("UICorner", { Parent = LoadingBarBG })

local LoadingBar = Create("Frame", {
    Parent = LoadingBarBG,
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Colors.Active,
    BorderSizePixel = 0,
    ZIndex = 2
})
Create("UICorner", { Parent = LoadingBar })

local barTween = Services.TS:Create(LoadingBar, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
barTween:Play()
barTween.Completed:Wait()

local fadeTween = Services.TS:Create(LoadingFrame, TWEEN_INFO_SMOOTH, {BackgroundTransparency = 1})
Services.TS:Create(LoadingTitle, TWEEN_INFO_FAST, {TextTransparency = 1}):Play()
Services.TS:Create(LoadingBarBG, TWEEN_INFO_FAST, {BackgroundTransparency = 1}):Play()
Services.TS:Create(LoadingBar, TWEEN_INFO_FAST, {BackgroundTransparency = 1}):Play()
Services.TS:Create(LoadingLogo, TWEEN_INFO_FAST, {ImageTransparency = 1}):Play()
fadeTween:Play()
fadeTween.Completed:Wait()
LoadingFrame:Destroy()
_G.MainMenuLoaded = true

UI.Frame = Create("Frame", {
    Parent = UI.Screen,
    Size = UDim2.new(0, 0, 0, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Colors.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false
})
Create("UICorner", { Parent = UI.Frame, CornerRadius = UDim.new(0, 8) })
local mainStroke = Create("UIStroke", { Parent = UI.Frame, Color = Colors.Border, Thickness = 1 })

local SnowContainer = Create("Frame", { Parent = UI.Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 0 })
local function SpawnSnowflake()
    local size = wRNG:NextNumber(2, 4)
    local flake = Create("Frame", {
        Parent = SnowContainer,
        Size = UDim2.new(0, size, 0, size),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = wRNG:NextNumber(0.4, 0.8),
        BorderSizePixel = 0,
        ZIndex = 0
    })
    Create("UICorner", { Parent = flake, CornerRadius = UDim.new(1, 0) })

    local function AnimateFlake()
        flake.Position = UDim2.new(wRNG:NextNumber(0, 1), 0, -0.05, 0)
        local dur = wRNG:NextNumber(5, 12)
        local tx = flake.Position.X.Scale + wRNG:NextNumber(-0.1, 0.1)
        local tw = Services.TS:Create(flake, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Position = UDim2.new(tx, 0, 1.05, 0)})
        tw.Completed:Connect(AnimateFlake)
        tw:Play()
    end

    flake.Position = UDim2.new(wRNG:NextNumber(0, 1), 0, wRNG:NextNumber(-0.05, 1), 0)
    local initDur = wRNG:NextNumber(2, 8)
    local initTx = flake.Position.X.Scale + wRNG:NextNumber(-0.08, 0.08)
    local initTw = Services.TS:Create(flake, TweenInfo.new(initDur, Enum.EasingStyle.Linear), {Position = UDim2.new(initTx, 0, 1.05, 0)})
    initTw.Completed:Connect(AnimateFlake)
    initTw:Play()
end
for _ = 1, 20 do SpawnSnowflake() end

local Shadow = Create("ImageLabel", {
    Parent = UI.Frame,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 30, 1, 30),
    BackgroundTransparency = 1,
    Image = "rbxassetid://6015897843",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.55,
    SliceCenter = Rect.new(49, 49, 450, 450),
    ScaleType = Enum.ScaleType.Slice,
    ZIndex = -1
})

local Watermark = Create("ImageLabel", {
    Parent = UI.Frame,
    Size = UDim2.new(0, 130, 0, 130),
    Position = UDim2.new(1, -120, 1, -120),
    BackgroundTransparency = 1,
    ImageTransparency = 0.94,
    Image = _G.NotificationAssetID,
    ZIndex = 0
})

local TopBar = Create("Frame", { Parent = UI.Frame, Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1 })
local TitleContainer = Create("Frame", { Parent = TopBar, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1 })
Create("UIListLayout", { Parent = TitleContainer, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8) })

local TitleText = Create("TextLabel", {
    Parent = TitleContainer,
    Size = UDim2.new(0, 0, 1, 0),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 1,
    Text = "SEPTUS HUB",
    TextColor3 = Colors.TextMain,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    LayoutOrder = 1
})

local VersionBadge = Create("Frame", { Parent = TitleContainer, Size = UDim2.new(0, 48, 0, 18), BackgroundColor3 = Colors.Surface, LayoutOrder = 2 })
Create("UICorner", { Parent = VersionBadge, CornerRadius = UDim.new(0, 4) })
Create("UIStroke", { Parent = VersionBadge, Color = Colors.Border, Thickness = 1 })
local VersionTag = Create("TextLabel", { Parent = VersionBadge, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "V2.31B", TextColor3 = Colors.Active, Font = Enum.Font.GothamSemibold, TextSize = 10 })

local Controls = Create("Frame", { Parent = TopBar, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -15, 0.5, 0), Size = UDim2.new(0, 70, 1, 0), BackgroundTransparency = 1 })
Create("UIListLayout", { Parent = Controls, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })

local function CreateCtrlBtn(text, order)
    local b = Create("TextButton", { Parent = Controls, Size = UDim2.new(0, 20, 0, 20), BackgroundTransparency = 1, Text = text, TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 15, LayoutOrder = order, AutoButtonColor = false })
    b.MouseEnter:Connect(function() Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Colors.TextMain}):Play() end)
    b.MouseLeave:Connect(function() Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Colors.TextDim}):Play() end)
    return b
end

local MinBtn = CreateCtrlBtn("—", 1)
local CloseBtn = CreateCtrlBtn("×", 2)

local ContentFrame = Create("Frame", { Parent = UI.Frame, Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 1, -38), BackgroundTransparency = 1 })

local Sidebar = Create("ScrollingFrame", {
    Parent = ContentFrame,
    Size = UDim2.new(0, 130, 1, 0),
    BackgroundTransparency = 1,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Border,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0)
})
Create("UIPadding", { Parent = Sidebar, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 4) })
local SidebarLayout = Create("UIListLayout", { Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 15)
end)

local TabContainer = Create("Frame", { Parent = ContentFrame, Position = UDim2.new(0, 130, 0, 0), Size = UDim2.new(1, -130, 1, 0), BackgroundTransparency = 1 })
Create("UIPadding", { Parent = TabContainer, PaddingTop = UDim.new(0, 8), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })

local function CreatePage(name)
    local scroll = Create("ScrollingFrame", {
        Name = name .. "Tab",
        Parent = TabContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        Visible = false,
        BorderSizePixel = 0
    })
    local layout = Create("UIListLayout", { Parent = scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
    UI.Pages[name] = scroll
    return scroll
end

local ActiveTab = nil
local function CreateTabButton(tabName, order)
    local b = Create("TextButton", {
        Name = tabName.."Btn",
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = tabName,
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        AutoButtonColor = false
    })
    local ind = Create("Frame", {
        Name = "Indicator",
        Parent = b,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -12, 0.5, 0),
        Size = UDim2.new(0, 2, 0, 0),
        BackgroundColor3 = Colors.Active,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = ind })

    b.MouseEnter:Connect(function() if ActiveTab ~= tabName then Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play() end end)
    b.MouseLeave:Connect(function() if ActiveTab ~= tabName then Services.TS:Create(b, TWEEN_INFO_FAST, {TextColor3 = Colors.TextDim}):Play() end end)

    b.MouseButton1Click:Connect(function()
        if ActiveTab == tabName then return end
        for _, child in pairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= tabName.."Btn" then
                Services.TS:Create(child, TWEEN_INFO_SMOOTH, {TextColor3 = Colors.TextDim}):Play()
                Services.TS:Create(child.Indicator, TWEEN_INFO_SMOOTH, {Size = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1}):Play()
            end
        end
        if ActiveTab and UI.Pages[ActiveTab] then
            local prev = UI.Pages[ActiveTab]
            local tw = Services.TS:Create(prev, TWEEN_INFO_FAST, {Position = UDim2.new(0, 0, 0, 8)})
            tw:Play(); tw.Completed:Wait()
            prev.Visible = false
        end
        ActiveTab = tabName
        Services.TS:Create(b, TWEEN_INFO_SMOOTH, {TextColor3 = Colors.TextMain}):Play()
        Services.TS:Create(ind, TWEEN_INFO_SMOOTH, {Size = UDim2.new(0, 3, 0, 16), BackgroundTransparency = 0}):Play()

        local curr = UI.Pages[tabName]
        if curr then
            curr.Position = UDim2.new(0, 0, 0, 8)
            curr.Visible = true
            Services.TS:Create(curr, TWEEN_INFO_SMOOTH, {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end
    end)
end

local HomeTab = CreatePage("Home")
local ServerTab = CreatePage("Server")
local TeleportTab = CreatePage("Teleport")
local MovedTab = CreatePage("Movement")
local VisualsTab = CreatePage("Visuals")
local ShadersTab = CreatePage("Shaders")
local ProtectTab = CreatePage("Protect")
local FunnyTab = CreatePage("Funny")
local ConfigTab = CreatePage("Config")
local QoLTab = CreatePage("QoL")
local MiscTab = CreatePage("Misc") -- Added Misc
local HelpTab = CreatePage("Help")
local SettingsTab = CreatePage("Settings")

CreateTabButton("Home", 1)
CreateTabButton("Server", 2)
CreateTabButton("Visuals", 3)
CreateTabButton("Teleport", 4)
CreateTabButton("Movement", 5)
CreateTabButton("Shaders", 6)
CreateTabButton("Protect", 7)
CreateTabButton("Funny", 8)
CreateTabButton("Config", 9)
CreateTabButton("QoL", 10)
CreateTabButton("Misc", 11) -- Placed immediately after QoL (Order 11)
CreateTabButton("Help", 12)
CreateTabButton("Settings", 13)

do
    local pCard = CreateStyledCard(HomeTab, 65)
    local avatar = Create("ImageLabel", {
        Parent = pCard,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 42, 0, 42),
        BackgroundTransparency = 1,
        Image = Services.Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    })
    Create("UICorner", { Parent = avatar, CornerRadius = UDim.new(1, 0) })
    Create("UIStroke", { Parent = avatar, Color = Colors.Border, Thickness = 1 })

    local welcome = Create("TextLabel", {
        Parent = pCard,
        Position = UDim2.new(0, 64, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, -75, 1, 0),
        BackgroundTransparency = 1,
        Text = "Welcome, " .. LP.Name,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local sCard = CreateStyledCard(HomeTab, 105)
    Create("UIPadding", { Parent = sCard, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12) })
    Create("UIListLayout", { Parent = sCard, Padding = UDim.new(0, 6) })

    local function createStatusLine(key, val)
        local l = Create("TextLabel", {
            Parent = sCard,
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = key .. ": <font color='#ffffff'>" .. val .. "</font>",
            TextColor3 = Colors.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true
        })
        return l
    end

    local gName = "Unknown"
    pcall(function() gName = Services.Market:GetProductInfo(game.PlaceId).Name end)
    createStatusLine("Game", gName)
    local fpsLbl = createStatusLine("FPS", "0")
    local pingLbl = createStatusLine("Ping", "0 ms")
    local playersLbl = createStatusLine("Players", "0")

    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                fpsLbl.Text = "FPS: <font color='#ffffff'>" .. math.floor(workspace:GetRealPhysicsFPS()) .. "</font>"
                pingLbl.Text = "Ping: <font color='#ffffff'>" .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms</font>"
                playersLbl.Text = "Players: <font color='#ffffff'>" .. #Services.Players:GetPlayers() .. "</font>"
            end)
        end
    end)

    local NotepadWin = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 320, 0, 240),
        Position = UDim2.new(0.5, 80, 0.5, -120),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Create("UICorner", { Parent = NotepadWin, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = NotepadWin, Color = Colors.Border, Thickness = 1 })

    local noteTopBar = Create("Frame", { Parent = NotepadWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    makeDraggable(NotepadWin, noteTopBar)
    Create("TextLabel", { Parent = noteTopBar, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Notepad", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local noteMinBtn = Create("TextButton", { Parent = noteTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -55, 0.5, -12), BackgroundTransparency = 1, Text = "—", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 14 })
    local noteCloseBtn = Create("TextButton", { Parent = noteTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local noteBox = Create("TextBox", {
        Parent = NotepadWin,
        Size = UDim2.new(1, -20, 1, -48),
        Position = UDim2.new(0, 10, 0, 38),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextWrapped = true,
        Text = "Write your notes here..."
    })
    Create("UICorner", { Parent = noteBox, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = noteBox, Color = Colors.Border, Thickness = 1 })

    local noteMin = false
    noteMinBtn.MouseButton1Click:Connect(function()
        noteMin = not noteMin
        Services.TS:Create(NotepadWin, TWEEN_INFO_FAST, {Size = UDim2.new(0, 320, 0, noteMin and 34 or 240)}):Play()
        noteBox.Visible = not noteMin
    end)

    local noteTogCard, _, setNotepad = createToggle(HomeTab, "Notepad", 175, false, function(st) NotepadWin.Visible = st end)
    noteCloseBtn.MouseButton1Click:Connect(function() setNotepad(false, true); NotepadWin.Visible = false end)

    local ManualOpPanel = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 320, 0, 42),
        Position = UDim2.new(0.5, -160, 0, 15),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false
    })
    Create("UICorner", { Parent = ManualOpPanel, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = ManualOpPanel, Color = Colors.Border, Thickness = 1 })

    local manInput = Create("TextBox", {
        Parent = ManualOpPanel,
        Size = UDim2.new(1, -85, 1, -12),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        PlaceholderText = "Enter function name...",
        Text = "",
        ClearTextOnFocus = false
    })
    Create("UICorner", { Parent = manInput, CornerRadius = UDim.new(0, 4) })
    Create("UIStroke", { Parent = manInput, Color = Colors.Border, Thickness = 1 })

    local manEnter = Create("TextButton", {
        Parent = ManualOpPanel,
        Size = UDim2.new(0, 65, 1, -12),
        Position = UDim2.new(1, -75, 0, 6),
        BackgroundColor3 = Colors.Active,
        Text = "Enter",
        Font = Enum.Font.GothamBold,
        TextColor3 = Colors.Background,
        TextSize = 12,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = manEnter, CornerRadius = UDim.new(0, 4) })

    local function execCommand()
        local cmd = manInput.Text:lower()
        local found = false
        for name, updater in pairs(_G.ConfigUpdaters) do
            if name:lower() == cmd then
                updater(not _G.ConfigState[name])
                showNotification(name .. " toggled manually!")
                found = true; break
            end
        end
        if not found then showNotification("Function not found: " .. manInput.Text) end
        manInput.Text = ""
    end
    manEnter.MouseButton1Click:Connect(execCommand)
    manInput.FocusLost:Connect(function(enter) if enter then execCommand() end end)

    local manTogCard, _, setManual = createToggle(HomeTab, "Manual operation", 220, false, function(st) ManualOpPanel.Visible = st end)

    local InstrWin = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 340, 0, 280),
        Position = UDim2.new(0.5, -170, 0.5, -140),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Create("UICorner", { Parent = InstrWin, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = InstrWin, Color = Colors.Border, Thickness = 1 })

    local insTopBar = Create("Frame", { Parent = InstrWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    makeDraggable(InstrWin, insTopBar)
    Create("TextLabel", { Parent = insTopBar, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Instruction Manual", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local insCloseBtn = Create("TextButton", { Parent = insTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local insText = Create("TextLabel", {
        Parent = InstrWin,
        Size = UDim2.new(1, -24, 0, 48),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        Text = "В поле текстового ввода введите имя любой функции, например Noclip, затем нажмите enter, и функция включится автоматически.",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    local funcScroll = Create("ScrollingFrame", {
        Parent = InstrWin,
        Size = UDim2.new(1, -24, 1, -100),
        Position = UDim2.new(0, 12, 0, 88),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local funcLayout = Create("UIListLayout", { Parent = funcScroll, Padding = UDim.new(0, 4) })
    funcLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        funcScroll.CanvasSize = UDim2.new(0, 0, 0, funcLayout.AbsoluteContentSize.Y + 5)
    end)

    local function refreshFunctions()
        for _, v in pairs(funcScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
        for name, _ in pairs(_G.ConfigUpdaters) do
            local lbl = Create("TextLabel", {
                Parent = funcScroll,
                Size = UDim2.new(1, -4, 0, 22),
                BackgroundColor3 = Colors.Surface,
                Text = "  " .. name,
                TextColor3 = Colors.Active,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UICorner", { Parent = lbl, CornerRadius = UDim.new(0, 4) })
            Create("UIStroke", { Parent = lbl, Color = Colors.Border, Thickness = 1 })
        end
    end

    local insTogCard, _, setInstr = createToggle(HomeTab, "Instruction manual", 265, false, function(st)
        InstrWin.Visible = st
        if st then refreshFunctions() end
    end)
    insCloseBtn.MouseButton1Click:Connect(function() setInstr(false, true); InstrWin.Visible = false end)

    local TopStatusPanel = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0.3, 0, 0, 32),
        Position = UDim2.new(0.5, 0, 0, 6),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Colors.Background,
        Visible = false,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = TopStatusPanel, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = TopStatusPanel, Color = Colors.Border, Thickness = 1 })

    local topStatusLayout = Create("UIListLayout", { Parent = TopStatusPanel, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12) })

    local function createTopLabel(text)
        local lbl = Create("TextLabel", {
            Parent = TopStatusPanel,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 11
        })
        return lbl
    end

    local topFPS = createTopLabel("FPS: 0")
    local topPing = createTopLabel("Ping: 0 ms")
    local topTime = createTopLabel("Time: 00:00")

    task.spawn(function()
        while task.wait(1) do
            if TopStatusPanel.Visible then
                local fps = math.floor(workspace:GetRealPhysicsFPS())
                local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                local totalSeconds = math.floor(workspace.DistributedGameTime)
                local hours = math.floor(totalSeconds / 3600)
                local mins = math.floor((totalSeconds % 3600) / 60)
                local secs = totalSeconds % 60
                local timeStr = hours > 0 and string.format("%02d:%02d:%02d", hours, mins, secs) or string.format("%02d:%02d", mins, secs)
                topFPS.Text = "FPS: " .. fps
                topPing.Text = "Ping: " .. ping .. " ms"
                topTime.Text = "Time: " .. timeStr
            end
        end
    end)

    local statusTogCard, _, setStatus = createToggle(HomeTab, "Status display", 310, false, function(st) TopStatusPanel.Visible = st end)
end

do
    local serverCard = CreateStyledCard(ServerTab, 90)
    Create("UIPadding", { Parent = serverCard, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
    Create("UIListLayout", { Parent = serverCard, Padding = UDim.new(0, 8) })

    local function createActBtn(text, parent, callback)
        local btn = Create("TextButton", {
            Parent = parent,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Colors.Surface,
            Text = text,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            BorderSizePixel = 0
        })
        Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 6) })
        local bStroke = Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })
        btn.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
        btn.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    createActBtn("🖱 Rejoin", serverCard, function()
        showNotification("Перезаход на сервер...")
        Services.TP:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)

    createActBtn("🖱 Server Hop", serverCard, function()
        showNotification("Ищем другой сервер...")
        task.spawn(function()
            local s, r = pcall(function()
                return Services.Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)
            if s and r and r.data then
                for _, srv in ipairs(r.data) do
                    if srv.playing and srv.maxPlayers and srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                        Services.TP:TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                        return
                    end
                end
            end
            showNotification("Не удалось найти подходящий сервер")
        end)
    end)

    local ServerWidget = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 120, 0, 36),
        Position = UDim2.new(0.5, -60, 0, 20),
        BackgroundColor3 = Colors.Background,
        Visible = false,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = ServerWidget, CornerRadius = UDim.new(0, 6) })
    local sWidgetStroke = Create("UIStroke", { Parent = ServerWidget, Color = Colors.Border, Thickness = 1 })

    local widgetBtn = Create("TextButton", {
        Parent = ServerWidget,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Servers",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12
    })
    makeDraggable(ServerWidget, widgetBtn)

    local ServerMenu = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 360, 0, 280),
        Position = UDim2.new(0.5, -180, 0.5, -140),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Create("UICorner", { Parent = ServerMenu, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = ServerMenu, Color = Colors.Border, Thickness = 1 })

    local srvTopBar = Create("Frame", { Parent = ServerMenu, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    makeDraggable(ServerMenu, srvTopBar)
    Create("TextLabel", { Parent = srvTopBar, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Server List", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    
    local srvSortBtn = Create("TextButton", {
        Parent = srvTopBar,
        Size = UDim2.new(0, 120, 0, 22),
        Position = UDim2.new(1, -195, 0.5, -11),
        BackgroundColor3 = Colors.Surface,
        Text = "Sort: Ascending",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = srvSortBtn, CornerRadius = UDim.new(0, 4) })
    local sortStroke = Create("UIStroke", { Parent = srvSortBtn, Color = Colors.Border, Thickness = 1 })

    local srvMinBtn = Create("TextButton", { Parent = srvTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -60, 0.5, -12), BackgroundTransparency = 1, Text = "—", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 14 })
    local srvCloseBtn = Create("TextButton", { Parent = srvTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local srvScroll = Create("ScrollingFrame", {
        Parent = ServerMenu,
        Size = UDim2.new(1, -24, 1, -48),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local srvLayout = Create("UIListLayout", { Parent = srvScroll, Padding = UDim.new(0, 4) })
    srvLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        srvScroll.CanvasSize = UDim2.new(0, 0, 0, srvLayout.AbsoluteContentSize.Y + 10)
    end)

    local srvSortAsc = true
    local srvMinimized = false

    local function populateServers()
        for _, v in pairs(srvScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        local s, r = pcall(function()
            return Services.Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if s and r and r.data then
            local servers = {}
            for _, srv in pairs(r.data) do
                if srv.playing and srv.maxPlayers and srv.playing < srv.maxPlayers then
                    table.insert(servers, srv)
                end
            end
            table.sort(servers, function(a, b)
                return srvSortAsc and a.playing < b.playing or a.playing > b.playing
            end)
            for _, srv in ipairs(servers) do
                local item = Create("Frame", { Parent = srvScroll, Size = UDim2.new(1, -4, 0, 30), BackgroundColor3 = Colors.Surface, BorderSizePixel = 0 })
                Create("UICorner", { Parent = item, CornerRadius = UDim.new(0, 4) })
                local itemStroke = Create("UIStroke", { Parent = item, Color = Colors.Border, Thickness = 1 })

                local info = Create("TextLabel", {
                    Parent = item,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "Players: " .. srv.playing .. "/" .. srv.maxPlayers .. " | Ping: " .. (srv.ping or "?"),
                    TextColor3 = Colors.TextMain,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local join = Create("TextButton", {
                    Parent = item,
                    Size = UDim2.new(0, 60, 0, 22),
                    Position = UDim2.new(1, -70, 0.5, -11),
                    BackgroundColor3 = Colors.Active,
                    Text = "Join",
                    TextColor3 = Colors.Background,
                    Font = Enum.Font.GothamBold,
                    TextSize = 11,
                    BorderSizePixel = 0
                })
                Create("UICorner", { Parent = join, CornerRadius = UDim.new(0, 4) })
                join.MouseButton1Click:Connect(function()
                    showNotification("Подключение...")
                    Services.TP:TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                end)
            end
        end
    end

    srvSortBtn.MouseButton1Click:Connect(function()
        srvSortAsc = not srvSortAsc
        srvSortBtn.Text = srvSortAsc and "Sort: Ascending" or "Sort: Descending"
        task.spawn(populateServers)
    end)

    srvMinBtn.MouseButton1Click:Connect(function()
        srvMinimized = not srvMinimized
        Services.TS:Create(ServerMenu, TWEEN_INFO_FAST, {Size = UDim2.new(0, 360, 0, srvMinimized and 34 or 280)}):Play()
        srvScroll.Visible = not srvMinimized
    end)

    srvCloseBtn.MouseButton1Click:Connect(function() ServerMenu.Visible = false end)
    widgetBtn.MouseButton1Click:Connect(function()
        ServerMenu.Visible = not ServerMenu.Visible
        if ServerMenu.Visible then task.spawn(populateServers) end
    end)

    createToggle(ServerTab, "Servers Toggle", 105, false, function(st)
        ServerWidget.Visible = st
        if not st then ServerMenu.Visible = false end
    end)
end

do
    local TPCard = CreateStyledCard(TeleportTab, 85)
    Create("UIPadding", { Parent = TPCard, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    local avatar = Create("ImageLabel", {
        Parent = TPCard,
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 0, 0, 12),
        BackgroundTransparency = 1,
        Image = "rbxassetid://115669221263328"
    })
    Create("UICorner", { Parent = avatar, CornerRadius = UDim.new(1, 0) })
    Create("UIStroke", { Parent = avatar, Color = Colors.Border, Thickness = 1 })

    local nameLbl = Create("TextLabel", {
        Parent = TPCard,
        Position = UDim2.new(0, 52, 0, 12),
        Size = UDim2.new(1, -60, 0, 15),
        BackgroundTransparency = 1,
        Text = "Select a player...",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local TPPlayer = nil

    local function makeActBtn(text, posX, callback)
        local b = Create("TextButton", {
            Parent = TPCard,
            Size = UDim2.new(0, 95, 0, 26),
            Position = UDim2.new(0, posX, 0, 36),
            BackgroundColor3 = Colors.Surface,
            Text = text,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0
        })
        Create("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
        local bStroke = Create("UIStroke", { Parent = b, Color = Colors.Border, Thickness = 1 })
        b.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
        b.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)
        b.MouseButton1Click:Connect(callback)
        return b
    end

    makeActBtn("Teleport", 52, function()
        if TPPlayer and LP.Character and TPPlayer.Character and TPPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character:MoveTo(TPPlayer.Character.HumanoidRootPart.Position)
            showNotification("Телепортирован к " .. TPPlayer.Name)
        end
    end)

    makeActBtn("Spectate", 155, function()
        if TPPlayer and TPPlayer.Character then
            local hum = TPPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                workspace.CurrentCamera.CameraSubject = hum
                showNotification("Наблюдение за " .. TPPlayer.Name)
            end
        end
    end)

    local PlayersMenu = Create("Frame", {
        Parent = TeleportTab,
        Size = UDim2.new(1, -6, 0, 0),
        Position = UDim2.new(0, 3, 0, 135),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true
    })
    Create("UICorner", { Parent = PlayersMenu, CornerRadius = UDim.new(0, 6) })
    local pMenuStroke = Create("UIStroke", { Parent = PlayersMenu, Color = Colors.Border, Thickness = 1 })

    local pScroll = Create("ScrollingFrame", {
        Parent = PlayersMenu,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local pLayout = Create("UIListLayout", { Parent = pScroll, Padding = UDim.new(0, 4) })
    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pScroll.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 5)
    end)

    local function refreshPlayersList()
        for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP then
                local b = Create("TextButton", {
                    Parent = pScroll,
                    Size = UDim2.new(1, -4, 0, 26),
                    BackgroundColor3 = Colors.Background,
                    Text = plr.Name,
                    TextColor3 = Colors.TextDim,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    BorderSizePixel = 0
                })
                Create("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
                local bStroke = Create("UIStroke", { Parent = b, Color = Colors.Border, Thickness = 1 })
                b.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
                b.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

                b.MouseButton1Click:Connect(function()
                    TPPlayer = plr
                    nameLbl.Text = plr.Name
                    pcall(function()
                        avatar.Image = Services.Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                    end)
                end)
            end
        end
    end

    local playersOpen = false
    local plrsBtn, plrsArrow = createMenuBtn(TeleportTab, "Players", 95, true)
    local toolBtn = createMenuBtn(TeleportTab, "Teleport Tool", 135, false)

    plrsBtn.MouseButton1Click:Connect(function()
        playersOpen = not playersOpen
        refreshPlayersList()
        PlayersMenu.Visible = true
        local menuHeight = playersOpen and 140 or 0
        Services.TS:Create(plrsArrow, TWEEN_INFO_FAST, {Rotation = playersOpen and 180 or 0}):Play()
        Services.TS:Create(PlayersMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, menuHeight)}):Play()
        Services.TS:Create(toolBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 135 + menuHeight)}):Play()
    end)

    toolBtn.MouseButton1Click:Connect(function()
        showNotification("Teleport Tool выдан!")
        local tool = Instance.new("Tool")
        tool.Name = "Teleport Tool"
        tool.RequiresHandle = false
        tool.Parent = LP.Backpack
        table.insert(UI.Connections, tool.Activated:Connect(function()
            local mouse = LP:GetMouse()
            if mouse.Hit and LP.Character then
                LP.Character:MoveTo(mouse.Hit.Position)
            end
        end))
    end)
end

do
    createSlider(MovedTab, 10, "Speed", 16, 200, 16, function(v)
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = v
        end
    end)

    createSlider(MovedTab, 70, "Jump", 50, 200, 50, function(v)
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.UseJumpPower = true
            LP.Character.Humanoid.JumpPower = v
        end
    end)

    local endless = false
    createToggle(MovedTab, "Endless Jump", 130, false, function(st) endless = st end)
    table.insert(UI.Connections, Services.UIS.JumpRequest:Connect(function()
        if endless and LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
            LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))

    local wall = false
    createToggle(MovedTab, "Climbing Walls", 175, false, function(st) wall = st end)
    task.spawn(function()
        while task.wait(0.1) do
            if wall and LP.Character and LP.Character:FindFirstChild("Humanoid") then
                LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
            end
        end
    end)

    local flySpeed = 50
    local speedCard = CreateStyledCard(MovedTab, 40)
    speedCard.Position = UDim2.new(0, 0, 0, 220)
    
    local speedLbl = Create("TextLabel", {
        Parent = speedCard,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "Flight Speed",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local speedInput = Create("TextBox", {
        Parent = speedCard,
        Size = UDim2.new(0, 60, 0, 24),
        Position = UDim2.new(1, -72, 0.5, -12),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        Text = tostring(flySpeed)
    })
    Create("UICorner", { Parent = speedInput, CornerRadius = UDim.new(0, 4) })
    local sInStroke = Create("UIStroke", { Parent = speedInput, Color = Colors.Border, Thickness = 1 })
    speedInput.FocusLost:Connect(function()
        local v = tonumber(speedInput.Text)
        if v then flySpeed = v else speedInput.Text = tostring(flySpeed) end
    end)

    local flying = false
    local bg, bv
    createToggle(MovedTab, "Flight (PC & Mobile)", 265, false, function(st)
        flying = st
        local char = LP.Character
        if flying and char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            bg = Instance.new("BodyGyro", hrp); bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = hrp.CFrame
            bv = Instance.new("BodyVelocity", hrp); bv.Velocity = Vector3.new(0,0,0); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            char.Humanoid.PlatformStand = true
        else
            if bg then bg:Destroy() end; if bv then bv:Destroy() end
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
        end
    end)

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if flying and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if not hum then return end
            local cam = workspace.CurrentCamera
            local moveDir = hum.MoveDirection; local vel = Vector3.new()
            if moveDir.Magnitude > 0 then
                local camLook = cam.CFrame.LookVector
                local camRight = cam.CFrame.RightVector
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                local forwardInput = moveDir:Dot(flatLook)
                local rightInput = moveDir:Dot(flatRight)
                vel = (camLook * forwardInput) + (camRight * rightInput)
            end
            if Services.UIS:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
            if Services.UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel + Vector3.new(0, -1, 0) end
            if bv then bv.Velocity = vel.Magnitude > 0 and vel.Unit * flySpeed or Vector3.new(0,0,0) end
            if bg then bg.CFrame = cam.CFrame end
        end
    end))
end

do
    local ESPBtn, Arrow = createMenuBtn(VisualsTab, "ESP", 10, true)
    local ESPMenu = Create("Frame", { Parent = VisualsTab, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local espLayout = Create("UIListLayout", { Parent = ESPMenu, Padding = UDim.new(0, 4) })

    local BoostBtn, BoostArrow = createMenuBtn(VisualsTab, "Boost FPS", 55, true)
    local BoostMenu = Create("Frame", { Parent = VisualsTab, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 95), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local boostLayout = Create("UIListLayout", { Parent = BoostMenu, Padding = UDim.new(0, 4) })

    local MiscBtn, MiscArrow = createMenuBtn(VisualsTab, "Misc", 95, true)
    local MiscMenu = Create("Frame", { Parent = VisualsTab, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 135), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local miscLayout = Create("UIListLayout", { Parent = MiscMenu, Padding = UDim.new(0, 4) })

    local espOpened, boostOpened, miscOpened = false, false, false
    local function updatePositions()
        local espHeight = espOpened and 265 or 0
        local boostHeight = boostOpened and 265 or 0
        local miscHeight = miscOpened and 264 or 0 -- Изменено с 220 на 264 для вмещения новой кнопки
        Services.TS:Create(BoostBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 55 + espHeight)}):Play()
        Services.TS:Create(BoostMenu, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 95 + espHeight)}):Play()
        Services.TS:Create(MiscBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 95 + espHeight + boostHeight)}):Play()
        Services.TS:Create(MiscMenu, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 135 + espHeight + boostHeight)}):Play()
    end

    ESPBtn.MouseButton1Click:Connect(function()
        espOpened = not espOpened
        ESPMenu.Visible = true
        Services.TS:Create(Arrow, TWEEN_INFO_FAST, {Rotation = espOpened and 180 or 0}):Play()
        local t = Services.TS:Create(ESPMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, espOpened and 260 or 0)})
        t:Play(); t.Completed:Wait(); updatePositions()
    end)

    BoostBtn.MouseButton1Click:Connect(function()
        boostOpened = not boostOpened
        BoostMenu.Visible = true
        Services.TS:Create(BoostArrow, TWEEN_INFO_FAST, {Rotation = boostOpened and 180 or 0}):Play()
        local t = Services.TS:Create(BoostMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, boostOpened and 260 or 0)})
        t:Play(); t.Completed:Wait(); updatePositions()
    end)

    MiscBtn.MouseButton1Click:Connect(function()
        miscOpened = not miscOpened
        MiscMenu.Visible = true
        Services.TS:Create(MiscArrow, TWEEN_INFO_FAST, {Rotation = miscOpened and 180 or 0}):Play()
        local t = Services.TS:Create(MiscMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, miscOpened and 264 or 0)}) -- Изменено с 220 на 264
        t:Play(); t.Completed:Wait(); updatePositions()
    end)

    local nameESP, outlineESP, itemESP, boxESP, tracersESP = false, false, false, false, false
    createToggle(ESPMenu, "ESP Name", 0, false, function(st) nameESP = st end)
    createToggle(ESPMenu, "ESP Outline", 44, false, function(st) outlineESP = st end)
    createToggle(ESPMenu, "Item ESP", 88, false, function(st) itemESP = st end)
    createToggle(ESPMenu, "Box ESP", 132, false, function(st) boxESP = st end)
    createToggle(ESPMenu, "Tracers", 176, false, function(st) tracersESP = st end)

    local xrayOriginals = {}
    createToggle(ESPMenu, "X-Ray", 220, false, function(st)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                if st then
                    if not xrayOriginals[obj] then xrayOriginals[obj] = obj.Transparency end
                    obj.Transparency = 0.6
                else
                    if xrayOriginals[obj] then obj.Transparency = xrayOriginals[obj]; xrayOriginals[obj] = nil end
                end
            end
        end
    end)

    local boostFPS, skinReplace, potatoEnabled, removeEnabled, fullbright, effectsEnabled = false, false, false, false, false, false
    local RemoveTool, oldLighting = nil, {}

    createToggle(BoostMenu, "Boostfps", 0, false, function(st)
        boostFPS = st
        if st then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
                if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0 end
            end
        end
    end)
    createToggle(BoostMenu, "Skin Replacement", 44, false, function(st)
        skinReplace = st
        for _, plr in pairs(Services.Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("MeshPart") and st then v.MeshId = ""; v.Size = Vector3.new(1, 1, 1) end
                end
            end
        end
    end)
    createToggle(BoostMenu, "Potato Mode", 88, false, function(st)
        potatoEnabled = st
        if st then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
                if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic; obj.Reflectance = 0; obj.CastShadow = false end
                if obj:IsA("MeshPart") then obj.TextureID = ""; obj.Material = Enum.Material.Plastic end
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then obj.Enabled = false end
            end
        end
    end)
    createToggle(BoostMenu, "Removing Textures", 132, false, function(st)
        removeEnabled = st
        if st then
            RemoveTool = Instance.new("Tool"); RemoveTool.Name = "Texture Remover"; RemoveTool.RequiresHandle = false; RemoveTool.Parent = LP.Backpack
            table.insert(UI.Connections, RemoveTool.Activated:Connect(function()
                local t = LP:GetMouse().Target
                if t then
                    for _, v in pairs(t:GetDescendants()) do if v:IsA("Texture") or v:IsA("Decal") then v:Destroy() end end
                    if t:IsA("MeshPart") then t.TextureID = "" end
                end
            end))
        else
            if RemoveTool then RemoveTool:Destroy(); RemoveTool = nil end
        end
    end)
    createToggle(BoostMenu, "FullBright", 176, false, function(st)
        fullbright = st
        local L = Services.Lighting
        if st then
            oldLighting.Brightness = L.Brightness; oldLighting.ClockTime = L.ClockTime; oldLighting.GlobalShadows = L.GlobalShadows; oldLighting.FogEnd = L.FogEnd
            L.Brightness = 3; L.ClockTime = 14; L.GlobalShadows = false; L.FogEnd = 999999
        else
            L.Brightness = oldLighting.Brightness or 1; L.ClockTime = oldLighting.ClockTime or 14; L.GlobalShadows = oldLighting.GlobalShadows; L.FogEnd = oldLighting.FogEnd or 1000
        end
    end)
    createToggle(BoostMenu, "Remove Effects", 220, false, function(st)
        effectsEnabled = st
        for _, v in pairs(Services.Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                v.Enabled = not st
            end
        end
    end)

    local headless, korblox, skyboxEnabled, thirdPersonEnabled = false, false, false, false
    local oldSkybox = nil

    createToggle(MiscMenu, "Headless", 0, false, function(st)
        headless = st
        if LP.Character and LP.Character:FindFirstChild("Head") then
            LP.Character.Head.Transparency = st and 1 or 0
            for _, v in pairs(LP.Character.Head:GetChildren()) do if v:IsA("Decal") then v.Transparency = st and 1 or 0 end end
        end
    end)
    createToggle(MiscMenu, "Korblox", 44, false, function(st)
        korblox = st
        if LP.Character then
            local leg = LP.Character:FindFirstChild("Right Leg") or LP.Character:FindFirstChild("RightLowerLeg")
            if leg then leg.Transparency = st and 1 or 0 end
        end
    end)
    createToggle(MiscMenu, "Skybox Changer", 88, false, function(st)
        skyboxEnabled = st
        local L = Services.Lighting
        if st then
            oldSkybox = L:FindFirstChildOfClass("Sky")
            if oldSkybox then oldSkybox.Parent = nil end
            local newSky = Instance.new("Sky", L)
            newSky.Name = "CustomSky"
            newSky.SkyboxBk = "rbxassetid://600886090"; newSky.SkyboxDn = "rbxassetid://600886090"; newSky.SkyboxFt = "rbxassetid://600886090"
            newSky.SkyboxLf = "rbxassetid://600886090"; newSky.SkyboxRt = "rbxassetid://600886090"; newSky.SkyboxUp = "rbxassetid://600886090"
        else
            local currSky = L:FindFirstChild("CustomSky")
            if currSky then currSky:Destroy() end
            if oldSkybox then oldSkybox.Parent = L end
        end
    end)
    createToggle(MiscMenu, "Third Person Mode", 132, false, function(st)
        thirdPersonEnabled = st
        if st then
            LP.CameraMode = Enum.CameraMode.Classic; LP.CameraMaxZoomDistance = 12; LP.CameraMinZoomDistance = 12
        else
            LP.CameraMaxZoomDistance = 400; LP.CameraMinZoomDistance = 0.5
        end
    end)

    local RadarWin = Create("Frame", { Parent = UI.Screen, Size = UDim2.new(0, 140, 0, 140), Position = UDim2.new(1, -165, 0, 55), BackgroundColor3 = Colors.Background, Visible = false, BorderSizePixel = 0 })
    Create("UICorner", { Parent = RadarWin, CornerRadius = UDim.new(1, 0) })
    Create("UIStroke", { Parent = RadarWin, Color = Colors.Border, Thickness = 1 })
    
    local rCenter = Create("Frame", { Parent = RadarWin, Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(0.5, -2, 0.5, -2), BackgroundColor3 = Colors.TextMain, BorderSizePixel = 0 })
    Create("UICorner", { Parent = rCenter, CornerRadius = UDim.new(1, 0) })
    makeDraggable(RadarWin)

    local radarEnabled = false
    createToggle(MiscMenu, "Radar", 176, false, function(st)
        radarEnabled = st
        RadarWin.Visible = st
    end)

    local MusicWin = Create("Frame", {
        Parent = UI.Screen,
        Size = UDim2.new(0, 320, 0, 350),
        Position = UDim2.new(0.5, -160, 0.5, -175),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 15000
    })
    Create("UICorner", { Parent = MusicWin, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = MusicWin, Color = Colors.Border, Thickness = 1 })

    local musTopBar = Create("Frame", { Parent = MusicWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    makeDraggable(MusicWin, musTopBar)

    Create("TextLabel", {
        Parent = musTopBar,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "Music Player",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local musCloseBtn = Create("TextButton", {
        Parent = musTopBar,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Colors.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 18
    })

    local musScroll = Create("ScrollingFrame", {
        Parent = MusicWin,
        Size = UDim2.new(1, -24, 0, 230),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Border,
        BorderSizePixel = 0
    })
    local musLayout = Create("UIListLayout", { Parent = musScroll, Padding = UDim.new(0, 4) })
    musLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        musScroll.CanvasSize = UDim2.new(0, 0, 0, musLayout.AbsoluteContentSize.Y + 5)
    end)

    local customPanel = Create("Frame", {
        Parent = MusicWin,
        Size = UDim2.new(1, -24, 0, 50),
        Position = UDim2.new(0, 12, 0, 280),
        BackgroundColor3 = Colors.Surface,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = customPanel, CornerRadius = UDim.new(0, 6) })
    Create("UIStroke", { Parent = customPanel, Color = Colors.Border, Thickness = 1 })

    local customInput = Create("TextBox", {
        Parent = customPanel,
        Size = UDim2.new(1, -90, 1, -16),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Enter Sound ID...",
        Text = "",
        ClearTextOnFocus = false
    })
    Create("UICorner", { Parent = customInput, CornerRadius = UDim.new(0, 4) })
    Create("UIStroke", { Parent = customInput, Color = Colors.Border, Thickness = 1 })

    local customPlayBtn = Create("TextButton", {
        Parent = customPanel,
        Size = UDim2.new(0, 70, 1, -16),
        Position = UDim2.new(1, -80, 0, 8),
        BackgroundColor3 = Colors.Active,
        Text = "Вкл",
        TextColor3 = Colors.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = customPlayBtn, CornerRadius = UDim.new(0, 4) })

    local currentSound = nil
    local currentPlayingId = nil
    local customPlaying = false
    local buttonsList = {}

    local function stopCurrentSound()
        if currentSound then
            currentSound:Stop()
            currentSound:Destroy()
            currentSound = nil
        end
    end

    local function playSound(id)
        stopCurrentSound()
        currentSound = Instance.new("Sound")
        currentSound.SoundId = "rbxassetid://" .. tostring(id)
        currentSound.Volume = 1
        currentSound.Looped = true
        currentSound.Parent = workspace
        currentSound:Play()
    end

    local function updateAllMusicButtons()
        for id, btn in pairs(buttonsList) do
            if currentPlayingId == id then
                btn.Text = "Выкл"
                btn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                btn.TextColor3 = Colors.TextMain
            else
                btn.Text = "Вкл"
                btn.BackgroundColor3 = Colors.Active
                btn.TextColor3 = Colors.Background
            end
        end
    end

    local function handlePlayClick(id)
        if currentPlayingId == id then
            stopCurrentSound()
            currentPlayingId = nil
            customPlaying = false
            customPlayBtn.Text = "Вкл"
            customPlayBtn.BackgroundColor3 = Colors.Active
            customPlayBtn.TextColor3 = Colors.Background
        else
            playSound(id)
            currentPlayingId = id
            customPlaying = false
            customPlayBtn.Text = "Вкл"
            customPlayBtn.BackgroundColor3 = Colors.Active
            customPlayBtn.TextColor3 = Colors.Background
        end
        updateAllMusicButtons()
    end

    customPlayBtn.MouseButton1Click:Connect(function()
        local id = customInput.Text
        if id ~= "" then
            if customPlaying and currentPlayingId == id then
                stopCurrentSound()
                currentPlayingId = nil
                customPlaying = false
                customPlayBtn.Text = "Вкл"
                customPlayBtn.BackgroundColor3 = Colors.Active
                customPlayBtn.TextColor3 = Colors.Background
                updateAllMusicButtons()
            else
                playSound(id)
                currentPlayingId = id
                customPlaying = true
                customPlayBtn.Text = "Выкл"
                customPlayBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
                customPlayBtn.TextColor3 = Colors.TextMain
                updateAllMusicButtons()
            end
        end
    end)

    musCloseBtn.MouseButton1Click:Connect(function()
        MusicWin.Visible = false
        if _G.ConfigUpdaters["Music Player"] then
            _G.ConfigUpdaters["Music Player"](false)
        end
    end)

    local songs = {
        {name = "Alan Walker - Fade", id = 1281861057},
        {name = "Alan Walker - Spectre", id = 280219665},
        {name = "Tobu - Candyland", id = 210134085},
        {name = "Tobu - Hope", id = 210135891},
        {name = "The Fat Rat - Unity", id = 186053155},
        {name = "The Fat Rat - Windfall", id = 191632766},
        {name = "Phonk - Metamorphosis", id = 11099313936},
        {name = "Phonk - Neon Blade", id = 10695027581},
        {name = "Kahoot Lobby Music", id = 1319760718},
        {name = "Epic Sax Guy", id = 130775431},
        {name = "Megumin Explosion", id = 412095311},
        {name = "Megalovania", id = 5410086219},
        {name = "Rick Roll", id = 1251912644},
        {name = "Careless Whisper", id = 1845182928},
        {name = "Stereo Madness", id = 219195392},
        {name = "Despacito", id = 1340114030},
        {name = "GigaChad Theme", id = 9114717144},
        {name = "Among Us Drip", id = 6124508453},
        {name = "Trio - Da Da Da", id = 153093282},
        {name = "Nyan Cat", id = 130790250},
        {name = "Darude - Sandstorm", id = 166589022},
        {name = "Guns N' Roses - Sweet Child", id = 292612543},
        {name = "We Like to Party Vengaboys", id = 151044434},
        {name = "Spooky Scary Skeletons", id = 160351296},
        {name = "Gummy Bear Song", id = 143896590},
        {name = "Macarena", id = 156942023},
        {name = "Soviet Anthem", id = 130838153},
        {name = "He-Man HEYYEYAAEYAAA", id = 142106725},
        {name = "Caramelldansen", id = 254823122},
        {name = "Running in the 90s", id = 130887303},
        {name = "Gas Gas Gas", id = 611680108},
        {name = "Deja Vu (Initial D)", id = 1358941651},
        {name = "Minecraft Calm 1", id = 142071948},
        {name = "Super Mario Theme", id = 1282141972},
        {name = "Tetris Theme", id = 148115695},
        {name = "Pac-Man Theme", id = 156828551},
        {name = "Mortal Kombat", id = 142410214},
        {name = "Pirates of the Caribbean", id = 155891398},
        {name = "Pokemon Theme", id = 131013445},
        {name = "Goku Ultra Instinct", id = 1432126294},
        {name = "Chipi Chipi Chapa Chapa", id = 15620958183},
        {name = "Baka Mitai (Dame Da Ne)", id = 5334817415},
        {name = "Sad Violin", id = 135328812},
        {name = "Coffin Dance", id = 4900778643},
        {name = "Monkeys Spinning Monkeys", id = 9114264627},
        {name = "Sneaky Snitch", id = 9119102434},
        {name = "Deadwood - Really Slow Motion", id = 286596328},
        {name = "Bad To The Bone Riff", id = 9115796248},
        {name = "Club Step (GD)", id = 151525997},
        {name = "Stay Inside Me (GD Practice)", id = 145557762}
    }

    for _, song in ipairs(songs) do
        local item = Create("Frame", {
            Parent = musScroll,
            Size = UDim2.new(1, -4, 0, 30),
            BackgroundColor3 = Colors.Surface,
            BorderSizePixel = 0
        })
        Create("UICorner", { Parent = item, CornerRadius = UDim.new(0, 4) })
        local itemStroke = Create("UIStroke", { Parent = item, Color = Colors.Border, Thickness = 1 })

        local title = Create("TextLabel", {
            Parent = item,
            Size = UDim2.new(1, -75, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = song.name,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClipsDescendants = true
        })

        local playBtn = Create("TextButton", {
            Parent = item,
            Size = UDim2.new(0, 55, 0, 22),
            Position = UDim2.new(1, -65, 0.5, -11),
            BackgroundColor3 = Colors.Active,
            Text = "Вкл",
            TextColor3 = Colors.Background,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0
        })
        Create("UICorner", { Parent = playBtn, CornerRadius = UDim.new(0, 4) })

        buttonsList[tostring(song.id)] = playBtn

        playBtn.MouseButton1Click:Connect(function()
            handlePlayClick(tostring(song.id))
        end)
    end

    createToggle(MiscMenu, "Music Player", 220, false, function(st)
        MusicWin.Visible = st
        if not st then
            stopCurrentSound()
            currentPlayingId = nil
            customPlaying = false
            customPlayBtn.Text = "Вкл"
            customPlayBtn.BackgroundColor3 = Colors.Active
            customPlayBtn.TextColor3 = Colors.Background
            updateAllMusicButtons()
        end
    end)

    local radarDots = {}
    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if not radarEnabled then return end
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP then
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local dot = radarDots[plr]
                    if not dot then
                        dot = Create("Frame", { Parent = RadarWin, Size = UDim2.new(0, 4, 0, 4), BackgroundColor3 = Color3.fromRGB(255, 80, 80), BorderSizePixel = 0 })
                        Create("UICorner", { Parent = dot, CornerRadius = UDim.new(1, 0) })
                        radarDots[plr] = dot
                    end
                    local offset = myHrp.CFrame:ToObjectSpace(char.HumanoidRootPart.CFrame).Position
                    local distance = offset.Magnitude
                    local maxDist = 200
                    if distance <= maxDist then
                        local x = (offset.X / maxDist) * 70
                        local z = (offset.Z / maxDist) * 70
                        dot.Position = UDim2.new(0.5, x - 2, 0.5, z - 2)
                        dot.Visible = true
                    else
                        dot.Visible = false
                    end
                else
                    if radarDots[plr] then radarDots[plr].Visible = false end
                end
            end
        end
    end))

    task.spawn(function()
        while task.wait(0.5) do
            for _, plr in pairs(Services.Players:GetPlayers()) do
                if plr ~= LP then
                    if itemESP then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if (obj:IsA("Tool") or obj.Name:lower():find("gun") or obj.Name:lower():find("key")) and not obj:FindFirstChild("ItemESP") then
                                local part = obj:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local bb = Create("BillboardGui", { Parent = obj, Name = "ItemESP", Size = UDim2.new(0, 100, 0, 30), AlwaysOnTop = true, Adornee = part })
                                    local txt = Create("TextLabel", { Parent = bb, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = obj.Name, TextScaled = true, TextColor3 = Colors.Active, Font = Enum.Font.GothamBold })
                                end
                            end
                        end
                    end
                    local char = plr.Character
                    if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
                        if nameESP then
                            local gui = char.Head:FindFirstChild("ESP") or Create("BillboardGui", { Parent = char.Head, Name = "ESP", Size = UDim2.new(0, 100, 0, 40), AlwaysOnTop = true, StudsOffset = Vector3.new(0, 2, 0), Adornee = char.Head })
                            local txt = gui:FindFirstChild("TXT") or Create("TextLabel", { Parent = gui, Name = "TXT", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Colors.Active, TextStrokeTransparency = 0, Font = Enum.Font.GothamBold, TextScaled = true })
                            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                                txt.Text = plr.Name .. "\n" .. math.floor((LP.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude) .. "m"
                            end
                        else
                            if char.Head:FindFirstChild("ESP") then char.Head.ESP:Destroy() end
                        end
                        if outlineESP then
                            if not char:FindFirstChild("ESPHighlight") then
                                local hl = Create("Highlight", { Parent = char, Name = "ESPHighlight", FillColor = Colors.Active, FillTransparency = 0.7, OutlineColor = Colors.Active, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop })
                            end
                        else
                            if char:FindFirstChild("ESPHighlight") then char.ESPHighlight:Destroy() end
                        end
                    end
                end
            end
        end
    end)

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP then
                if not _G.pDrawings[plr] then
                    _G.pDrawings[plr] = { box = Drawing.new("Square"), tracer = Drawing.new("Line") }
                    _G.pDrawings[plr].box.Color = Colors.Active; _G.pDrawings[plr].box.Thickness = 1.5; _G.pDrawings[plr].box.Filled = false
                    _G.pDrawings[plr].tracer.Color = Colors.Active; _G.pDrawings[plr].tracer.Thickness = 1.5
                end
                local d = _G.pDrawings[plr]
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local hrp = char.HumanoidRootPart
                    local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if vis then
                        if boxESP then
                            local head = char:FindFirstChild("Head")
                            if head then
                                local headPos = workspace.CurrentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local legPos = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                                local height = math.abs(headPos.Y - legPos.Y)
                                local width = height / 2
                                d.box.Size = Vector2.new(width, height)
                                d.box.Position = Vector2.new(pos.X - width / 2, headPos.Y)
                                d.box.Visible = true
                            else d.box.Visible = false end
                        else d.box.Visible = false end

                        if tracersESP then
                            d.tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                            d.tracer.To = Vector2.new(pos.X, pos.Y)
                            d.tracer.Visible = true
                        else d.tracer.Visible = false end
                    else
                        d.box.Visible = false; d.tracer.Visible = false
                    end
                else
                    d.box.Visible = false; d.tracer.Visible = false
                end
            end
        end
    end))
end

do
    local origLighting = {
        Ambient = Services.Lighting.Ambient,
        OutdoorAmbient = Services.Lighting.OutdoorAmbient,
        ClockTime = Services.Lighting.ClockTime,
        FogEnd = Services.Lighting.FogEnd,
        FogStart = Services.Lighting.FogStart,
        FogColor = Services.Lighting.FogColor
    }

    local retroEnabled = false
    local ccEffect = Instance.new("ColorCorrectionEffect")
    ccEffect.Name = "RetroCC"; ccEffect.Brightness = 0.1; ccEffect.Contrast = 0.5; ccEffect.Saturation = -0.4; ccEffect.TintColor = Color3.fromRGB(255, 230, 200)

    createToggle(ShadersTab, "Retro Game", 10, false, function(st)
        retroEnabled = st
        ccEffect.Parent = st and Services.Lighting or nil
    end)

    local rtxEnabled = false
    local rCC = Instance.new("ColorCorrectionEffect")
    rCC.Name = "RTX_CC"; rCC.Contrast = 0.3; rCC.Saturation = 0.6; rCC.Brightness = 0.1; rCC.TintColor = Color3.fromRGB(255, 255, 255)
    local rBloom = Instance.new("BloomEffect")
    rBloom.Name = "RTX_Bloom"; rBloom.Intensity = 0.8; rBloom.Size = 24
    local rDof = Instance.new("DepthOfFieldEffect")
    rDof.Name = "RTX_DoF"; rDof.FocusDistance = 10; rDof.InFocusRadius = 20; rDof.NearIntensity = 0.1; rDof.FarIntensity = 0.5
    local rSun = Instance.new("SunRaysEffect")
    rSun.Name = "RTX_Sun"; rSun.Intensity = 0.1

    createToggle(ShadersTab, "RTX / Vibrant", 55, false, function(st)
        rtxEnabled = st
        rCC.Parent = st and Services.Lighting or nil
        rBloom.Parent = st and Services.Lighting or nil
        rDof.Parent = st and Services.Lighting or nil
        rSun.Parent = st and Services.Lighting or nil
    end)

    local cyberEnabled = false
    local CyberFolder = Instance.new("Folder")
    CyberFolder.Name = "CyberShaders"
    local cCC = Instance.new("ColorCorrectionEffect", CyberFolder); cCC.Contrast = 0.4; cCC.Saturation = 0.8; cCC.TintColor = Color3.fromRGB(255, 200, 255)
    Instance.new("BloomEffect", CyberFolder).Intensity = 1.2
    local cyberConn = nil

    createToggle(ShadersTab, "Cyberpunk Neon", 100, false, function(st)
        cyberEnabled = st
        CyberFolder.Parent = st and Services.Lighting or nil
        if st then
            cyberConn = Services.Run.RenderStepped:Connect(function() Services.Lighting.ClockTime = 0 end)
        else
            if cyberConn then cyberConn:Disconnect(); cyberConn = nil end
            Services.Lighting.ClockTime = origLighting.ClockTime
        end
    end)

    local silentEnabled = false
    local SilentFolder = Instance.new("Folder")
    SilentFolder.Name = "SilentShaders"
    local sCC = Instance.new("ColorCorrectionEffect", SilentFolder); sCC.Contrast = 0.1; sCC.Saturation = -0.8; sCC.TintColor = Color3.fromRGB(200, 200, 200)
    Instance.new("BlurEffect", SilentFolder).Size = 4

    createToggle(ShadersTab, "Silent Hill", 145, false, function(st)
        silentEnabled = st
        SilentFolder.Parent = st and Services.Lighting or nil
        local L = Services.Lighting
        if st then
            L.FogColor = Color3.fromRGB(150, 150, 150); L.FogEnd = 150; L.FogStart = 0; L.ClockTime = 18
        else
            L.FogColor = origLighting.FogColor; L.FogEnd = origLighting.FogEnd; L.FogStart = origLighting.FogStart; L.ClockTime = origLighting.ClockTime
        end
    end)

    local friedEnabled = false
    local fCC = Instance.new("ColorCorrectionEffect")
    fCC.Name = "Fried_CC"; fCC.Brightness = 0.2; fCC.Contrast = 2.0; fCC.Saturation = 2.0; fCC.TintColor = Color3.fromRGB(255, 150, 50)

    createToggle(ShadersTab, "Deep Fried", 190, false, function(st)
        friedEnabled = st
        fCC.Parent = st and Services.Lighting or nil
    end)

    local nvEnabled = false
    local NVFolder = Instance.new("Folder")
    NVFolder.Name = "NightVisionShaders"
    local nvCC = Instance.new("ColorCorrectionEffect", NVFolder); nvCC.Brightness = 0.3; nvCC.Contrast = 0.5; nvCC.Saturation = -0.5; nvCC.TintColor = Color3.fromRGB(50, 255, 50)
    Instance.new("BloomEffect", NVFolder).Intensity = 0.5

    createToggle(ShadersTab, "Night Vision", 235, false, function(st)
        nvEnabled = st
        NVFolder.Parent = st and Services.Lighting or nil
        local L = Services.Lighting
        if st then
            L.Ambient = Color3.fromRGB(50, 255, 50); L.OutdoorAmbient = Color3.fromRGB(50, 255, 50)
        else
            L.Ambient = origLighting.Ambient; L.OutdoorAmbient = origLighting.OutdoorAmbient
        end
    end)
end

do
    local antiFling, antiSit, antiVoid, antiStun, antiRagdoll = false, false, false, false, false
    createToggle(ProtectTab, "Anti Fling", 10, false, function(st) antiFling = st end)
    createToggle(ProtectTab, "Anti Sit", 55, false, function(st) antiSit = st end)
    createToggle(ProtectTab, "Anti void", 100, false, function(st) antiVoid = st end)
    createToggle(ProtectTab, "Anti Stun", 145, false, function(st) antiStun = st end)
    createToggle(ProtectTab, "Anti Ragdoll", 190, false, function(st) antiRagdoll = st end)

    table.insert(UI.Connections, Services.Run.Stepped:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChild("Humanoid") then
            local hrp = LP.Character.HumanoidRootPart
            local hum = LP.Character.Humanoid
            if antiFling then
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        for _, p in ipairs(plr.Character:GetDescendants()) do
                            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                        end
                    end
                end
            end
            if antiSit and hum.Sit then
                hum.Sit = false; hum.Jump = true
            end
            if antiVoid and hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 50) then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 250, 0)
            end
            if antiStun then
                if hum.PlatformStand then hum.PlatformStand = false end
                hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
            end
            if antiRagdoll then
                local state = hum:GetState()
                if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
    end))
end

do
    local DiffBtn, DiffArrow = createMenuBtn(MiscTab, "Different", 10, true)
    local DiffMenu = Create("Frame", {
        Parent = MiscTab,
        Size = UDim2.new(1, -6, 0, 0),
        Position = UDim2.new(0, 3, 0, 50),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false
    })
    local diffLayout = Create("UIListLayout", { Parent = DiffMenu, Padding = UDim.new(0, 4) })

    local OtherBtn, OtherArrow = createMenuBtn(MiscTab, "Other", 55, true)
    local OtherMenu = Create("Frame", {
        Parent = MiscTab,
        Size = UDim2.new(1, -6, 0, 0),
        Position = UDim2.new(0, 3, 0, 95),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = false
    })
    local otherLayout = Create("UIListLayout", { Parent = OtherMenu, Padding = UDim.new(0, 4) })

    local diffOpened, otherOpened = false, false
    local function updateMiscPositions()
        local diffHeight = diffOpened and 264 or 0
        Services.TS:Create(OtherBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 55 + diffHeight)}):Play()
        Services.TS:Create(OtherMenu, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 95 + diffHeight)}):Play()
    end

    DiffBtn.MouseButton1Click:Connect(function()
        diffOpened = not diffOpened
        DiffMenu.Visible = true
        Services.TS:Create(DiffArrow, TWEEN_INFO_FAST, {Rotation = diffOpened and 180 or 0}):Play()
        local t = Services.TS:Create(DiffMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, diffOpened and 264 or 0)})
        t:Play(); t.Completed:Wait(); updateMiscPositions()
    end)

    OtherBtn.MouseButton1Click:Connect(function()
        otherOpened = not otherOpened
        OtherMenu.Visible = true
        Services.TS:Create(OtherArrow, TWEEN_INFO_FAST, {Rotation = otherOpened and 180 or 0}):Play()
        local t = Services.TS:Create(OtherMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, otherOpened and 88 or 0)})
        t:Play(); t.Completed:Wait(); updateMiscPositions()
    end)

    local antiAfkEnabled = false
    createToggle(DiffMenu, "Anti-AFK", 0, false, function(st) antiAfkEnabled = st end)
    table.insert(UI.Connections, LP.Idled:Connect(function()
        if antiAfkEnabled then
            Services.VU:CaptureController()
            Services.VU:ClickButton2(Vector2.new())
        end
    end))

    local noclipEnabled = false
    createToggle(DiffMenu, "Noclip", 44, false, function(st) noclipEnabled = st end)
    table.insert(UI.Connections, Services.Run.Stepped:Connect(function()
        if noclipEnabled and LP.Character then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end))

    local autoReconEnabled = false
    createToggle(DiffMenu, "Auto Reconnect", 88, false, function(st) autoReconEnabled = st end)
    table.insert(UI.Connections, game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if autoReconEnabled then
            task.wait(0.5)
            Services.TP:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end
    end))

    local freeCamEnabled = false
    local cam = workspace.CurrentCamera
    local fcSpeed = 2
    local fcKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

    createToggle(DiffMenu, "Free camera", 132, false, function(st)
        freeCamEnabled = st
        if st then
            cam.CameraType = Enum.CameraType.Scriptable
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = true
            end
        else
            cam.CameraType = Enum.CameraType.Custom
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = false
            end
        end
    end)

    table.insert(UI.Connections, Services.UIS.InputBegan:Connect(function(i, g)
        if not g then
            if i.KeyCode == Enum.KeyCode.W then fcKeys.W = true
            elseif i.KeyCode == Enum.KeyCode.A then fcKeys.A = true
            elseif i.KeyCode == Enum.KeyCode.S then fcKeys.S = true
            elseif i.KeyCode == Enum.KeyCode.D then fcKeys.D = true
            elseif i.KeyCode == Enum.KeyCode.Space then fcKeys.Space = true
            elseif i.KeyCode == Enum.KeyCode.LeftShift then fcKeys.LeftShift = true
            end
        end
    end))

    table.insert(UI.Connections, Services.UIS.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W then fcKeys.W = false
        elseif i.KeyCode == Enum.KeyCode.A then fcKeys.A = false
        elseif i.KeyCode == Enum.KeyCode.S then fcKeys.S = false
        elseif i.KeyCode == Enum.KeyCode.D then fcKeys.D = false
        elseif i.KeyCode == Enum.KeyCode.Space then fcKeys.Space = false
        elseif i.KeyCode == Enum.KeyCode.LeftShift then fcKeys.LeftShift = false
        end
    end))

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if freeCamEnabled then
            local v = Vector3.new()
            if fcKeys.W then v = v + Vector3.new(0, 0, -1) end
            if fcKeys.S then v = v + Vector3.new(0, 0, 1) end
            if fcKeys.A then v = v + Vector3.new(-1, 0, 0) end
            if fcKeys.D then v = v + Vector3.new(1, 0, 0) end
            if fcKeys.Space then v = v + Vector3.new(0, 1, 0) end
            if fcKeys.LeftShift then v = v + Vector3.new(0, -1, 0) end
            cam.CFrame = cam.CFrame * CFrame.new(v * fcSpeed)
        end
    end))

    local invisEnabled = false
    local originalPart0 = nil
    local originalPart1 = nil
    local rootJoint = nil

    createToggle(DiffMenu, "Invisibility", 176, false, function(st)
        invisEnabled = st
        local char = LP.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            showNotification("HumanoidRootPart не найден!")
            return 
        end
        
        rootJoint = hrp:FindFirstChild("RootJoint") or char:FindFirstChild("RootJoint", true)
        if not rootJoint then
            showNotification("RootJoint не найден!")
            return
        end

        if st then
            originalPart0 = rootJoint.Part0
            originalPart1 = rootJoint.Part1
            rootJoint.Part0 = nil
            
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 0.5
                elseif v:IsA("Decal") then
                    v.Transparency = 0.5
                end
            end
            showNotification("FE Invisibility включен! Ваш торс остался на месте для других.")
        else
            if rootJoint and originalPart0 then
                rootJoint.Part0 = originalPart0
                if originalPart1 then rootJoint.Part1 = originalPart1 end
            end

            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 0
                end
            end
            rootJoint = nil
            originalPart0 = nil
            originalPart1 = nil
            showNotification("FE Invisibility выключен.")
        end
    end)

    local cinematicEnabled = false
    local cinemCam = workspace.CurrentCamera
    local PlayerModule = require(LP.PlayerScripts:WaitForChild("PlayerModule"))
    local ControlsClass = PlayerModule:GetControls()
    local cinemPart = nil
    local oldMinZoom, oldMaxZoom = 0.5, 400

    createToggle(DiffMenu, "Cinematic Mode", 220, false, function(st)
        cinematicEnabled = st
        pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, not st) end)
        for _, gui in pairs(LP.PlayerGui:GetChildren()) do
            if gui ~= UI.Screen and gui:IsA("ScreenGui") then
                gui.Enabled = not st
            end
        end

        if st then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = true
            end
            oldMinZoom = LP.CameraMinZoomDistance
            oldMaxZoom = LP.CameraMaxZoomDistance

            cinemPart = Instance.new("Part")
            cinemPart.Name = "CinemPart"
            cinemPart.Transparency = 1
            cinemPart.Anchored = true
            cinemPart.CanCollide = false
            cinemPart.CFrame = cinemCam.CFrame
            cinemPart.Parent = workspace

            cinemCam.CameraSubject = cinemPart
            LP.CameraMinZoomDistance = 0.5
            LP.CameraMaxZoomDistance = 0.5
        else
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = false
                if LP.Character:FindFirstChild("Humanoid") then
                    cinemCam.CameraSubject = LP.Character.Humanoid
                end
            end
            if cinemPart then cinemPart:Destroy() end
            LP.CameraMinZoomDistance = oldMinZoom
            LP.CameraMaxZoomDistance = oldMaxZoom
        end
    end)

    table.insert(UI.Connections, Services.Run.RenderStepped:Connect(function()
        if cinematicEnabled and cinemPart then
            local moveVector = ControlsClass:GetMoveVector()
            local lookVector = cinemCam.CFrame.LookVector
            local rightVector = cinemCam.CFrame.RightVector
            local moveDir = (lookVector * moveVector.Z * -1) + (rightVector * moveVector.X)
            cinemPart.CFrame = cinemPart.CFrame + (moveDir * 1.5)
        end
    end))

    local ConsoleWin = Create("Frame", { Parent = UI.Screen, Size = UDim2.new(0, 440, 0, 240), Position = UDim2.new(0.5, -220, 0.5, -120), BackgroundColor3 = Colors.Background, BorderSizePixel = 0, Visible = false, ClipsDescendants = true })
    Create("UICorner", { Parent = ConsoleWin, CornerRadius = UDim.new(0, 8) })
    Create("UIStroke", { Parent = ConsoleWin, Color = Colors.Border, Thickness = 1 })
    local conTopBar = Create("Frame", { Parent = ConsoleWin, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    makeDraggable(ConsoleWin, conTopBar)
    Create("TextLabel", { Parent = conTopBar, Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Developer Console", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local conCloseBtn = Create("TextButton", { Parent = conTopBar, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundTransparency = 1, Text = "×", TextColor3 = Colors.TextDim, Font = Enum.Font.GothamMedium, TextSize = 18 })

    local conScroll = Create("ScrollingFrame", { Parent = ConsoleWin, Size = UDim2.new(1, -24, 1, -48), Position = UDim2.new(0, 12, 0, 38), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.Border, BorderSizePixel = 0 })
    local conLayout = Create("UIListLayout", { Parent = conScroll, Padding = UDim.new(0, 2) })
    conLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() conScroll.CanvasSize = UDim2.new(0, 0, 0, conLayout.AbsoluteContentSize.Y + 10) end)

    local function addConsoleLine(msg, msgType)
        local lbl = Create("TextLabel", { Parent = conScroll, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = msg, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 11 })
        if msgType == Enum.MessageType.MessageError then lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif msgType == Enum.MessageType.MessageWarning then lbl.TextColor3 = Color3.fromRGB(255, 200, 80)
        elseif msgType == Enum.MessageType.MessageInfo then lbl.TextColor3 = Color3.fromRGB(150, 200, 255)
        else lbl.TextColor3 = Colors.TextMain end
        task.wait()
        conScroll.CanvasPosition = Vector2.new(0, conScroll.CanvasSize.Y.Offset)
    end
    table.insert(UI.Connections, Services.Log.MessageOut:Connect(addConsoleLine))
    for _, log in ipairs(Services.Log:GetLogHistory()) do addConsoleLine(log.message, log.messageType) end

    local consoleTog, _, setConsoleState = createToggle(OtherMenu, "Developer Console", 0, false, function(st) ConsoleWin.Visible = st end)
    conCloseBtn.MouseButton1Click:Connect(function() setConsoleState(false, true); ConsoleWin.Visible = false end)

local spyEnabled = false
    local spyTog, _, setSpyState = createToggle(OtherMenu, "Remote Spy", 44, false, function(st)
        spyEnabled = st
        if st then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/CherryCalCor/BWSPY.Lua/refs/heads/main/Code"))()
        end
    end)

end

do
    local stalkMenuEnabled = false
    local StalkWin, StalkClose, StalkScroll, StalkLayout, StalkActionBtn, StalkActionLbl = createFloatingMenu("Stalk")
    local currentStalkTarget = nil
    local stalking = false
    local stalkTarget = nil
    local stalkConnection = nil

    local function StartStalk(targetPlayer)
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local myChar = LP.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        stalking = true; stalkTarget = targetPlayer
        myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)

        if stalkConnection then stalkConnection:Disconnect() end
        stalkConnection = Services.Run.RenderStepped:Connect(function()
            if not stalking or not stalkTarget then return end
            local targetChar = stalkTarget.Character
            local myCharacter = LP.Character
            if targetChar and myCharacter and targetChar:FindFirstChild("HumanoidRootPart") and myCharacter:FindFirstChild("HumanoidRootPart") then
                myCharacter.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                if targetChar:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = targetChar.Humanoid end
            end
        end)
        table.insert(UI.Connections, stalkConnection)
    end

    local function StopStalk()
        stalking = false; stalkTarget = nil
        if stalkConnection then stalkConnection:Disconnect(); stalkConnection = nil end
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = LP.Character.Humanoid end
    end

    createToggle(FunnyTab, "Stalk Mode", 10, false, function(st)
        stalkMenuEnabled = st
        StalkWin.Visible = st
        if st then
            populatePlayers(StalkScroll, StalkLayout, StalkActionLbl, "Stalk", function(p) currentStalkTarget = p end)
        else
            StopStalk(); StalkActionLbl.Text = "Stalk: [None]"
        end
    end)
    StalkClose.MouseButton1Click:Connect(function() StalkWin.Visible = false; StopStalk(); StalkActionLbl.Text = "Stalk: [None]" end)
    StalkActionBtn.MouseButton1Click:Connect(function()
        if not currentStalkTarget then return end
        if stalking and stalkTarget == currentStalkTarget then StopStalk(); showNotification("Преследование остановлено")
        else StartStalk(currentStalkTarget); showNotification("Преследование: " .. currentStalkTarget.Name) end
    end)

    local FakeLagBtn, FakeLagArrow = createMenuBtn(FunnyTab, "Fake lag", 55, true)
    local FakeLagMenu = Create("Frame", { Parent = FunnyTab, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 95), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    Create("UIListLayout", { Parent = FakeLagMenu, Padding = UDim.new(0, 4) })

    local fakeLagOpened = false
    FakeLagBtn.MouseButton1Click:Connect(function()
        fakeLagOpened = not fakeLagOpened
        FakeLagMenu.Visible = true
        Services.TS:Create(FakeLagArrow, TWEEN_INFO_FAST, {Rotation = fakeLagOpened and 180 or 0}):Play()
        Services.TS:Create(FakeLagMenu, TWEEN_INFO_FAST, {Size = fakeLagOpened and UDim2.new(1, -6, 0, 90) or UDim2.new(1, -6, 0, 0)}):Play()
    end)

    local suspEnabled = false
    createToggle(FakeLagMenu, "Complete suspension", 0, false, function(st)
        suspEnabled = st
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Anchored = st end
    end)

    local usualEnabled = false
    createToggle(FakeLagMenu, "The usual lag", 44, false, function(st)
        usualEnabled = st
        if not st and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Anchored = false end
    end)

    task.spawn(function()
        while UI.Screen and UI.Screen.Parent do
            task.wait(math.random(1, 3))
            if usualEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.Anchored = true
                task.wait(math.random(1, 3) * 0.5)
                if usualEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Anchored = false end
            end
        end
    end)
end

do
    local ConfigsMenu = Create("Frame", { Parent = ConfigTab, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local cfgLayout = Create("UIListLayout", { Parent = ConfigsMenu, Padding = UDim.new(0, 4) })

    local nameCard = CreateStyledCard(ConfigTab, 40)
    nameCard.Position = UDim2.new(0, 0, 0, 55)
    local ConfigNameInput = Create("TextBox", {
        Parent = nameCard,
        Size = UDim2.new(1, -24, 1, -12),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        PlaceholderText = "Enter config name...",
        Font = Enum.Font.Gotham,
        Text = ""
    })
    Create("UICorner", { Parent = ConfigNameInput, CornerRadius = UDim.new(0, 4) })
    local cInStroke = Create("UIStroke", { Parent = ConfigNameInput, Color = Colors.Border, Thickness = 1 })

    local SaveConfigBtn = Create("TextButton", {
        Parent = ConfigTab,
        Size = UDim2.new(1, -6, 0, 32),
        Position = UDim2.new(0, 3, 0, 105),
        BackgroundColor3 = Colors.Surface,
        Text = "Save Config",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = SaveConfigBtn, CornerRadius = UDim.new(0, 6) })
    local saveStroke = Create("UIStroke", { Parent = SaveConfigBtn, Color = Colors.Border, Thickness = 1 })

    SaveConfigBtn.MouseEnter:Connect(function() Services.TS:Create(saveStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
    SaveConfigBtn.MouseLeave:Connect(function() Services.TS:Create(saveStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

    local AutoUploadToggleCont = Create("Frame", { Parent = ConfigTab, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 145), BackgroundTransparency = 1 })

    local cfgOpened = false
    local function updateConfigPos()
        local h = cfgOpened and 120 or 0
        Services.TS:Create(nameCard, TWEEN_INFO_FAST, {Position = UDim2.new(0, 0, 0, 55 + h)}):Play()
        Services.TS:Create(SaveConfigBtn, TWEEN_INFO_FAST, {Position = UDim2.new(0, 3, 0, 105 + h)}):Play()
        Services.TS:Create(AutoUploadToggleCont, TWEEN_INFO_FAST, {Position = UDim2.new(0, 0, 0, 145 + h)}):Play()
    end

    local folderName = "SeptusHub_Configs"
    local autoLoadFile = folderName .. "/autoload.txt"
    local selectedConfigToLoad = nil

    pcall(function() if makefolder and not isfolder(folderName) then makefolder(folderName) end end)

    local function refreshConfigs()
        for _, v in pairs(ConfigsMenu:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        pcall(function()
            if listfiles then
                local files = listfiles(folderName)
                for _, file in ipairs(files) do
                    if file:match("%.json$") then
                        local confName = file:match("([^/\\]+)%.json$") or "Unknown"
                        local btn = Create("TextButton", {
                            Parent = ConfigsMenu,
                            Size = UDim2.new(1, -4, 0, 26),
                            BackgroundColor3 = Colors.Surface,
                            Text = confName,
                            TextColor3 = Colors.TextDim,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 12,
                            BorderSizePixel = 0
                        })
                        Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
                        local bStroke = Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })

                        btn.MouseButton1Click:Connect(function()
                            selectedConfigToLoad = confName
                            showNotification("Загружен конфиг: " .. confName)
                            local rawData = readfile(file)
                            local decoded = Services.Http:JSONDecode(rawData)
                            if decoded.ThemeC1 and decoded.ThemeC2 then
                                _G.changeTheme(Color3.fromHex(decoded.ThemeC1), Color3.fromHex(decoded.ThemeC2))
                            end
                            if decoded.Settings then
                                for k, v in pairs(decoded.Settings) do
                                    if _G.ConfigUpdaters[k] then _G.ConfigUpdaters[k](v) end
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end

    local ConfigsBtn, ConfigsArrow = createMenuBtn(ConfigTab, "Configs (Select to load)", 10, true)
    ConfigsBtn.MouseButton1Click:Connect(function()
        cfgOpened = not cfgOpened
        ConfigsMenu.Visible = true
        Services.TS:Create(ConfigsArrow, TWEEN_INFO_FAST, {Rotation = cfgOpened and 180 or 0}):Play()
        local t = Services.TS:Create(ConfigsMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, cfgOpened and 110 or 0)})
        t:Play(); t.Completed:Wait(); updateConfigPos(); refreshConfigs()
    end)

    SaveConfigBtn.MouseButton1Click:Connect(function()
        local txt = ConfigNameInput.Text
        if txt == "" then txt = "DefaultConfig" end
        pcall(function()
            if writefile then
                local dataToSave = {
                    ThemeC1 = _G.CurrentGradientColors[1]:ToHex(),
                    ThemeC2 = _G.CurrentGradientColors[2]:ToHex(),
                    Settings = _G.ConfigState
                }
                writefile(folderName .. "/" .. txt .. ".json", Services.Http:JSONEncode(dataToSave))
                showNotification("Конфиг '" .. txt .. "' успешно сохранен!")
                refreshConfigs()
            else showNotification("Ваш инжектор не поддерживает файлы!") end
        end)
    end)

    local isAutoUpload = false
    pcall(function()
        if isfile and isfile(autoLoadFile) then
            local autoCfg = readfile(autoLoadFile)
            if autoCfg and autoCfg ~= "" then
                isAutoUpload = true; selectedConfigToLoad = autoCfg
                task.spawn(function()
                    task.wait(2)
                    showNotification("Авто-загрузка конфига: " .. autoCfg)
                    local cpath = folderName .. "/" .. autoCfg .. ".json"
                    if isfile(cpath) then
                        local decoded = Services.Http:JSONDecode(readfile(cpath))
                        if decoded.ThemeC1 and decoded.ThemeC2 then _G.changeTheme(Color3.fromHex(decoded.ThemeC1), Color3.fromHex(decoded.ThemeC2)) end
                        if decoded.Settings then
                            for k, v in pairs(decoded.Settings) do if _G.ConfigUpdaters[k] then _G.ConfigUpdaters[k](v) end end
                        end
                    end
                end)
            end
        end
    end)

    createToggle(AutoUploadToggleCont, "Auto upload", 0, isAutoUpload, function(st)
        isAutoUpload = st
        pcall(function()
            if isAutoUpload and selectedConfigToLoad then
                if writefile then writefile(autoLoadFile, selectedConfigToLoad) end
                showNotification("Auto upload установлен на: " .. selectedConfigToLoad)
            else
                if writefile then writefile(autoLoadFile, "") end
                if isfile and isfile(autoLoadFile) and delfile then delfile(autoLoadFile) end
                showNotification("Auto upload отключен.")
            end
        end)
    end)
end

do
    local bindHeader = CreateStyledCard(QoLTab, 90)
    Create("UIPadding", { Parent = bindHeader, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    Create("TextLabel", {
        Parent = bindHeader,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Custom Keybinds",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local bindKeyInput = Create("TextBox", {
        Parent = bindHeader,
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Key"
    })
    Create("UICorner", { Parent = bindKeyInput, CornerRadius = UDim.new(0, 4) })

    local bindFuncInput = Create("TextBox", {
        Parent = bindHeader,
        Size = UDim2.new(1, -125, 0, 26),
        Position = UDim2.new(0, 56, 0, 28),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Function Name"
    })
    Create("UICorner", { Parent = bindFuncInput, CornerRadius = UDim.new(0, 4) })

    local addBind = Create("TextButton", {
        Parent = bindHeader,
        Size = UDim2.new(0, 60, 0, 26),
        Position = UDim2.new(1, -60, 0, 28),
        BackgroundColor3 = Colors.Active,
        Text = "Add",
        TextColor3 = Colors.Background,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = addBind, CornerRadius = UDim.new(0, 4) })

    addBind.MouseButton1Click:Connect(function()
        local k = bindKeyInput.Text:upper()
        local f = bindFuncInput.Text
        if k ~= "" and f ~= "" then
            _G.UserBinds[k] = f
            showNotification("Байнд установлен: " .. k .. " -> " .. f)
            bindKeyInput.Text = ""; bindFuncInput.Text = ""
        end
    end)

    table.insert(UI.Connections, Services.UIS.InputBegan:Connect(function(input, processed)
        if processed then return end
        local keyName = input.KeyCode.Name
        if _G.UserBinds[keyName] then
            local fName = _G.UserBinds[keyName]
            local found = false
            for name, updater in pairs(_G.ConfigUpdaters) do
                if name:lower() == fName:lower() then
                    updater(not _G.ConfigState[name])
                    showNotification(name .. " toggled via Bind!")
                    found = true; break
                end
            end
            if not found then showNotification("Функция не найдена: " .. fName) end
        end
    end))

    local macroHeader = CreateStyledCard(QoLTab, 90)
    macroHeader.Position = UDim2.new(0, 0, 0, 100)
    Create("UIPadding", { Parent = macroHeader, PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })

    Create("TextLabel", {
        Parent = macroHeader,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Macro Recorder (Movement)",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local macroFrames = {}
    local isRecording, isPlaying = false, false
    local recConnection, playConnection

    local recBtn = Create("TextButton", {
        Parent = macroHeader,
        Size = UDim2.new(0.5, -6, 0, 26),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(200, 80, 80),
        Text = "Start Record",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = recBtn, CornerRadius = UDim.new(0, 4) })

    local playBtn = Create("TextButton", {
        Parent = macroHeader,
        Size = UDim2.new(0.5, -6, 0, 26),
        Position = UDim2.new(0.5, 6, 0, 28),
        BackgroundColor3 = Color3.fromRGB(80, 180, 80),
        Text = "Play Macro",
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0
    })
    Create("UICorner", { Parent = playBtn, CornerRadius = UDim.new(0, 4) })

    recBtn.MouseButton1Click:Connect(function()
        if isPlaying then return end
        isRecording = not isRecording
        if isRecording then
            macroFrames = {}
            recBtn.Text = "Stop Record"
            recBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
            showNotification("Запись макроса началась")
            recConnection = Services.Run.Heartbeat:Connect(function()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(macroFrames, LP.Character.HumanoidRootPart.CFrame)
                end
            end)
        else
            recBtn.Text = "Start Record"
            recBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            if recConnection then recConnection:Disconnect() end
            showNotification("Запись сохранена! Фреймов: " .. #macroFrames)
        end
    end)

    local macroLoop = false
    local loopCard, _, setLoop = createToggle(QoLTab, "Loop Macro Playback", 195, false, function(st) macroLoop = st end)

    playBtn.MouseButton1Click:Connect(function()
        if isRecording or #macroFrames == 0 then return end
        isPlaying = not isPlaying
        if isPlaying then
            playBtn.Text = "Stop Playback"
            playBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
            local frameIndex = 1
            playConnection = Services.Run.Heartbeat:Connect(function()
                if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
                LP.Character.HumanoidRootPart.CFrame = macroFrames[frameIndex]
                frameIndex = frameIndex + 1
                if frameIndex > #macroFrames then
                    if macroLoop then 
                        frameIndex = 1 
                    else
                        isPlaying = false
                        playBtn.Text = "Play Macro"
                        playBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
                        playConnection:Disconnect()
                    end
                end
            end)
        else
            playBtn.Text = "Play Macro"
            playBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            if playConnection then playConnection:Disconnect() end
        end
    end)
end

do
    local function createHelpCard(q, a, btnText, btnLink)
        local card = CreateStyledCard(HelpTab, 40)
        card.AutomaticSize = Enum.AutomaticSize.Y
        Create("UIPadding", { Parent = card, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
        local layout = Create("UIListLayout", { Parent = card, Padding = UDim.new(0, 6) })

        Create("TextLabel", {
            Parent = card,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = "Q: " .. q,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextColor3 = Colors.Active,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        if a ~= "" then
            Create("TextLabel", {
                Parent = card,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = "A: " .. a,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Colors.TextMain,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        if btnText then
            local b = Create("TextButton", {
                Parent = card,
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Colors.Surface,
                Text = btnText,
                TextColor3 = Colors.TextMain,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                BorderSizePixel = 0
            })
            Create("UICorner", { Parent = b, CornerRadius = UDim.new(0, 4) })
            local bStroke = Create("UIStroke", { Parent = b, Color = Colors.Border, Thickness = 1 })
            b.MouseEnter:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Active}):Play() end)
            b.MouseLeave:Connect(function() Services.TS:Create(bStroke, TWEEN_INFO_FAST, {Color = Colors.Border}):Play() end)

            b.MouseButton1Click:Connect(function()
                pcall(function()
                    if setclipboard then setclipboard(btnLink) elseif toclipboard then toclipboard(btnLink) end
                end)
                showNotification("Ссылка скопирована!")
            end)
        end
    end

    createHelpCard("Why is the menu taking a long time to load?", "Loading the menu depends on your internet connection.")
    createHelpCard("Why is the mascot not loaded in the notification?", "It also depends on your Internet connection, or on the roblox/injector itself if it does not support image uploading.")
    createHelpCard("Why are the menus lagging/hanging?", "This is also due to the fact that fixes are released daily and because of this we cannot notice all the bugs in the new versions, we continue to work on optimizing the GUI.")
    createHelpCard("Why is there a server List with a single player?", "We are aware of this issue and are already working to fix the situation. Different servers will be displayed soon.")
    createHelpCard("Why aren't the servers displayed?", "If your servers are not displayed, then your injector does not support server loading, this is not a bug!")
    createHelpCard("How do I create my own Notification Mascot?", "Go to the create section on the roblox website, then go to Creations, then go to Decals, click on the plus sign, you will be redirected to the publication menu. You select the image you need, the main thing is that it should be without a background and in PNG format.\nAfter creation, you go to the images section, click on the 3 dots on the desired image, then copy the Asset ID and insert it in the script.")
    createHelpCard("How do I remove the background and make a PNG format?", "Go into any AI and throw him a picture with the following message: Remove the background and make a PNG Format for this picture.")
    createHelpCard("How to contact us?", "So far, not as possible, we will soon create a Telegram channel or a discord channel.")
    createHelpCard("How to bypass the system key from injectors or scripts:", "", "Bypass Bot", "https://telegram.me/OrxBypass_not")
end

do
    local themeMenu = Create("Frame", { Parent = SettingsTab, Size = UDim2.new(1, -6, 0, 0), Position = UDim2.new(0, 3, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local themeLayout = Create("UIListLayout", { Parent = themeMenu, Padding = UDim.new(0, 4) })

    local function createThemeOption(name, c1, c2)
        local btn = Create("TextButton", {
            Parent = themeMenu,
            Size = UDim2.new(1, -4, 0, 26),
            BackgroundColor3 = Colors.Surface,
            Text = name,
            TextColor3 = Colors.TextMain,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0
        })
        Create("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 4) })
        local bStroke = Create("UIStroke", { Parent = btn, Color = Colors.Border, Thickness = 1 })
        
        btn.MouseButton1Click:Connect(function() _G.changeTheme(c1, c2) end)
    end

    createThemeOption("Indigo & Glow Purple", Color3.fromRGB(15, 15, 20), Color3.fromRGB(220, 190, 255))
    createThemeOption("Black & Orange", Color3.fromRGB(15, 15, 20), Color3.fromRGB(255, 120, 0))
    createThemeOption("Black & Red", Color3.fromRGB(15, 15, 20), Color3.fromRGB(255, 50, 50))
    createThemeOption("Black & Green", Color3.fromRGB(15, 15, 20), Color3.fromRGB(50, 255, 50))
    createThemeOption("Black & Blue", Color3.fromRGB(15, 15, 20), Color3.fromRGB(50, 100, 255))
    createThemeOption("Black & Cyan", Color3.fromRGB(15, 15, 20), Color3.fromRGB(0, 255, 255))
    createThemeOption("Black & Pink", Color3.fromRGB(15, 15, 20), Color3.fromRGB(255, 105, 180))
    createThemeOption("Deep Aqua & Mint", Color3.fromRGB(10, 35, 40), Color3.fromRGB(100, 255, 180))

    local themeOpened = false
    local themeBtn, themeArrow = createMenuBtn(SettingsTab, "Themes", 10, true)
    themeBtn.MouseButton1Click:Connect(function()
        themeOpened = not themeOpened
        themeMenu.Visible = true
        Services.TS:Create(themeArrow, TWEEN_INFO_FAST, {Rotation = themeOpened and 180 or 0}):Play()
        local t = Services.TS:Create(themeMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, themeOpened and 245 or 0)})
        t:Play(); t.Completed:Wait()
    end)

    local notifMenu = Create("Frame", { Parent = SettingsTab, Size = UDim2.new(1, -6, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local notifLayout = Create("UIListLayout", { Parent = notifMenu, Padding = UDim.new(0, 4) })

    createToggle(notifMenu, "Enable Notifications", 0, true, function(st) _G.NotificationsEnabled = st end)
    createToggle(notifMenu, "New notification system", 44, false, function(st) _G.UseNewNotifications = st end)

    local playerNotifsEnabled = false
    createToggle(notifMenu, "Player Notifications", 88, false, function(st) playerNotifsEnabled = st end)

    table.insert(UI.Connections, Services.Players.PlayerAdded:Connect(function(p)
        if playerNotifsEnabled then showNotification(p.Name .. " зашёл на сервер") end
    end))
    table.insert(UI.Connections, Services.Players.PlayerRemoving:Connect(function(p)
        if playerNotifsEnabled then showNotification(p.Name .. " вышел с сервера") end
    end))

    local mascotCard = CreateStyledCard(notifMenu, 40)
    mascotCard.Position = UDim2.new(0, 0, 0, 132)
    local mascotInput = Create("TextBox", {
        Parent = mascotCard,
        Size = UDim2.new(1, -24, 1, -12),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundColor3 = Colors.ToggleShell,
        BorderSizePixel = 0,
        TextColor3 = Colors.TextMain,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        PlaceholderText = "Paste Character Asset ID..."
    })
    Create("UICorner", { Parent = mascotInput, CornerRadius = UDim.new(0, 4) })
    local mInStroke = Create("UIStroke", { Parent = mascotInput, Color = Colors.Border, Thickness = 1 })
    mascotInput:GetPropertyChangedSignal("Text"):Connect(function()
        local v = mascotInput.Text
        if v ~= "" then
            _G.NotificationAssetID = tonumber(v) and "rbxthumb://type=Asset&id=" .. v .. "&w=150&h=150" or v
        end
    end)

    local notifBtn, notifArrow = createMenuBtn(SettingsTab, "Notifications Management", 55, true)
    local notifOpened = false
    notifBtn.MouseButton1Click:Connect(function()
        notifOpened = not notifOpened
        notifMenu.Visible = true
        Services.TS:Create(notifArrow, TWEEN_INFO_FAST, {Rotation = notifOpened and 180 or 0}):Play()
        local t = Services.TS:Create(notifMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, notifOpened and 180 or 0)})
        t:Play(); t.Completed:Wait()
    end)

    local renderCard = CreateStyledCard(SettingsTab, 55)
    renderCard.Position = UDim2.new(0, 0, 0, 100)
    createSlider(renderCard, 0, "Map render distance", 10, 5000, 1000, function(val)
        Services.Lighting.FogEnd = val
        Services.Lighting.FogStart = val * 0.5
    end)

    local renderMenu = Create("Frame", { Parent = SettingsTab, Size = UDim2.new(1, -6, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
    local renderLayout = Create("UIListLayout", { Parent = renderMenu, Padding = UDim.new(0, 4) })

    createToggle(renderMenu, "Drawing characters", 0, true, function(st)
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                for _, v in ipairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = st and 0 or 1 end
                end
            end
        end
    end)
    createToggle(renderMenu, "Drawing accessories", 44, true, function(st)
        for _, plr in ipairs(Services.Players:GetPlayers()) do
            if plr.Character then
                for _, v in ipairs(plr.Character:GetChildren()) do
                    if v:IsA("Accessory") and v:FindFirstChild("Handle") then v.Handle.Transparency = st and 0 or 1 end
                end
            end
        end
    end)
    createToggle(renderMenu, "Ray drawing", 88, true, function(st)
        for _, v in pairs(Services.Lighting:GetChildren()) do
            if v:IsA("SunRaysEffect") then v.Enabled = st end
        end
    end)
    createToggle(renderMenu, "Drawing shadows", 132, true, function(st)
        Services.Lighting.GlobalShadows = st
    end)

    local renderOpened = false
    local renderBtn, renderArrow = createMenuBtn(SettingsTab, "Graphic Optimizations", 160, true)
    renderBtn.MouseButton1Click:Connect(function()
        renderOpened = not renderOpened
        renderMenu.Visible = true
        Services.TS:Create(renderArrow, TWEEN_INFO_FAST, {Rotation = renderOpened and 180 or 0}):Play()
        local t = Services.TS:Create(renderMenu, TWEEN_INFO_FAST, {Size = UDim2.new(1, -6, 0, renderOpened and 180 or 0)})
        t:Play(); t.Completed:Wait()
    end)

    createToggle(SettingsTab, "Watermark", 205, true, function(st)
        if Watermark then Watermark.Visible = st end
    end)

    local oldDesignEnabled = false
    local savedColors = {}
    createToggle(SettingsTab, "Old design", 250, false, function(st)
        oldDesignEnabled = st
        for _, obj in pairs(UI.Screen:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if obj.BackgroundTransparency < 1 then
                    if st then
                        if not savedColors[obj] then savedColors[obj] = obj.BackgroundColor3 end
                        obj.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                    else
                        if savedColors[obj] then obj.BackgroundColor3 = savedColors[obj] end
                    end
                end
            end
        end
        if not st then savedColors = {} end
    end)
end



local isFlinging = false
local currentFlingTarget = nil
local FlingWin, FlingClose, FlingScroll, FlingLayout, FlingActionBtn, FlingActionLbl = createFloatingMenu("Fling")
createToggle(FunnyTab, "Fling Target", 145, false, function(st)
    FlingWin.Visible = st
    if st then populatePlayers(FlingScroll, FlingLayout, FlingActionLbl, "Fling", function(p) currentFlingTarget = p end) end
end)


FlingClose.MouseButton1Click:Connect(function() FlingWin.Visible = false end)
FlingActionBtn.MouseButton1Click:Connect(function()
    if not currentFlingTarget or not currentFlingTarget.Character or isFlinging then return end
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    isFlinging = true; showNotification("Fling применяется к " .. currentFlingTarget.Name)
    local hrp = LP.Character.HumanoidRootPart; local oldPos = hrp.CFrame
    local bv = Instance.new("BodyAngularVelocity", hrp); bv.AngularVelocity = Vector3.new(0, 99999, 0); bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); bv.P = math.huge
    local bt = Instance.new("BodyThrust", hrp); bt.Force = Vector3.new(9999, 9999, 9999); LP.Character.Humanoid.Sit = true
    local flingTime = 0; local flingCon
    flingCon = Services.Run.Stepped:Connect(function(_, dt)
        flingTime = flingTime + dt
        if flingTime > 2.5 or not currentFlingTarget.Character or not currentFlingTarget.Character:FindFirstChild("HumanoidRootPart") then
            if bv then bv:Destroy() end
            if bt then bt:Destroy() end; hrp.Velocity = Vector3.new(); hrp.RotVelocity = Vector3.new(); hrp.CFrame = oldPos; LP.Character.Humanoid.Sit = false
            isFlinging = false; flingCon:Disconnect(); return
        end
        hrp.CFrame = currentFlingTarget.Character.HumanoidRootPart.CFrame
    end)
    table.insert(UI.Connections, flingCon)
end)

local isBringing = false
local currentBringTarget = nil
local BringWin, BringClose, BringScroll, BringLayout, BringActionBtn, BringActionLbl = createFloatingMenu("Bring Parts")
createToggle(FunnyTab, "Bring Parts", 190, false, function(st)
    BringWin.Visible = st
    if st then populatePlayers(BringScroll, BringLayout, BringActionLbl, "Bring", function(p) currentBringTarget = p end) end
end)
BringClose.MouseButton1Click:Connect(function() BringWin.Visible = false end)

local bringConnection = nil
local BringFolder = nil
local descConn = nil
BringActionBtn.MouseButton1Click:Connect(function()
    if not currentBringTarget or not currentBringTarget.Character then return end
    if isBringing then
        isBringing = false
        if bringConnection then bringConnection:Disconnect(); bringConnection = nil end
        if BringFolder then BringFolder:Destroy(); BringFolder = nil end
        if descConn then descConn:Disconnect(); descConn = nil end
        showNotification("Притяжение деталей остановлено")
        return
    end
    isBringing = true; showNotification("Сбор физических объектов к " .. currentBringTarget.Name)

    if not _G.SeptusNetwork then
        _G.SeptusNetwork = { BaseParts = {}, Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424) }
        _G.SeptusNetwork.RetainPart = function(Part)
            if Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
                table.insert(_G.SeptusNetwork.BaseParts, Part)
                Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                Part.CanCollide = false
            end
        end
        table.insert(UI.Connections, Services.Run.Heartbeat:Connect(function()
            pcall(function() sethiddenproperty(LP, "SimulationRadius", math.huge) end)
            for _, Part in pairs(_G.SeptusNetwork.BaseParts) do
                if Part:IsDescendantOf(workspace) then Part.Velocity = _G.SeptusNetwork.Velocity end
            end
        end))
    end

    BringFolder = Instance.new("Folder", workspace)
    local attPart = Instance.new("Part", BringFolder)
    attPart.Anchored = true; attPart.CanCollide = false; attPart.Transparency = 1
    local Attachment1 = Instance.new("Attachment", attPart)

    local function ForcePart(v)
        if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
            end
            v.CanCollide = false
            _G.SeptusNetwork.RetainPart(v)
            local Torque = Instance.new("Torque", v)
            Torque.Torque = Vector3.new(100000, 100000, 100000)
            local AlignPosition = Instance.new("AlignPosition", v)
            local Attachment2 = Instance.new("Attachment", v)
            Torque.Attachment0 = Attachment2
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 200
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = Attachment1
        end
    end

    for _, v in ipairs(workspace:GetDescendants()) do ForcePart(v) end
    descConn = workspace.DescendantAdded:Connect(ForcePart)
    table.insert(UI.Connections, descConn)

    bringConnection = Services.Run.RenderStepped:Connect(function()
        if not isBringing or not currentBringTarget.Character then
            if descConn then descConn:Disconnect() end
            if BringFolder then BringFolder:Destroy(); BringFolder = nil end
            if bringConnection then bringConnection:Disconnect() end
            return
        end
        local hrp = currentBringTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp then Attachment1.WorldCFrame = hrp.CFrame end
    end)
    table.insert(UI.Connections, bringConnection)
end)

local ConfirmCloseWin = Create("Frame", { Parent = UI.Screen, Size = UDim2.new(0, 260, 0, 110), Position = UDim2.new(0.5, -130, 0.5, -55), BackgroundColor3 = Colors.Background, Visible = false, ZIndex = 99999 })
Create("UICorner", { Parent = ConfirmCloseWin, CornerRadius = UDim.new(0, 10) })
Create("UIStroke", { Parent = ConfirmCloseWin, Color = Colors.Border, Thickness = 1 })

local confLbl = Create("TextLabel", { Parent = ConfirmCloseWin, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1, Text = "Close the script?", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 100000 })
local btnYes = Create("TextButton", { Parent = ConfirmCloseWin, Size = UDim2.new(0, 95, 0, 30), Position = UDim2.new(0, 25, 0, 60), BackgroundColor3 = Colors.Active, Text = "Yes", TextColor3 = Colors.Background, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 100000 })
Create("UICorner", { Parent = btnYes, CornerRadius = UDim.new(0, 4) })
local btnNo = Create("TextButton", { Parent = ConfirmCloseWin, Size = UDim2.new(0, 95, 0, 30), Position = UDim2.new(1, -120, 0, 60), BackgroundColor3 = Colors.Surface, Text = "No", TextColor3 = Colors.TextMain, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 100000 })
Create("UICorner", { Parent = btnNo, CornerRadius = UDim.new(0, 4) })
local noStroke = Create("UIStroke", { Parent = btnNo, Color = Colors.Border, Thickness = 1 })

btnNo.MouseButton1Click:Connect(function() ConfirmCloseWin.Visible = false end)
btnYes.MouseButton1Click:Connect(function()
    for name, updater in pairs(_G.ConfigUpdaters) do
        if name ~= "Drawing characters" and name ~= "Drawing accessories" and name ~= "Ray drawing" then
            if _G.ConfigState[name] then pcall(function() updater(false) end) end
        end
    end
    
    if _G.ConfigUpdaters["Drawing characters"] then pcall(function() _G.ConfigUpdaters["Drawing characters"](true) end) end
    if _G.ConfigUpdaters["Drawing accessories"] then pcall(function() _G.ConfigUpdaters["Drawing accessories"](true) end) end
    if _G.ConfigUpdaters["Ray drawing"] then pcall(function() _G.ConfigUpdaters["Ray drawing"](true) end) end
    
    for _, conn in pairs(UI.Connections) do if conn.Disconnect then conn:Disconnect() end end
    for _, draw in pairs(_G.pDrawings) do draw.box:Remove(); draw.tracer:Remove() end
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Anchored = false end
    
    local L = Services.Lighting
    L.GlobalShadows = true
    for _, obj in pairs(L:GetChildren()) do
        if obj.Name == "RetroCC" or obj.Name == "CustomSky" or obj.Name == "RTXShaders" or obj.Name == "CyberShaders" or obj.Name == "SilentShaders" or obj.Name == "FriedShaders" or obj.Name == "NightVisionShaders" or obj.Name == "SeptusBlur" then
            obj:Destroy()
        end
    end
    UI.Screen:Destroy()
end)

CloseBtn.MouseButton1Click:Connect(function() ConfirmCloseWin.Visible = true end)

local ToggleBtn = Create("TextButton", {
    Parent = UI.Screen,
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(0, 20, 0.5, -22),
    BackgroundColor3 = Colors.Surface,
    Text = "",
    Visible = false,
    BorderSizePixel = 0
})
Create("UICorner", { Parent = ToggleBtn, CornerRadius = UDim.new(0, 10) })
local toggleStroke = Create("UIStroke", { Parent = ToggleBtn, Color = Colors.Active, Thickness = 1 })

local toggleIcon = Create("ImageLabel", {
    Parent = ToggleBtn,
    Size = UDim2.new(1, -12, 1, -12),
    Position = UDim2.new(0, 6, 0, 6),
    BackgroundTransparency = 1,
    Image = "rbxassetid://83309664199973"
})

_G.UpdateToggleIcon = function(id) if toggleIcon then toggleIcon.Image = id end end
makeDraggable(ToggleBtn)

local blurEffect = Instance.new("BlurEffect", Services.Lighting)
blurEffect.Size = 0
blurEffect.Name = "SeptusBlur"

local isGuiVisible = false
local isMinimized = false

ToggleBtn.MouseButton1Click:Connect(function()
    isGuiVisible = not isGuiVisible
    if isGuiVisible then
        UI.Frame.Visible = true

        local targetSize = isMinimized and UDim2.new(0, 520, 0, 38) or UDim2.new(0, 520, 0, 340)
        local targetBlur = isMinimized and 0 or 15
        
        Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = targetSize, Position = UDim2.new(0.5, -260, 0.5, -170), BackgroundTransparency = 0 }):Play()
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = targetBlur }):Play()
        ContentFrame.Visible = not isMinimized
    else
        local shrink = Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0) })
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = 0 }):Play()
        shrink:Play()
        shrink.Completed:Wait()
        if not isGuiVisible then UI.Frame.Visible = false end
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then

        Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = UDim2.new(0, 520, 0, 38) }):Play()
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = 0 }):Play()
        ContentFrame.Visible = false
    else

        Services.TS:Create(UI.Frame, TWEEN_INFO_SMOOTH, { Size = UDim2.new(0, 520, 0, 340) }):Play()
        Services.TS:Create(blurEffect, TWEEN_INFO_SMOOTH, { Size = 15 }):Play()
        ContentFrame.Visible = true
    end
end)

task.spawn(function()
    repeat task.wait() until _G.MainMenuLoaded == true
    ToggleBtn.Visible = true
    showNotification("SEPTUS HUB успешно загружен!")
    
    local HomeBtn = Sidebar:FindFirstChild("HomeBtn")
    if HomeBtn then
        HomeBtn.Indicator.Size = UDim2.new(0, 3, 0, 16)
        HomeBtn.Indicator.BackgroundTransparency = 0
        HomeBtn.TextColor3 = Colors.TextMain
        ActiveTab = "Home"
        UI.Pages.Home.Visible = true
    end
end)

local executor = "Unknown"
pcall(function() if identifyexecutor then executor = identifyexecutor() elseif getexecutorname then executor = getexecutorname() end end)
local execLabel = Create("TextLabel", { Parent = UI.Frame, Size = UDim2.new(0, 100, 0, 20), Position = UDim2.new(1, -235, 0, 8), BackgroundTransparency = 1, Text = "Executor: " .. executor, TextColor3 = Colors.TextDim, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right })

local AntiAfk = Networking and Networking.AntiAfk and Networking.AntiAfk.RequestHop
if AntiAfk then
    local origHop = AntiAfk.RequestHop.Fire
    AntiAfk.RequestHop.Fire = function() return end
    LP:SetAttribute("AntiAfkIdleOverride", 999999)
end
