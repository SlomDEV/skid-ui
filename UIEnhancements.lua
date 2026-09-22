-- Integrated UI enhancement for Library.lua (3).txt.
-- Load this once after the library has been loaded; it wraps library:window
-- so every subsequently-created window gets the drag handle and toggle.

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function create(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    return object
end

local function attach(library, window)
    if not window or not window.items or not window.items.main then
        return window
    end

    local main = window.items.main
    local accent = Color3.fromRGB(155, 150, 219)
    local dragging = false
    local dragStart
    local startPosition

    local handle = create("TextButton", {
        Name = "IntegratedDragHandle",
        Parent = main,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 28),
        ZIndex = 20,
    })

    handle.InputBegan:Connect(function(input)
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
        local x = math.clamp(startPosition.X.Offset + delta.X, 0, math.max(0, viewport.X - main.AbsoluteSize.X))
        local y = math.clamp(startPosition.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - main.AbsoluteSize.Y))
        main.Position = UDim2.fromOffset(x, y)
    end)

    local toggleGui = create("ScreenGui", {
        Name = "MileniumIntegratedToggle",
        Parent = CoreGui,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    })

    local toggle = create("TextButton", {
        Name = "ShowHide",
        Parent = toggleGui,
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(34, 24),
        BackgroundColor3 = Color3.fromRGB(14, 14, 16),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "≡",
        TextColor3 = accent,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 100,
    })

    create("UICorner", {Parent = toggle, CornerRadius = UDim.new(0, 6)})
    create("UIStroke", {Parent = toggle, Color = Color3.fromRGB(23, 23, 29), Thickness = 1})

    local visible = true
    toggle.Activated:Connect(function()
        visible = not visible
        library.items.Enabled = visible
        toggle.Text = visible and "≡" or "▸"
    end)

    if library.apply_theme then
        library:apply_theme(toggle, "accent", "TextColor3")
    end

    window.toggle_gui = toggleGui
    return window
end

local function integrate(library)
    assert(library and library.window, "A loaded library is required")
    if library.__ui_enhancements_integrated then
        return library
    end

    local originalWindow = library.window
    library.window = function(self, properties)
        return attach(self, originalWindow(self, properties))
    end
    library.__ui_enhancements_integrated = true
    return library
end

return {
    attach = attach,
    integrate = integrate,
}
