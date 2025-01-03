local Library = {windowCount = 0, flags = {}}
local Services = {}
setmetatable(
    Services,
    {
        __index = function(_, serviceName)
            return game:GetService(serviceName)
        end,
        __newindex = function(_, _)
            return
        end
    }
)

local currentDraggedObject
local playerMouse = Services.Players.LocalPlayer:GetMouse()

function Drag(element, handle)
    if currentDraggedObject then
        currentDraggedObject.ZIndex = -2
    end
    currentDraggedObject = element
    currentDraggedObject.ZIndex = -1

    handle = handle or element
    local isDragging, dragStartPosition, elementStartPosition, currentInput

    local function updatePosition(input)
        local delta = input.Position - dragStartPosition
        element.Position = UDim2.new(
            elementStartPosition.X.Scale,
            elementStartPosition.X.Offset + delta.X,
            elementStartPosition.Y.Scale,
            elementStartPosition.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPosition = input.Position
            elementStartPosition = element.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    element.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            currentInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == currentInput and isDragging then
            updatePosition(input)
        end
    end)
end

function ClickEffect(target)
    spawn(function()
        if not target.ClipsDescendants then
            target.ClipsDescendants = true
        end

        local ripple = Instance.new("ImageLabel")
        ripple.Name = "Ripple"
        ripple.Parent = target
        ripple.BackgroundTransparency = 1
        ripple.ZIndex = 8
        ripple.Image = "rbxassetid://2708891598"
        ripple.ImageTransparency = 0.8
        ripple.ScaleType = Enum.ScaleType.Fit
        ripple.ImageColor3 = Color3.fromRGB(131, 132, 255)
        ripple.Position = UDim2.new(
            (playerMouse.X - ripple.AbsolutePosition.X) / target.AbsoluteSize.X,
            0,
            (playerMouse.Y - ripple.AbsolutePosition.Y) / target.AbsoluteSize.Y,
            0
        )

        Services.TweenService:Create(
            ripple,
            TweenInfo.new(1),
            {Position = UDim2.new(-5.5, 0, -5.5, 0), Size = UDim2.new(12, 0, 12, 0)}
        ):Play()

        wait(0.25)

        Services.TweenService:Create(ripple, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()

        repeat
            wait()
        until ripple.ImageTransparency == 1

        ripple:Destroy()
    end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = Services.HttpService:GenerateGUID()
screenGui.Parent = Services.RunService:IsStudio() and Services.Players.LocalPlayer:WaitForChild("PlayerGui") or Services.CoreGui

Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift and not gameProcessed then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

function Library:CreateWindow(title)
    local windowOpen = false
    Library.windowCount = Library.windowCount + 1

    local topFrame = Instance.new("Frame")
    local windowLine = Instance.new("Frame")
    local gradient = Instance.new("UIGradient")
    local header = Instance.new("TextLabel")
    local toggleButton = Instance.new("TextButton")
    local toggleIcon = Instance.new("ImageLabel")
    local bottomFrame = Instance.new("Frame")
    local layout = Instance.new("UIListLayout")
    local padding = Instance.new("Frame")

    topFrame.Name = "Top"
    topFrame.Parent = screenGui
    topFrame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
    topFrame.BorderSizePixel = 0
    topFrame.Position = UDim2.new(0, 25, 0, -30 + 36 * Library.windowCount + 6 * Library.windowCount)
    topFrame.Size = UDim2.new(0, 212, 0, 36)
    Drag(topFrame)

    windowLine.Name = "WindowLine"
    windowLine.Parent = topFrame
    windowLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    windowLine.BorderSizePixel = 0
    windowLine.Position = UDim2.new(0, 0, 0, 34)
    windowLine.Size = UDim2.new(0, 212, 0, 2)

    gradient.Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 43, 43)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(43, 43, 43)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(131, 132, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(43, 43, 43)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(43, 43, 43))
    }
    gradient.Name = "WindowLineGradient"
    gradient.Parent = windowLine

    header.Name = "Header"
    header.Parent = topFrame
    header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.Size = UDim2.new(0, 54, 0, 34)
    header.Font = Enum.Font.GothamSemibold
    header.Text = "   " .. (title or "")
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left

    toggleButton.Name = "WindowToggle"
    toggleButton.Parent = topFrame
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BackgroundTransparency = 1
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(0.835, 0, 0, 0)
    toggleButton.Size = UDim2.new(0, 34, 0, 34)
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.Text = ""

    toggleIcon.Name = "WindowToggleImg"
    toggleIcon.Parent = toggleButton
    toggleIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.BorderSizePixel = 0
    toggleIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleIcon.Size = UDim2.new(0, 18, 0, 18)
    toggleIcon.Image = "rbxassetid://3926305904"
    toggleIcon.ImageRectOffset = Vector2.new(524, 764)
    toggleIcon.ImageRectSize = Vector2.new(36, 36)
    toggleIcon.Rotation = 180

    bottomFrame.Name = "Bottom"
    bottomFrame.Parent = topFrame
    bottomFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    bottomFrame.BorderSizePixel = 0
    bottomFrame.ClipsDescendants = true
    bottomFrame.Position = UDim2.new(0, 0, 1, 0)
    bottomFrame.Size = UDim2.new(0, 212, 0, 0)

    layout.Name = "BottomLayout"
    layout.Parent = bottomFrame
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)

    padding.Name = "PaddingThing"
    padding.Parent = bottomFrame
    padding.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    padding.BorderSizePixel = 0
    padding.Position = UDim2.new(0.263, 0, 0
    padding.Size = UDim2.new(0, 100, 0, 0)
    local playerMouse = false
    local function currentInput()
        if playerMouse then
            return
        end
        windowOpen = not windowOpen
        local playerMouse = true
        Services.TweenService:Create(
            bottomFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Size = UDim2.new(0, 212, 0, windowOpen and F.AbsoluteContentSize.Y + 4 or 0)}
        ):Play()
        Services.TweenService:Create(
            toggleIcon,
            TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {Rotation = windowOpen and 0 or 180}
        ):Play()
        wait(.25)
        windowOpen = false
    end
    local function UI()
        if playerMouse or not windowOpen then
            return
        end
        bottomFrame.Size.Y.Offset = layout.AbsoluteContentSize.Y + 4
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UI)
    toggleButton.MouseButton1Click:Connect(currentInput)
    local Functions = {}
    function Functions:Label(text)
        local label = Instance.new("TextButton")
        label.Name = "Label"
        label.Parent = Functions
        label.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
        label.BorderSizePixel = 0
        label.Position = UDim2.new(0.0212264154, 0, 0.71676302, 0)
        label.Size = UDim2.new(0, 203, 0, 26)
        label.AutoButtonColor = false
        label.Font = Enum.Font.GothamSemibold
        label.Text = tostring(text) or ""
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14.000
        return label
    end
function Functions:Button(label, onClickFunction)
    local buttonFrame = Instance.new("Frame")
    local button = Instance.new("TextButton")

    onClickFunction = onClickFunction or function() end

    buttonFrame.Name = "ButtonObj"
    buttonFrame.Parent = bottomFrame
    buttonFrame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Position = UDim2.new(0, 0, 0.017, 0)
    buttonFrame.Size = UDim2.new(0, 203, 0, 36)

    button.Name = "Button"
    button.Parent = buttonFrame
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 203, 0, 36)
    button.Font = Enum.Font.Gotham
    button.Text = "  " .. tostring(label) or ""
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.TextXAlignment = Enum.TextXAlignment.Left

    button.MouseEnter:Connect(function()
        Services.TweenService:Create(
            buttonFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}
        ):Play()
    end)

    button.MouseLeave:Connect(function()
        Services.TweenService:Create(
            buttonFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundColor3 = Color3.fromRGB(43, 43, 43)}
        ):Play()
    end)

    button.MouseButton1Click:Connect(function()
        spawn(function()
            ClickEffect(button)
        end)
        onClickFunction()
    end)
end
function LibraryWindow:Toggle(label, flagName, initialState, callback, flags)
    flags = flags or Functions.flags
    flagName = flagName or Services.HttpService:GenerateGUID()
    initialState = initialState or false
    callback = callback or function() end

    flags[flagName] = initialState

    local toggleFrame = Instance.new("Frame")
    local toggleTextButton = Instance.new("TextButton")
    local statusIndicator = Instance.new("Frame")
    local corner = Instance.new("UICorner")

    toggleFrame.Name = "ToggleObj"
    toggleFrame.Parent = bottomFrame
    toggleFrame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Position = UDim2.new(0, 0, 0.017, 0)
    toggleFrame.Size = UDim2.new(0, 203, 0, 36)

    toggleTextButton.Name = "ToggleText"
    toggleTextButton.Parent = toggleFrame
    toggleTextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleTextButton.BackgroundTransparency = 1
    toggleTextButton.BorderSizePixel = 0
    toggleTextButton.Size = UDim2.new(0, 203, 0, 36)
    toggleTextButton.Font = Enum.Font.Gotham
    toggleTextButton.Text = "  " .. tostring(label) or ""
    toggleTextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleTextButton.TextSize = 14
    toggleTextButton.TextXAlignment = Enum.TextXAlignment.Left

    statusIndicator.Name = "ToggleStatus"
    statusIndicator.Parent = toggleFrame
    statusIndicator.AnchorPoint = Vector2.new(0, 0.5)
    statusIndicator.BackgroundColor3 = initialState and Color3.fromRGB(14, 255, 110) or Color3.fromRGB(255, 44, 44)
    statusIndicator.BorderSizePixel = 0
    statusIndicator.Position = UDim2.new(0.847, 0, 0.5, 0)
    statusIndicator.Size = UDim2.new(0, 24, 0, 24)
    
    corner.CornerRadius = UDim.new(0, 4)
    corner.Name = "ToggleStatusRound"
    corner.Parent = statusIndicator

    if initialState then
        callback(true)
    end

    toggleTextButton.MouseEnter:Connect(function()
        Services.TweenService:Create(
            toggleFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}
        ):Play()
    end)

    toggleTextButton.MouseLeave:Connect(function()
        Services.TweenService:Create(
            toggleFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundColor3 = Color3.fromRGB(43, 43, 43)}
        ):Play()
    end)

    toggleTextButton.MouseButton1Click:Connect(function()
        flags[flagName] = not flags[flagName]
        
        spawn(function()
            Services.TweenService:Create(
                statusIndicator,
                TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {BackgroundColor3 = flags[flagName] and Color3.fromRGB(14, 255, 110) or Color3.fromRGB(255, 44, 44)}
            ):Play()
        end)

        spawn(function()
            ClickEffect(toggleTextButton)
        end)

        callback(flags[flagName])
    end)
end
function Functions:Slider(label, minValue, maxValue, initialValue, callback, flags)
    local minValue = minValue or 0
    local maxValue = maxValue or 100
    local initialValue = initialValue or minValue
    local callback = callback or function() end 
    local flags = flags or Functions.flags
    local flagName = Services.HttpService:GenerateGUID()
    local isSliding = false

    flags[flagName] = initialValue

    local sliderFrame = Instance.new("Frame")
    local labelTextButton = Instance.new("TextButton")
    local sliderBackground = Instance.new("Frame")
    local sliderPart = Instance.new("Frame")
    local sliderCorner = Instance.new("UICorner")
    local valueLabel = Instance.new("TextLabel")
    local sliderPartCorner = Instance.new("UICorner")

    sliderFrame.Name = "SliderObj"
    sliderFrame.Parent = bottomFrame
    sliderFrame.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Position = UDim2.new(0, 0, 0.017, 0)
    sliderFrame.Size = UDim2.new(0, 203, 0, 36)

    labelTextButton.Name = "SliderText"
    labelTextButton.Parent = sliderFrame
    labelTextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    labelTextButton.BackgroundTransparency = 1
    labelTextButton.BorderSizePixel = 0
    labelTextButton.Size = UDim2.new(0, 203, 0, 36)
    labelTextButton.Font = Enum.Font.Gotham
    labelTextButton.Text = "  " .. tostring(label) or ""
    labelTextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelTextButton.TextSize = 14
    labelTextButton.TextXAlignment = Enum.TextXAlignment.Left

    sliderBackground.Name = "SliderBack"
    sliderBackground.Parent = sliderFrame
    sliderBackground.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Position = UDim2.new(0.571, 0, 0.68, 0)
    sliderBackground.Size = UDim2.new(0, 80, 0, 7)

    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Name = "SliderBackRound"
    sliderCorner.Parent = sliderBackground

    sliderPart.Name = "SliderPart"
    sliderPart.Parent = sliderBackground
    sliderPart.BackgroundColor3 = Color3.fromRGB(131, 133, 255)
    sliderPart.BorderSizePixel = 0
    sliderPart.Size = UDim2.new((initialValue - minValue) / (maxValue - minValue), 0, 1, 0)

    sliderPartCorner.CornerRadius = UDim.new(0, 4)
    sliderPartCorner.Name = "SliderPartRound"
    sliderPartCorner.Parent = sliderPart

    valueLabel.Name = "SliderValue"
    valueLabel.Parent = sliderFrame
    valueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.BackgroundTransparency = 1
    valueLabel.BorderSizePixel = 0
    valueLabel.Position = UDim2.new(0.571, 0, 0.167, 0)
    valueLabel.Size = UDim2.new(0, 80, 0, 16)
    valueLabel.Font = Enum.Font.Code
    valueLabel.Text = tostring(initialValue)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14

    if initialValue and initialValue ~= minValue then
        callback(initialValue)
    end

    local function updateSliderPosition(input)
        local position = UDim2.new(math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1), 0, 1, 0)
        sliderPart:TweenSize(position, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.05, true)
        local newValue = math.floor(position.X.Scale * (maxValue - minValue) + minValue)
        valueLabel.Text = tostring(newValue)
        flags[flagName] = newValue
        callback(newValue)
    end

    labelTextButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            spawn(function()
                Services.TweenService:Create(sliderPart, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end)
            updateSliderPosition(input)
            isSliding = true
        end
    end)

    labelTextButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            spawn(function()
                Services.TweenService:Create(sliderPart, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(131, 133, 255)}):Play()
            end)
            isSliding = false
        end
    end)

    Services.InputChanged:Connect(function(input)
        if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSliderPosition(input)
        end
    end)
end
return Functions
end
return Library
