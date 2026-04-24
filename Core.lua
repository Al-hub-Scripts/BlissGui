-- ============================================================
--   AETHER UI LIBRARY  ·  Core.lua  ·  v1.0
--   Theme system · Instance utilities · Animation helpers
-- ============================================================

local Core = {}
Core.__index = Core

-- ── Services ─────────────────────────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

-- ── Theme Definitions ─────────────────────────────────────────
Core.Themes = {

    -- Dark amber / terminal-gold (matches screenshot aesthetic)
    Ember = {
        BG          = Color3.fromRGB(13, 13, 16),
        Surface     = Color3.fromRGB(20, 20, 26),
        SurfaceHigh = Color3.fromRGB(30, 30, 40),
        Border      = Color3.fromRGB(42, 42, 58),
        BorderHigh  = Color3.fromRGB(68, 68, 90),
        Accent      = Color3.fromRGB(185, 147, 82),
        AccentDark  = Color3.fromRGB(105, 82, 42),
        AccentText  = Color3.fromRGB(255, 210, 128),
        Success     = Color3.fromRGB(68, 190, 118),
        Warning     = Color3.fromRGB(235, 172, 50),
        Error       = Color3.fromRGB(210, 65, 65),
        Info        = Color3.fromRGB(90, 162, 245),
        Text        = Color3.fromRGB(232, 228, 218),
        TextSub     = Color3.fromRGB(155, 150, 138),
        TextDim     = Color3.fromRGB(82, 80, 72),
        Scrollbar   = Color3.fromRGB(55, 55, 72),
        ToggleON    = Color3.fromRGB(185, 147, 82),
        ToggleOFF   = Color3.fromRGB(42, 42, 58),
        SliderFill  = Color3.fromRGB(185, 147, 82),
        SliderTrack = Color3.fromRGB(35, 35, 50),
    },

    -- Deep navy / electric blue
    Dusk = {
        BG          = Color3.fromRGB(10, 12, 20),
        Surface     = Color3.fromRGB(16, 18, 32),
        SurfaceHigh = Color3.fromRGB(24, 27, 48),
        Border      = Color3.fromRGB(38, 42, 70),
        BorderHigh  = Color3.fromRGB(62, 68, 115),
        Accent      = Color3.fromRGB(108, 152, 235),
        AccentDark  = Color3.fromRGB(62, 95, 168),
        AccentText  = Color3.fromRGB(162, 198, 255),
        Success     = Color3.fromRGB(68, 200, 130),
        Warning     = Color3.fromRGB(235, 172, 50),
        Error       = Color3.fromRGB(212, 72, 72),
        Info        = Color3.fromRGB(90, 165, 250),
        Text        = Color3.fromRGB(215, 218, 238),
        TextSub     = Color3.fromRGB(128, 132, 162),
        TextDim     = Color3.fromRGB(72, 76, 112),
        Scrollbar   = Color3.fromRGB(45, 50, 85),
        ToggleON    = Color3.fromRGB(108, 152, 235),
        ToggleOFF   = Color3.fromRGB(38, 42, 70),
        SliderFill  = Color3.fromRGB(108, 152, 235),
        SliderTrack = Color3.fromRGB(22, 25, 44),
    },

    -- Void black / rose pink
    Sakura = {
        BG          = Color3.fromRGB(16, 11, 16),
        Surface     = Color3.fromRGB(26, 18, 26),
        SurfaceHigh = Color3.fromRGB(38, 26, 38),
        Border      = Color3.fromRGB(68, 42, 65),
        BorderHigh  = Color3.fromRGB(110, 66, 102),
        Accent      = Color3.fromRGB(220, 110, 148),
        AccentDark  = Color3.fromRGB(145, 65, 95),
        AccentText  = Color3.fromRGB(255, 168, 200),
        Success     = Color3.fromRGB(68, 192, 128),
        Warning     = Color3.fromRGB(235, 172, 55),
        Error       = Color3.fromRGB(212, 72, 72),
        Info        = Color3.fromRGB(100, 168, 252),
        Text        = Color3.fromRGB(238, 218, 230),
        TextSub     = Color3.fromRGB(155, 118, 142),
        TextDim     = Color3.fromRGB(92, 65, 84),
        Scrollbar   = Color3.fromRGB(75, 46, 70),
        ToggleON    = Color3.fromRGB(220, 110, 148),
        ToggleOFF   = Color3.fromRGB(68, 42, 65),
        SliderFill  = Color3.fromRGB(220, 110, 148),
        SliderTrack = Color3.fromRGB(28, 18, 26),
    },

    -- Forest green / muted ivory
    Forest = {
        BG          = Color3.fromRGB(11, 15, 12),
        Surface     = Color3.fromRGB(17, 23, 19),
        SurfaceHigh = Color3.fromRGB(26, 35, 28),
        Border      = Color3.fromRGB(40, 58, 44),
        BorderHigh  = Color3.fromRGB(64, 96, 70),
        Accent      = Color3.fromRGB(112, 190, 130),
        AccentDark  = Color3.fromRGB(62, 118, 78),
        AccentText  = Color3.fromRGB(168, 230, 185),
        Success     = Color3.fromRGB(80, 205, 128),
        Warning     = Color3.fromRGB(235, 180, 55),
        Error       = Color3.fromRGB(215, 72, 72),
        Info        = Color3.fromRGB(95, 170, 250),
        Text        = Color3.fromRGB(218, 228, 215),
        TextSub     = Color3.fromRGB(135, 158, 138),
        TextDim     = Color3.fromRGB(75, 95, 78),
        Scrollbar   = Color3.fromRGB(45, 68, 50),
        ToggleON    = Color3.fromRGB(112, 190, 130),
        ToggleOFF   = Color3.fromRGB(40, 58, 44),
        SliderFill  = Color3.fromRGB(112, 190, 130),
        SliderTrack = Color3.fromRGB(17, 25, 19),
    },
}

-- ── Global Config ─────────────────────────────────────────────
Core.Config = {
    Theme     = "Ember",
    AnimSpeed = 0.22,
    SlowAnim  = 0.48,
    FastAnim  = 0.12,
    Font      = Enum.Font.GothamMedium,
    FontBold  = Enum.Font.GothamBold,
    FontMono  = Enum.Font.RobotoMono,
    CornerLG  = UDim.new(0, 8),
    CornerMD  = UDim.new(0, 5),
    CornerSM  = UDim.new(0, 3),
    CornerRound = UDim.new(1, 0),
}

-- ── Theme Accessor ─────────────────────────────────────────────
function Core:T()
    return self.Themes[self.Config.Theme] or self.Themes.Ember
end

-- ── Tween Helper ──────────────────────────────────────────────
function Core:Tween(obj, props, t, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(
        t      or self.Config.AnimSpeed,
        style  or Enum.EasingStyle.Quart,
        dir    or Enum.EasingDirection.Out
    ), props)
    tw:Play()
    return tw
end

-- ── Instance Creator ──────────────────────────────────────────
function Core:New(class, props)
    local obj = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            pcall(function() obj[k] = v end)
        end
    end
    if parent then obj.Parent = parent end
    return obj
end

-- ── Corner ────────────────────────────────────────────────────
function Core:Corner(p, r)
    return self:New("UICorner", { CornerRadius = r or self.Config.CornerMD, Parent = p })
end

-- ── Stroke ────────────────────────────────────────────────────
function Core:Stroke(p, color, thick, trans)
    return self:New("UIStroke", {
        Color        = color or self:T().Border,
        Thickness    = thick or 1,
        Transparency = trans or 0,
        Parent       = p,
    })
end

-- ── Padding ───────────────────────────────────────────────────
function Core:Pad(p, t, b, l, r)
    return self:New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft   = UDim.new(0, l or 8),
        PaddingRight  = UDim.new(0, r or 8),
        Parent        = p,
    })
end

-- ── List Layout ───────────────────────────────────────────────
function Core:List(p, dir, space, ha, va)
    return self:New("UIListLayout", {
        FillDirection       = dir   or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, space or 6),
        HorizontalAlignment = ha    or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va    or Enum.VerticalAlignment.Top,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = p,
    })
end

-- ── Grid Layout ───────────────────────────────────────────────
function Core:Grid(p, cellSize, padding)
    return self:New("UIGridLayout", {
        CellSize        = cellSize  or UDim2.new(0.5, -5, 0, 72),
        CellPaddingSize = padding   or UDim2.new(0, 6, 0, 6),
        SortOrder       = Enum.SortOrder.LayoutOrder,
        Parent          = p,
    })
end

-- ── Size Constraint ───────────────────────────────────────────
function Core:SizeConst(p, min, max)
    return self:New("UISizeConstraint", {
        MinSize = min or Vector2.new(0, 0),
        MaxSize = max or Vector2.new(math.huge, math.huge),
        Parent  = p,
    })
end

-- ── Ripple Click Effect ───────────────────────────────────────
function Core:Ripple(btn, zi)
    btn.ClipsDescendants = true
    btn.MouseButton1Click:Connect(function()
        local rip = self:New("Frame", {
            Size                 = UDim2.new(0, 0, 0, 0),
            Position             = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint          = Vector2.new(0.5, 0.5),
            BackgroundColor3     = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.78,
            ZIndex               = (zi or btn.ZIndex) + 8,
            Parent               = btn,
        })
        self:Corner(rip, self.Config.CornerRound)
        local sz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 3
        self:Tween(rip, { Size = UDim2.new(0,sz,0,sz), BackgroundTransparency = 1 }, 0.48, Enum.EasingStyle.Quad)
        task.delay(0.5, function() rip:Destroy() end)
    end)
end

-- ── Hover Color Effect ────────────────────────────────────────
function Core:Hover(frame, norm, hov, prop)
    prop = prop or "BackgroundColor3"
    frame.MouseEnter:Connect(function()
        self:Tween(frame, { [prop] = hov }, self.Config.FastAnim)
    end)
    frame.MouseLeave:Connect(function()
        self:Tween(frame, { [prop] = norm }, self.Config.FastAnim)
    end)
end

-- ── Draggable Window ──────────────────────────────────────────
function Core:MakeDraggable(win, handle)
    local dragging, startMouse, startWin = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging   = true
            startMouse = inp.Position
            startWin   = win.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - startMouse
            win.Position = UDim2.new(
                startWin.X.Scale, startWin.X.Offset + d.X,
                startWin.Y.Scale, startWin.Y.Offset + d.Y
            )
        end
    end)
end

-- ── Resizable Window ──────────────────────────────────────────
function Core:MakeResizable(win, handle, minSz, maxSz)
    minSz = minSz or Vector2.new(400, 300)
    maxSz = maxSz or Vector2.new(960, 720)
    local resizing, startMouse, startSz = false, nil, nil

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing   = true
            startMouse = inp.Position
            startSz    = win.AbsoluteSize
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    UserInputService.MouseIcon = ""
                end
            end)
        end
    end)
    handle.MouseEnter:Connect(function()
        UserInputService.MouseIcon = "rbxasset://SystemCursors/SizeNWSE"
    end)
    handle.MouseLeave:Connect(function()
        if not resizing then UserInputService.MouseIcon = "" end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d  = inp.Position - startMouse
            local nW = math.clamp(startSz.X + d.X, minSz.X, maxSz.X)
            local nH = math.clamp(startSz.Y + d.Y, minSz.Y, maxSz.Y)
            win.Size = UDim2.new(0, nW, 0, nH)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            UserInputService.MouseIcon = ""
        end
    end)
end

-- ── Gradient Frame ────────────────────────────────────────────
function Core:Gradient(p, c0, c1, rotation)
    local grad = self:New("UIGradient", {
        Color    = ColorSequence.new(c0, c1),
        Rotation = rotation or 0,
        Parent   = p,
    })
    return grad
end

-- ── Type-color utility ────────────────────────────────────────
function Core:TypeColor(t)
    local T = self:T()
    return ({
        success = T.Success,
        error   = T.Error,
        warning = T.Warning,
        info    = T.Info,
    })[t:lower()] or T.Info
end

return Core
