local NewlocUI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local function GetGuiParent()
    local ok, parent = pcall(function()
        if gethui then
            return gethui()
        end
        return CoreGui
    end)

    if ok and parent then
        return parent
    end

    return Player:WaitForChild("PlayerGui")
end

local Theme = {
    Background = Color3.fromRGB(12, 12, 16),
    Sidebar = Color3.fromRGB(17, 17, 23),
    Panel = Color3.fromRGB(23, 23, 30),
    Element = Color3.fromRGB(30, 30, 39),
    Accent = Color3.fromRGB(132, 55, 255),
    AccentDark = Color3.fromRGB(83, 32, 170),
    Text = Color3.fromRGB(245, 245, 250),
    SubText = Color3.fromRGB(150, 150, 165),
    Border = Color3.fromRGB(48, 48, 60),
    White = Color3.fromRGB(255, 255, 255)
}

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function Stroke(parent, color, transparency)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        Thickness = 1
    }, parent)
end

local function Tween(object, properties, duration)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )

    animation:Play()
    return animation
end

local function Label(parent, text, size, color, font)
    return Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextSize = size or 14,
        TextColor3 = color or Theme.Text,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(1, 0, 1, 0)
    }, parent)
end

-- WINDOW

function NewlocUI:CreateWindow(config)

    config = config or {}

    local WindowName = config.Name or "NEWLOC MENU"
    local Subtitle = config.Subtitle or "UI Library"
    local ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local GuiParent = GetGuiParent()

    -- remove janela antiga caso execute o script de novo
    for _, gui in ipairs(GuiParent:GetChildren()) do
        if gui.Name == "NewlocUI" then
            gui:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NewlocUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        pcall(syn.protect_gui, ScreenGui)
    end

    ScreenGui.Parent = GuiParent

    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(900, 560),
        Position = UDim2.new(0.5, -450, 0.5, -280),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, ScreenGui)

    Corner(Main, 12)
    Stroke(Main, Theme.Border)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 195, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    }, Main)

    local Logo = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 20),
        Size = UDim2.new(1, -30, 0, 45),
        Text = "NEWLOC",
        TextColor3 = Theme.Accent,
        TextSize = 29,
        Font = Enum.Font.GothamBlack
    }, Sidebar)

    local LogoSub = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 61),
        Size = UDim2.new(1, -30, 0, 20),
        Text = Subtitle,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        Font = Enum.Font.GothamMedium
    }, Sidebar)

    Create("Frame", {
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0
    }, Sidebar)

    local TabHolder = Create("ScrollingFrame", {
        Name = "Tabs",
        Position = UDim2.fromOffset(10, 110),
        Size = UDim2.new(1, -20, 1, -180),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    }, Sidebar)

    local TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, TabHolder)

    local UserInfo = Create("Frame", {
        Position = UDim2.new(0, 12, 1, -60),
        Size = UDim2.new(1, -24, 0, 45),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0
    }, Sidebar)

    Corner(UserInfo, 8)

    Label(
        Create("Frame", {
            Position = UDim2.fromOffset(10, 0),
            Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1
        }, UserInfo),
        Player.DisplayName,
        13,
        Theme.Text,
        Enum.Font.GothamBold
    )

    local Content = Create("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(195, 0),
        Size = UDim2.new(1, -195, 1, 0),
        BackgroundTransparency = 1
    }, Main)

    local Topbar = Create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1
    }, Content)

    local Title = Create("TextLabel", {
        Position = UDim2.fromOffset(22, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, Topbar)

    local Close = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.fromOffset(34, 32),
        BackgroundColor3 = Theme.Element,
        Text = "×",
        TextSize = 23,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham
    }, Topbar)

    Corner(Close, 7)

    local Minimize = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -55, 0.5, 0),
        Size = UDim2.fromOffset(34, 32),
        BackgroundColor3 = Theme.Element,
        Text = "−",
        TextSize = 21,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham
    }, Topbar)

    Corner(Minimize, 7)

    local Pages = {}
    local SelectedTab = nil
    local Window = {}

    -- DRAG

    local dragging = false
    local dragStart
    local startPosition

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- WINDOW CONTROLS

    local minimized = false

    Minimize.MouseButton1Click:Connect(function()
        minimized = not minimized

        Tween(Main, {
            Size = minimized
                and UDim2.fromOffset(900, 55)
                or UDim2.fromOffset(900, 560)
        }, 0.25)

        Minimize.Text = minimized and "+" or "−"
    end)

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- NOTIFICATIONS

    function Window:Notify(config)
        config = config or {}

        local notification = Create("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 350, 1, -20),
            Size = UDim2.fromOffset(280, 75),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            ZIndex = 20
        }, ScreenGui)

        Corner(notification, 9)
        Stroke(notification, Theme.Accent)

        local title = Create("TextLabel", {
            Position = UDim2.fromOffset(13, 8),
            Size = UDim2.new(1, -25, 0, 23),
            BackgroundTransparency = 1,
            Text = config.Title or "NEWLOC",
            TextColor3 = Theme.Accent,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 21
        }, notification)

        local message = Create("TextLabel", {
            Position = UDim2.fromOffset(13, 32),
            Size = UDim2.new(1, -25, 0, 30),
            BackgroundTransparency = 1,
            Text = config.Content or "Notificação",
            TextColor3 = Theme.SubText,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 21
        }, notification)

        Tween(notification, {
            Position = UDim2.new(1, -15, 1, -20)
        }, 0.3)

        task.delay(config.Duration or 3, function()
            if notification.Parent then
                Tween(notification, {
                    Position = UDim2.new(1, 350, 1, -20)
                }, 0.3)

                task.wait(0.35)
                notification:Destroy()
            end
        end)
    end

    -- TAB

    function Window:CreateTab(config)

        config = config or {}

        local TabName = config.Name or "Nova Aba"
        local Icon = config.Icon or "◆"

        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 43),
            BackgroundColor3 = Theme.Sidebar,
            Text = "",
            AutoButtonColor = false
        }, TabHolder)

        Corner(TabButton, 7)

        local AccentBar = Create("Frame", {
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        }, TabButton)

        Corner(AccentBar, 5)

        local TabIcon = Create("TextLabel", {
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.fromOffset(25, 43),
            BackgroundTransparency = 1,
            Text = Icon,
            TextSize = 17,
            TextColor3 = Theme.SubText,
            Font = Enum.Font.GothamBold
        }, TabButton)

        local TabLabel = Create("TextLabel", {
            Position = UDim2.fromOffset(45, 0),
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = TabName,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        }, TabButton)

        local Page = Create("ScrollingFrame", {
            Name = TabName,
            Position = UDim2.fromOffset(15, 65),
            Size = UDim2.new(1, -30, 1, -80),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            Visible = false
        }, Content)

        Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, Page)

        local Tab = {}

        function Tab:Select()
            for _, data in ipairs(Pages) do
                data.Page.Visible = false
                data.Button.BackgroundColor3 = Theme.Sidebar
                data.Bar.BackgroundTransparency = 1
                data.Label.TextColor3 = Theme.SubText
                data.Icon.TextColor3 = Theme.SubText
            end

            Page.Visible = true
            TabButton.BackgroundColor3 = Theme.Element
            AccentBar.BackgroundTransparency = 0
            TabLabel.TextColor3 = Theme.Text
            TabIcon.TextColor3 = Theme.Accent

            SelectedTab = TabName
        end

        TabButton.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        table.insert(Pages, {
            Page = Page,
            Button = TabButton,
            Bar = AccentBar,
            Label = TabLabel,
            Icon = TabIcon
        })

        if #Pages == 1 then
            Tab:Select()
        end

        -- SECTION

        function Tab:CreateSection(name)

            local Section = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0
            }, Page)

            Corner(Section, 9)
            Stroke(Section, Theme.Border)

            local SectionTitle = Create("TextLabel", {
                Position = UDim2.fromOffset(13, 8),
                Size = UDim2.new(1, -26, 0, 25),
                BackgroundTransparency = 1,
                Text = name or "Section",
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            }, Section)

            local Elements = Create("Frame", {
                Position = UDim2.fromOffset(10, 40),
                Size = UDim2.new(1, -20, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1
            }, Section)

            Create("UIListLayout", {
                Padding = UDim.new(0, 7),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, Elements)

            local Components = {}

            local function NewRow(height)
                local Row = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 40),
                    BackgroundColor3 = Theme.Element,
                    BorderSizePixel = 0
                }, Elements)

                Corner(Row, 7)
                return Row
            end

            local function NewLabel(parent, name)
                local label = Create("TextLabel", {
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(0.55, -10, 1, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left
                }, parent)

                return label
            end

            -- BUTTON

            function Components:CreateButton(config)
                config = config or {}

                local Row = NewRow(40)
                NewLabel(Row, config.Name or "Button")

                local Button = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(115, 29),
                    BackgroundColor3 = Theme.AccentDark,
                    Text = config.NameButton or "Executar",
                    TextColor3 = Theme.White,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold
                }, Row)

                Corner(Button, 6)

                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.Accent}, 0.1)

                    if config.Callback then
                        task.spawn(config.Callback)
                    end

                    task.delay(0.15, function()
                        if Button.Parent then
                            Tween(Button, {BackgroundColor3 = Theme.AccentDark}, 0.1)
                        end
                    end)
                end)

                return Row
            end

            -- TOGGLE

            function Components:CreateToggle(config)
                config = config or {}

                local value = config.CurrentValue or false

                local Row = NewRow(40)
                NewLabel(Row, config.Name or "Toggle")

                local Toggle = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -12, 0.5, 0),
                    Size = UDim2.fromOffset(43, 23),
                    BackgroundColor3 = value and Theme.Accent or Theme.Border,
                    Text = "",
                    AutoButtonColor = false
                }, Row)

                Corner(Toggle, 20)

                local Circle = Create("Frame", {
                    Position = value and UDim2.new(1, -21, 0.5, -8)
                        or UDim2.fromOffset(5, 4),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = Theme.White,
                    BorderSizePixel = 0
                }, Toggle)

                Corner(Circle, 20)

                local function Update()
                    Tween(Toggle, {
                        BackgroundColor3 = value and Theme.Accent or Theme.Border
                    }, 0.15)

                    Tween(Circle, {
                        Position = value
                            and UDim2.new(1, -21, 0.5, -8)
                            or UDim2.fromOffset(5, 4)
                    }, 0.15)

                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end

                Toggle.MouseButton1Click:Connect(function()
                    value = not value
                    Update()
                end)

                local Object = {}

                function Object:Set(newValue)
                    value = newValue == true
                    Update()
                end

                function Object:Get()
                    return value
                end

                return Object
            end

            -- SLIDER

            function Components:CreateSlider(config)
                config = config or {}

                local minimum = config.Range and config.Range[1] or 0
                local maximum = config.Range and config.Range[2] or 100
                local value = math.clamp(config.CurrentValue or minimum, minimum, maximum)

                local Row = NewRow(57)
                NewLabel(Row, config.Name or "Slider")

                local ValueLabel = Create("TextLabel", {
                    Position = UDim2.new(1, -65, 0, 3),
                    Size = UDim2.fromOffset(50, 20),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right
                }, Row)

                local Bar = Create("Frame", {
                    Position = UDim2.new(0, 12, 0, 36),
                    Size = UDim2.new(1, -24, 0, 5),
                    BackgroundColor3 = Theme.Border,
                    BorderSizePixel = 0
                }, Row)

                Corner(Bar, 10)

                local Fill = Create("Frame", {
                    Size = UDim2.new((value - minimum) / math.max(maximum - minimum, 1), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0
                }, Bar)

                Corner(Fill, 10)

                local Knob = Create("TextButton", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0),
                    Size = UDim2.fromOffset(15, 15),
                    BackgroundColor3 = Theme.White,
                    Text = "",
                    AutoButtonColor = false
                }, Bar)

                Corner(Knob, 20)

                local function Update(inputX)
                    local percent = math.clamp(
                        (inputX - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                        0, 1
                    )

                    value = minimum + (maximum - minimum) * percent

                    local precision = config.Decimal or 0
                    local multiplier = 10 ^ precision
                    value = math.floor(value * multiplier + 0.5) / multiplier

                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    Knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    ValueLabel.Text = tostring(value)

                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end

                local sliding = false

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                        Update(input.Position.X)
                    end
                end)

                Knob.MouseButton1Down:Connect(function()
                    sliding = true
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)

                local Object = {}

                function Object:Set(newValue)
                    value = math.clamp(newValue, minimum, maximum)
                    local percent = (value - minimum) / math.max(maximum - minimum, 1)

                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    Knob.Position = UDim2.new(percent, 0, 0.5, 0)
                    ValueLabel.Text = tostring(value)

                    if config.Callback then
                        task.spawn(config.Callback, value)
                    end
                end

                function Object:Get()
                    return value
                end

                return Object
            end

            -- DROPDOWN

            function Components:CreateDropdown(config)
                config = config or {}

                local options = config.Options or {}
                local selected = config.CurrentOption or options[1] or "Nenhum"

                local Row = NewRow(40)
                NewLabel(Row, config.Name or "Dropdown")

                local Button = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(150, 29),
                    BackgroundColor3 = Theme.Panel,
                    Text = tostring(selected) .. "  ▾",
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham
                }, Row)

                Corner(Button, 6)

                local index = table.find(options, selected) or 1

                Button.MouseButton1Click:Connect(function()
                    if #options == 0 then return end

                    index = index % #options + 1
                    selected = options[index]
                    Button.Text = tostring(selected) .. "  ▾"

                    if config.Callback then
                        task.spawn(config.Callback, selected)
                    end
                end)

                local Object = {}

                function Object:Set(option)
                    local newIndex = table.find(options, option)

                    if newIndex then
                        index = newIndex
                        selected = option
                        Button.Text = tostring(selected) .. "  ▾"

                        if config.Callback then
                            task.spawn(config.Callback, selected)
                        end
                    end
                end

                function Object:Get()
                    return selected
                end

                return Object
            end

            -- TEXTBOX

            function Components:CreateTextbox(config)
                config = config or {}

                local Row = NewRow(40)
                NewLabel(Row, config.Name or "Textbox")

                local Input = Create("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(150, 29),
                    BackgroundColor3 = Theme.Panel,
                    PlaceholderText = config.PlaceholderText or "Digite aqui...",
                    Text = config.CurrentValue or "",
                    TextColor3 = Theme.Text,
                    PlaceholderColor3 = Theme.SubText,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false
                }, Row)

                Corner(Input, 6)

                Input.FocusLost:Connect(function(enterPressed)
                    if config.Callback then
                        task.spawn(config.Callback, Input.Text, enterPressed)
                    end
                end)

                local Object = {}

                function Object:Set(value)
                    Input.Text = tostring(value)
                end

                function Object:Get()
                    return Input.Text
                end

                return Object
            end

            -- KEYBIND

            function Components:CreateKeybind(config)
                config = config or {}

                local currentKey = config.CurrentKey or Enum.KeyCode.E

                local Row = NewRow(40)
                NewLabel(Row, config.Name or "Keybind")

                local Button = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(100, 28),
                    BackgroundColor3 = Theme.Panel,
                    Text = currentKey.Name,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold
                }, Row)

                Corner(Button, 6)

                local listening = false

                Button.MouseButton1Click:Connect(function()
                    listening = true
                    Button.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        listening = false
                        Button.Text = currentKey.Name
                        return
                    end

                    if not processed and not listening
                        and input.KeyCode == currentKey then

                        if config.Callback then
                            task.spawn(config.Callback, currentKey)
                        end
                    end
                end)

                local Object = {}

                function Object:Get()
                    return currentKey
                end

                function Object:Set(key)
                    currentKey = key
                    Button.Text = key.Name
                end

                return Object
            end

            return Components
        end

        return Tab
    end

    -- DESTROY

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:GetScreenGui()
        return ScreenGui
    end

    return Window
end

return NewlocUI