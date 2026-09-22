-- UI enhancements for the Milenium library.
-- Usage after creating a window:
--     local toggle = require(...)
--     toggle.attach(library, window)
--
-- This module is intentionally self-contained so it can be copied into the
-- library without changing the existing control definitions.

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local M = {}

local function make(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    return object
end

function M.attach(library, window)
    assert(window and window.items and window.items.main, "attach expects a library window")

    local main = window.items.main
    local accent = Color3.fromRGB(155, 150, 219)
    local background = Color3.fromRGB(14, 14, 16)
    local border = Color3.fromRGB(23, 23, 29)

    -- The existing window is draggable, but this input layer also keeps the
    -- drag behavior available while the main frame is covered by controls.
    local dragHandle = make("TextButton", {
        Name = "DragHandle",
        Parent = main,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 28),
        ZIndex = 20,
    })

    local dragging = false
    local dragStart
    local startPosition

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - dragStart
        local viewport = workspace.CurrentCamera.ViewportSize
        local x = math.clamp(startPosition.X.Offset + delta.X, 0, viewport.X - main.AbsoluteSize.X)
        local y = math.clamp(startPosition.Y.Offset + delta.Y, 0, viewport.Y - main.AbsoluteSize.Y)
        main.Position = UDim2.fromOffset(x, y)
    end)

    -- A compact, vertically-low/horizontally-high button in the top-left.
    -- It remains visible when the main UI is hidden so the UI can be restored.
    local toggleGui = make("ScreenGui", {
        Name = "MileniumToggle",
        Parent = CoreGui,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
    })

    local toggle = make("TextButton", {
        Name = "ToggleButton",
        Parent = toggleGui,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(34, 24),
        BackgroundColor3 = background,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "≡",
        TextColor3 = accent,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 100,
    })

    make("UICorner", {Parent = toggle, CornerRadius = UDim.new(0, 6)})
    make("UIStroke", {Parent = toggle, Color = border, Thickness = 1})

    local visible = true
    toggle.Activated:Connect(function()
        visible = not visible
        library.items.Enabled = visible
        toggle.Text = visible and "≡" or "▸"
    end)

    -- Keep the toggle in the theme when the library changes its accent.
    if library.apply_theme then
        library:apply_theme(toggle, "accent", "TextColor3")
    end

    return toggleGui
end

return M
