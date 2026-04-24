-- ============================================================
--   AETHER UI LIBRARY  ·  Elements.lua  ·  v1.0
--   Button · Toggle · Slider · Dropdown · TextInput
--   Keybind · ColorPicker · Label · Separator · Paragraph
-- ============================================================

local Elements = {}

-- ── Inject: patches all element methods onto a sectionAPI ─────
function Elements.Inject(Core, secAPI)
    local C = Core

    -- ┌─────────────────────────────────────────────────────┐
    -- │  BUTTON                                              │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddButton(opts)
        opts = opts or {}
        local T   = C:T()
        local lo  = self:_lo()
        local title = opts.Title or opts.Name or "Button"
        local desc  = opts.Description or opts.Desc or ""

        local frame = C:New("Frame", {
            Name             = "Btn_" .. title,
            Size             = UDim2.new(1, 0, 0, desc ~= "" and 56 or 38),
            BackgroundColor3 = T.SurfaceHigh,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)

        -- Hover + ripple host
        local btn = C:New("TextButton", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = "",
            ZIndex               = 6,
            Parent               = frame,
        })
        C:Ripple(btn, 6)

        -- Accent left stripe
        local stripe = C:New("Frame", {
            Size             = UDim2.new(0, 3, 0.5, 0),
            Position         = UDim2.new(0, 0, 0.25, 0),
            BackgroundColor3 = T.Accent,
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = frame,
        })
        C:Corner(stripe, UDim.new(1, 0))

        C:New("TextLabel", {
            Size                 = UDim2.new(1, -56, 0, 20),
            Position             = UDim2.new(0, 14, 0, desc ~= "" and 9 or 9),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = frame,
        })

        if desc ~= "" then
            C:New("TextLabel", {
                Size                 = UDim2.new(1, -56, 0, 16),
                Position             = UDim2.new(0, 14, 0, 31),
                BackgroundTransparency = 1,
                Text                 = desc,
                TextColor3           = T.TextSub,
                Font                 = C.Config.Font,
                TextSize             = 11,
                TextXAlignment       = Enum.TextXAlignment.Left,
                ZIndex               = 6,
                Parent               = frame,
            })
        end

        -- Arrow icon
        C:New("TextLabel", {
            Size                 = UDim2.new(0, 30, 1, 0),
            Position             = UDim2.new(1, -34, 0, 0),
            BackgroundTransparency = 1,
            Text                 = "›",
            TextColor3           = T.TextDim,
            Font                 = C.Config.FontBold,
            TextSize             = 18,
            ZIndex               = 6,
            Parent               = frame,
        })

        C:Hover(frame, T.SurfaceHigh, T.BorderHigh)

        btn.MouseButton1Click:Connect(function()
            if opts.Callback then pcall(opts.Callback) end
        end)

        self:_reg(title, frame)
        return { Frame = frame, Button = btn }
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  TOGGLE                                              │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddToggle(opts)
        opts = opts or {}
        local T     = C:T()
        local lo    = self:_lo()
        local title = opts.Title or opts.Name or "Toggle"
        local desc  = opts.Description or opts.Desc or ""
        local state = opts.Default ~= nil and opts.Default or false

        local frame = C:New("Frame", {
            Name             = "Tog_" .. title,
            Size             = UDim2.new(1, 0, 0, desc ~= "" and 56 or 38),
            BackgroundColor3 = T.SurfaceHigh,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)

        C:New("TextLabel", {
            Size                 = UDim2.new(1, -62, 0, 20),
            Position             = UDim2.new(0, 12, 0, desc ~= "" and 9 or 9),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = frame,
        })

        if desc ~= "" then
            C:New("TextLabel", {
                Size                 = UDim2.new(1, -62, 0, 16),
                Position             = UDim2.new(0, 12, 0, 31),
                BackgroundTransparency = 1,
                Text                 = desc,
                TextColor3           = T.TextSub,
                Font                 = C.Config.Font,
                TextSize             = 11,
                TextXAlignment       = Enum.TextXAlignment.Left,
                ZIndex               = 6,
                Parent               = frame,
            })
        end

        -- Track
        local track = C:New("Frame", {
            Size             = UDim2.new(0, 40, 0, 22),
            Position         = UDim2.new(1, -52, 0.5, -11),
            BackgroundColor3 = state and T.ToggleON or T.ToggleOFF,
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = frame,
        })
        C:Corner(track, C.Config.CornerRound)
        C:Stroke(track, T.Border, 1)

        -- Thumb
        local thumb = C:New("Frame", {
            Size             = UDim2.new(0, 16, 0, 16),
            Position         = state and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 7,
            Parent           = track,
        })
        C:Corner(thumb, C.Config.CornerRound)

        local hitbox = C:New("TextButton", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = "",
            ZIndex               = 8,
            Parent               = frame,
        })

        local function setState(v, callback)
            state = v
            C:Tween(track, { BackgroundColor3 = state and T.ToggleON or T.ToggleOFF }, 0.22)
            C:Tween(thumb, { Position         = state and UDim2.new(0,21,0.5,-8) or UDim2.new(0,3,0.5,-8) }, 0.22)
            if callback ~= false and opts.Callback then pcall(opts.Callback, state) end
        end

        hitbox.MouseButton1Click:Connect(function()
            setState(not state)
        end)

        C:Hover(frame, T.SurfaceHigh, T.BorderHigh)

        self:_reg(title, frame)

        local api = { Value = state, Frame = frame }
        function api:Set(v) setState(v, false); self.Value = v end
        function api:Get() return state end
        return api
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  SLIDER                                              │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddSlider(opts)
        opts = opts or {}
        local T     = C:T()
        local lo    = self:_lo()
        local title = opts.Title or opts.Name or "Slider"
        local min   = opts.Min   or 0
        local max   = opts.Max   or 100
        local def   = opts.Default or min
        local suffix = opts.Suffix or ""
        local current = math.clamp(def, min, max)

        local frame = C:New("Frame", {
            Name             = "Sld_" .. title,
            Size             = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = T.SurfaceHigh,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)

        C:New("TextLabel", {
            Size                 = UDim2.new(1, -80, 0, 20),
            Position             = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = frame,
        })

        local valLbl = C:New("TextLabel", {
            Size                 = UDim2.new(0, 72, 0, 20),
            Position             = UDim2.new(1, -84, 0, 8),
            BackgroundTransparency = 1,
            Text                 = tostring(current) .. suffix,
            TextColor3           = T.AccentText,
            Font                 = C.Config.FontMono,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Right,
            ZIndex               = 6,
            Parent               = frame,
        })

        -- Track background
        local track = C:New("Frame", {
            Size             = UDim2.new(1, -24, 0, 6),
            Position         = UDim2.new(0, 12, 0, 38),
            BackgroundColor3 = T.SliderTrack,
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = frame,
        })
        C:Corner(track, C.Config.CornerRound)

        -- Fill bar
        local pct  = (current - min) / (max - min)
        local fill = C:New("Frame", {
            Size             = UDim2.new(pct, 0, 1, 0),
            BackgroundColor3 = T.SliderFill,
            BorderSizePixel  = 0,
            ZIndex           = 7,
            Parent           = track,
        })
        C:Corner(fill, C.Config.CornerRound)

        -- Thumb dot
        local thumb = C:New("Frame", {
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = UDim2.new(pct, -7, 0.5, -7),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel  = 0,
            ZIndex           = 8,
            Parent           = track,
        })
        C:Corner(thumb, C.Config.CornerRound)

        local UserInputService = game:GetService("UserInputService")
        local dragging = false

        local function updateSlider(inputX)
            local tX  = track.AbsolutePosition.X
            local tW  = track.AbsoluteSize.X
            local p   = math.clamp((inputX - tX) / tW, 0, 1)
            local raw = min + p * (max - min)
            current   = opts.Integer and math.round(raw) or math.floor(raw * 100 + 0.5) / 100
            local fp  = (current - min) / (max - min)
            fill.Size      = UDim2.new(fp, 0, 1, 0)
            thumb.Position = UDim2.new(fp, -7, 0.5, -7)
            valLbl.Text    = tostring(current) .. suffix
            if opts.Callback then pcall(opts.Callback, current) end
        end

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(inp.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(inp.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        C:Hover(frame, T.SurfaceHigh, T.BorderHigh)
        self:_reg(title, frame)

        local api = { Value = current, Frame = frame }
        function api:Set(v)
            current   = math.clamp(v, min, max)
            local fp  = (current - min) / (max - min)
            fill.Size      = UDim2.new(fp, 0, 1, 0)
            thumb.Position = UDim2.new(fp, -7, 0.5, -7)
            valLbl.Text    = tostring(current) .. suffix
            self.Value     = current
        end
        function api:Get() return current end
        return api
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  DROPDOWN                                            │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddDropdown(opts)
        opts = opts or {}
        local T       = C:T()
        local lo      = self:_lo()
        local title   = opts.Title or opts.Name or "Dropdown"
        local options = opts.Options or {}
        local multi   = opts.Multi or false
        local selected = opts.Default and { [opts.Default] = true } or {}
        local expanded = false

        local frame = C:New("Frame", {
            Name             = "DD_" .. title,
            Size             = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = T.SurfaceHigh,
            ClipsDescendants = false,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 6,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)

        -- Header
        local header = C:New("TextButton", {
            Size                 = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text                 = "",
            ZIndex               = 7,
            Parent               = frame,
        })

        C:New("TextLabel", {
            Size                 = UDim2.new(1, -52, 1, 0),
            Position             = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 7,
            Parent               = header,
        })

        local selLbl = C:New("TextLabel", {
            Size                 = UDim2.new(0, 100, 1, 0),
            Position             = UDim2.new(1, -120, 0, 0),
            BackgroundTransparency = 1,
            Text                 = opts.Default or "None",
            TextColor3           = T.AccentText,
            Font                 = C.Config.Font,
            TextSize             = 12,
            TextXAlignment       = Enum.TextXAlignment.Right,
            ZIndex               = 7,
            Parent               = header,
        })

        local arrow = C:New("TextLabel", {
            Size                 = UDim2.new(0, 24, 1, 0),
            Position             = UDim2.new(1, -28, 0, 0),
            BackgroundTransparency = 1,
            Text                 = "▾",
            TextColor3           = T.TextDim,
            Font                 = C.Config.FontBold,
            TextSize             = 13,
            ZIndex               = 7,
            Parent               = header,
        })

        -- Dropdown list container
        local listFrame = C:New("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            Position         = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
            ZIndex           = 15,
            Parent           = frame,
        })
        C:Corner(listFrame, C.Config.CornerSM)
        C:Stroke(listFrame, T.Border, 1)

        local listScroll = C:New("ScrollingFrame", {
            Size                    = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency  = 1,
            BorderSizePixel         = 0,
            ScrollBarThickness      = 3,
            ScrollBarImageColor3    = T.Scrollbar,
            CanvasSize              = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize     = Enum.AutomaticSize.Y,
            ZIndex                  = 16,
            Parent                  = listFrame,
        })
        C:List(listScroll, Enum.FillDirection.Vertical, 2)
        C:Pad(listScroll, 4, 4, 4, 4)

        local function updateLabel()
            local keys = {}
            for k in pairs(selected) do table.insert(keys, k) end
            selLbl.Text = #keys == 0 and "None" or (multi and table.concat(keys, ", ") or keys[1])
        end

        -- Build option rows
        for _, opt in ipairs(options) do
            local row = C:New("TextButton", {
                Size             = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = T.SurfaceHigh,
                BackgroundTransparency = 1,
                Text             = "",
                BorderSizePixel  = 0,
                AutoButtonColor  = false,
                ZIndex           = 17,
                Parent           = listScroll,
            })
            C:Corner(row, C.Config.CornerSM)

            local check = C:New("TextLabel", {
                Size                 = UDim2.new(0, 18, 1, 0),
                Position             = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text                 = selected[opt] and "✓" or " ",
                TextColor3           = T.Accent,
                Font                 = C.Config.FontBold,
                TextSize             = 13,
                ZIndex               = 17,
                Parent               = row,
            })

            C:New("TextLabel", {
                Size                 = UDim2.new(1, -28, 1, 0),
                Position             = UDim2.new(0, 26, 0, 0),
                BackgroundTransparency = 1,
                Text                 = opt,
                TextColor3           = T.Text,
                Font                 = C.Config.Font,
                TextSize             = 13,
                TextXAlignment       = Enum.TextXAlignment.Left,
                ZIndex               = 17,
                Parent               = row,
            })

            C:Hover(row, T.SurfaceHigh, T.BorderHigh)

            row.MouseButton1Click:Connect(function()
                if multi then
                    selected[opt] = not selected[opt] or nil
                else
                    selected = { [opt] = true }
                end
                check.Text = selected[opt] and "✓" or " "
                updateLabel()
                if opts.Callback then
                    local keys = {}
                    for k in pairs(selected) do table.insert(keys, k) end
                    pcall(opts.Callback, multi and keys or keys[1])
                end
            end)
        end

        local maxH = math.min(#options * 34 + 8, 160)

        header.MouseButton1Click:Connect(function()
            expanded = not expanded
            C:Tween(frame,     { Size = UDim2.new(1, 0, 0, expanded and 40 + maxH + 4 or 40) }, 0.24, Enum.EasingStyle.Quart)
            C:Tween(listFrame, { Size = UDim2.new(1, 0, 0, expanded and maxH or 0)            }, 0.24, Enum.EasingStyle.Quart)
            C:Tween(arrow,     { Rotation = expanded and 180 or 0 }                            , 0.22)
        end)

        C:Hover(frame, T.SurfaceHigh, T.BorderHigh)
        self:_reg(title, frame)

        local api = { Selected = selected, Frame = frame }
        function api:Set(v)
            selected = type(v) == "table" and v or { [v] = true }
            updateLabel()
        end
        function api:Get()
            local keys = {}
            for k in pairs(selected) do table.insert(keys, k) end
            return multi and keys or keys[1]
        end
        return api
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  TEXT INPUT                                          │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddTextInput(opts)
        opts = opts or {}
        local T     = C:T()
        local lo    = self:_lo()
        local title = opts.Title or opts.Name or "Input"

        local frame = C:New("Frame", {
            Name             = "TI_" .. title,
            Size             = UDim2.new(1, 0, 0, 64),
            BackgroundColor3 = T.SurfaceHigh,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)

        C:New("TextLabel", {
            Size                 = UDim2.new(1, -12, 0, 20),
            Position             = UDim2.new(0, 12, 0, 7),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = frame,
        })

        local inputBG = C:New("Frame", {
            Size             = UDim2.new(1, -22, 0, 24),
            Position         = UDim2.new(0, 11, 0, 30),
            BackgroundColor3 = T.BG,
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = frame,
        })
        C:Corner(inputBG, C.Config.CornerSM)
        local stroke = C:Stroke(inputBG, T.Border, 1)

        local box = C:New("TextBox", {
            Size                 = UDim2.new(1, -16, 1, 0),
            Position             = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text                 = opts.Default or "",
            PlaceholderText      = opts.Placeholder or "Enter text...",
            PlaceholderColor3    = T.TextDim,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 12,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ClearTextOnFocus     = opts.ClearOnFocus ~= nil and opts.ClearOnFocus or false,
            ZIndex               = 7,
            Parent               = inputBG,
        })

        box.Focused:Connect(function()
            C:Tween(stroke, { Color = T.Accent }, 0.18)
        end)
        box.FocusLost:Connect(function(enter)
            C:Tween(stroke, { Color = T.Border }, 0.18)
            if opts.Callback then pcall(opts.Callback, box.Text, enter) end
        end)

        C:Hover(frame, T.SurfaceHigh, T.BorderHigh)
        self:_reg(title, frame)

        local api = { Value = box.Text, Frame = frame, Box = box }
        function api:Set(v) box.Text = v; self.Value = v end
        function api:Get() return box.Text end
        return api
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  KEYBIND                                             │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddKeybind(opts)
        opts = opts or {}
        local T       = C:T()
        local lo      = self:_lo()
        local title   = opts.Title or opts.Name or "Keybind"
        local UserInputService = game:GetService("UserInputService")
        local bound   = opts.Default or Enum.KeyCode.Unknown
        local listening = false

        local frame = C:New("Frame", {
            Name             = "KB_" .. title,
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = T.SurfaceHigh,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)

        C:New("TextLabel", {
            Size                 = UDim2.new(1, -110, 1, 0),
            Position             = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = frame,
        })

        local keyBtn = C:New("TextButton", {
            Size             = UDim2.new(0, 90, 0, 24),
            Position         = UDim2.new(1, -100, 0.5, -12),
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            Text             = bound.Name,
            TextColor3       = T.AccentText,
            Font             = C.Config.FontMono,
            TextSize         = 12,
            AutoButtonColor  = false,
            ZIndex           = 6,
            Parent           = frame,
        })
        C:Corner(keyBtn, C.Config.CornerSM)
        C:Stroke(keyBtn, T.Border, 1)

        keyBtn.MouseButton1Click:Connect(function()
            listening   = true
            keyBtn.Text = "..."
            keyBtn.TextColor3 = T.Warning
        end)

        UserInputService.InputBegan:Connect(function(inp, gpe)
            if not listening or gpe then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                bound   = inp.KeyCode
                listening = false
                keyBtn.Text = bound.Name
                keyBtn.TextColor3 = T.AccentText
                if opts.Callback then pcall(opts.Callback, bound) end
            end
        end)

        -- Fire on keypress
        UserInputService.InputBegan:Connect(function(inp, gpe)
            if not gpe and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == bound then
                if opts.Hold then
                    if opts.HoldCallback then pcall(opts.HoldCallback, true) end
                else
                    if opts.FireCallback then pcall(opts.FireCallback) end
                end
            end
        end)

        C:Hover(frame, T.SurfaceHigh, T.BorderHigh)
        self:_reg(title, frame)

        local api = { Key = bound, Frame = frame }
        function api:Set(k) bound = k; keyBtn.Text = k.Name end
        function api:Get() return bound end
        return api
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  COLOR PICKER                                        │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddColorPicker(opts)
        opts = opts or {}
        local T       = C:T()
        local lo      = self:_lo()
        local title   = opts.Title or opts.Name or "Color"
        local current = opts.Default or Color3.fromRGB(255, 100, 100)
        local open    = false

        local frame = C:New("Frame", {
            Name             = "CP_" .. title,
            Size             = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = T.SurfaceHigh,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)

        C:New("TextLabel", {
            Size                 = UDim2.new(1, -62, 1, 0),
            Position             = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.Font,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = frame,
        })

        local swatch = C:New("TextButton", {
            Size             = UDim2.new(0, 36, 0, 22),
            Position         = UDim2.new(1, -46, 0.5, -11),
            BackgroundColor3 = current,
            Text             = "",
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            ZIndex           = 6,
            Parent           = frame,
        })
        C:Corner(swatch, C.Config.CornerSM)
        C:Stroke(swatch, T.Border, 1)

        -- Expanded color panel
        local panel = C:New("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            Position         = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            ClipsDescendants = true,
            ZIndex           = 10,
            Parent           = frame,
        })
        C:Corner(panel, C.Config.CornerSM)
        C:Stroke(panel, T.Border, 1)

        -- Hue slider (simple implementation)
        local hueBar = C:New("Frame", {
            Size             = UDim2.new(1, -20, 0, 16),
            Position         = UDim2.new(0, 10, 0, 10),
            BorderSizePixel  = 0,
            ZIndex           = 11,
            Parent           = panel,
        })
        C:Corner(hueBar, C.Config.CornerSM)
        C:New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,   1, 1)),
                ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17,1, 1)),
                ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1, 1)),
                ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5, 1, 1)),
                ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67,1, 1)),
                ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1, 1)),
                ColorSequenceKeypoint.new(1,   Color3.fromHSV(1,   1, 1)),
            }),
            Rotation = 0,
            Parent = hueBar,
        })

        -- Sat/brightness label (simplified, for full picker see docs)
        local hueH, hueS, hueV = current:ToHSV()
        local hueCursor = C:New("Frame", {
            Size             = UDim2.new(0, 6, 1, 4),
            Position         = UDim2.new(hueH, -3, 0, -2),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel  = 0,
            ZIndex           = 12,
            Parent           = hueBar,
        })
        C:Corner(hueCursor, C.Config.CornerSM)

        -- Hex input
        local hexInput = C:New("TextBox", {
            Size             = UDim2.new(1, -20, 0, 24),
            Position         = UDim2.new(0, 10, 0, 34),
            BackgroundColor3 = T.BG,
            Text             = string.format("#%02X%02X%02X",
                math.round(current.R*255), math.round(current.G*255), math.round(current.B*255)),
            TextColor3       = T.Text,
            Font             = C.Config.FontMono,
            TextSize         = 12,
            BorderSizePixel  = 0,
            ZIndex           = 11,
            Parent           = panel,
        })
        C:Corner(hexInput, C.Config.CornerSM)
        C:Stroke(hexInput, T.Border, 1)
        C:Pad(hexInput, 0, 0, 8, 4)

        local function applyColor(col)
            current = col
            swatch.BackgroundColor3 = col
            hexInput.Text = string.format("#%02X%02X%02X",
                math.round(col.R*255), math.round(col.G*255), math.round(col.B*255))
            if opts.Callback then pcall(opts.Callback, col) end
        end

        -- Hue drag
        local UserInputService = game:GetService("UserInputService")
        local dragging = false
        hueBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local p = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                hueCursor.Position = UDim2.new(p, -3, 0, -2)
                applyColor(Color3.fromHSV(p, 1, 1))
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local p = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                hueCursor.Position = UDim2.new(p, -3, 0, -2)
                applyColor(Color3.fromHSV(p, 1, 1))
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

        hexInput.FocusLost:Connect(function()
            local hex = hexInput.Text:gsub("#", "")
            if #hex == 6 then
                local r = tonumber(hex:sub(1,2), 16)
                local g = tonumber(hex:sub(3,4), 16)
                local b = tonumber(hex:sub(5,6), 16)
                if r and g and b then
                    applyColor(Color3.fromRGB(r, g, b))
                end
            end
        end)

        swatch.MouseButton1Click:Connect(function()
            open = not open
            C:Tween(frame, { Size = UDim2.new(1, 0, 0, open and 108 or 40) }, 0.24, Enum.EasingStyle.Quart)
            C:Tween(panel, { Size = UDim2.new(1, 0, 0, open and 66 or 0)   }, 0.24, Enum.EasingStyle.Quart)
        end)

        C:Hover(frame, T.SurfaceHigh, T.BorderHigh)
        self:_reg(title, frame)

        local api = { Value = current, Frame = frame }
        function api:Set(col) applyColor(col); self.Value = col end
        function api:Get() return current end
        return api
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  LABEL                                               │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddLabel(opts)
        opts = opts or {}
        local T     = C:T()
        local lo    = self:_lo()
        local text  = type(opts) == "string" and opts or (opts.Text or opts.Title or "Label")

        local frame = C:New("TextLabel", {
            Name                 = "Lbl_" .. text:sub(1,20),
            Size                 = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Text                 = text,
            TextColor3           = T.TextSub,
            Font                 = C.Config.Font,
            TextSize             = 12,
            TextXAlignment       = Enum.TextXAlignment.Left,
            TextWrapped          = true,
            LayoutOrder          = lo,
            ZIndex               = 5,
            Parent               = self._inner,
        })
        C:Pad(frame, 0, 0, 12, 4)

        self:_reg(text, frame)

        local api = { Frame = frame }
        function api:Set(t) frame.Text = t end
        return api
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  PARAGRAPH                                           │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddParagraph(opts)
        opts = opts or {}
        local T     = C:T()
        local lo    = self:_lo()
        local head  = opts.Title or opts.Name or ""
        local body  = opts.Content or opts.Text or ""

        local frame = C:New("Frame", {
            Name             = "Para",
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.BG,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
        C:Corner(frame, C.Config.CornerSM)
        C:Pad(frame, 8, 8, 12, 12)
        C:List(frame, Enum.FillDirection.Vertical, 4)

        if head ~= "" then
            C:New("TextLabel", {
                Size                 = UDim2.new(1, 0, 0, 18),
                AutomaticSize        = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text                 = head,
                TextColor3           = T.AccentText,
                Font                 = C.Config.FontBold,
                TextSize             = 12,
                TextXAlignment       = Enum.TextXAlignment.Left,
                ZIndex               = 6,
                Parent               = frame,
            })
        end

        C:New("TextLabel", {
            Size                 = UDim2.new(1, 0, 0, 0),
            AutomaticSize        = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text                 = body,
            TextColor3           = T.TextSub,
            Font                 = C.Config.Font,
            TextSize             = 12,
            TextXAlignment       = Enum.TextXAlignment.Left,
            TextWrapped          = true,
            RichText             = true,
            ZIndex               = 6,
            Parent               = frame,
        })

        self:_reg(head ~= "" and head or body:sub(1,20), frame)
        return { Frame = frame }
    end

    -- ┌─────────────────────────────────────────────────────┐
    -- │  SEPARATOR                                           │
    -- └─────────────────────────────────────────────────────┘
    function secAPI:AddSeparator()
        local T  = C:T()
        local lo = self:_lo()
        C:New("Frame", {
            Size             = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Border,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
            ZIndex           = 5,
            Parent           = self._inner,
        })
    end
end

return Elements
