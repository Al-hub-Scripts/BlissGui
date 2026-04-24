-- ============================================================
--   AETHER UI LIBRARY  ·  Window.lua  ·  v1.0
--   Window · Tabs · Drag · Resize · Search
-- ============================================================

local Window = {}
Window.__index = Window

local UserInputService = game:GetService("UserInputService")

-- ── Constructor ───────────────────────────────────────────────
function Window.new(Core, opts)
    local self     = setmetatable({}, Window)
    self.Core      = Core
    self.Opts      = opts or {}
    self.Tabs      = {}          -- [name] = tabObject
    self.TabOrder  = {}          -- ordered list of tab names
    self.ActiveTab = nil
    self.IsOpen    = true
    self.IsMinimized = false
    self.AllElements = {}        -- for search: {name, frame}
    self.StoredH   = 0

    -- Apply theme override
    if opts.Theme then Core.Config.Theme = opts.Theme end
    local C = Core
    local T = C:T()

    local W = (opts.Size and opts.Size.X) or 650
    local H = (opts.Size and opts.Size.Y) or 480
    self.StoredH = H

    -- ── ScreenGui ───────────────────────────────────────────
    pcall(function()
        local e = game:GetService("CoreGui"):FindFirstChild("AetherLib")
        if e then e:Destroy() end
    end)

    local gui
    local ok = pcall(function()
        gui = C:New("ScreenGui", {
            Name             = "AetherLib",
            ResetOnSpawn     = false,
            ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset   = true,
            Parent           = game:GetService("CoreGui"),
        })
    end)
    if not ok then
        gui = C:New("ScreenGui", {
            Name           = "AetherLib",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
            Parent         = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
        })
    end
    self.GUI = gui

    -- ── Main Frame ──────────────────────────────────────────
    local win = C:New("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, W * 0.88, 0, H * 0.88),
        Position         = UDim2.new(0.5, -(W * 0.88) / 2, 0.5, -(H * 0.88) / 2 + 18),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        Parent           = gui,
    })
    C:Corner(win, C.Config.CornerLG)
    C:Stroke(win, T.Border, 1)
    C:SizeConst(win, Vector2.new(400, 300), Vector2.new(960, 720))
    self.Window = win

    -- Animate in
    C:Tween(win, {
        Size     = UDim2.new(0, W, 0, H),
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
    }, 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Drop shadow
    C:New("ImageLabel", {
        Name                = "Shadow",
        Size                = UDim2.new(1, 72, 1, 72),
        Position            = UDim2.new(0, -36, 0, -24),
        BackgroundTransparency = 1,
        Image               = "rbxassetid://6014261993",
        ImageColor3         = Color3.fromRGB(0,0,0),
        ImageTransparency   = 0.52,
        ScaleType           = Enum.ScaleType.Slice,
        SliceCenter         = Rect.new(49,49,450,450),
        ZIndex              = 0,
        Parent              = win,
    })

    -- ── Title Bar ───────────────────────────────────────────
    local bar = C:New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = win,
    })
    C:New("UICorner", { CornerRadius = C.Config.CornerLG, Parent = bar })
    -- Cover bottom rounded corners of bar
    C:New("Frame", {
        Size             = UDim2.new(1, 0, 0, 14),
        Position         = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = bar,
    })
    -- Bottom divider line
    C:New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = bar,
    })

    -- Icon badge
    local badge = C:New("Frame", {
        Size             = UDim2.new(0, 30, 0, 30),
        Position         = UDim2.new(0, 11, 0.5, -15),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = bar,
    })
    C:Corner(badge, C.Config.CornerSM)
    C:New("TextLabel", {
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                 = opts.Icon or "◈",
        TextColor3           = T.BG,
        Font                 = C.Config.FontBold,
        TextSize             = 15,
        ZIndex               = 6,
        Parent               = badge,
    })

    -- Title
    C:New("TextLabel", {
        Size                 = UDim2.new(0, 160, 1, 0),
        Position             = UDim2.new(0, 49, 0, 0),
        BackgroundTransparency = 1,
        Text                 = opts.Title or "Aether",
        TextColor3           = T.Text,
        Font                 = C.Config.FontBold,
        TextSize             = 14,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ZIndex               = 5,
        Parent               = bar,
    })

    -- Subtitle
    C:New("TextLabel", {
        Size                 = UDim2.new(0, 260, 1, 0),
        Position             = UDim2.new(0, 49 + (#(opts.Title or "Aether") * 8.4), 0, 0),
        BackgroundTransparency = 1,
        Text                 = "/ " .. (opts.Subtitle or "v1.0"),
        TextColor3           = T.TextDim,
        Font                 = C.Config.Font,
        TextSize             = 13,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ZIndex               = 5,
        Parent               = bar,
    })

    -- ── Search Button + Bar ─────────────────────────────────
    local searchBtn = C:New("TextButton", {
        Size                 = UDim2.new(0, 30, 0, 30),
        Position             = UDim2.new(1, -110, 0.5, -15),
        BackgroundColor3     = T.SurfaceHigh,
        Text                 = "⌕",
        TextColor3           = T.TextSub,
        Font                 = C.Config.FontBold,
        TextSize             = 17,
        BorderSizePixel      = 0,
        AutoButtonColor      = false,
        ZIndex               = 6,
        Parent               = bar,
    })
    C:Corner(searchBtn, C.Config.CornerSM)
    C:Hover(searchBtn, T.SurfaceHigh, T.Border)

    local searchBar = C:New("Frame", {
        Size             = UDim2.new(0, 0, 0, 30),
        Position         = UDim2.new(1, -44, 0.5, -15),
        BackgroundColor3 = T.SurfaceHigh,
        ClipsDescendants = true,
        Visible          = false,
        ZIndex           = 7,
        Parent           = bar,
    })
    C:Corner(searchBar, C.Config.CornerSM)
    C:Stroke(searchBar, T.Border, 1)

    local searchInput = C:New("TextBox", {
        Size                 = UDim2.new(1, -12, 1, 0),
        Position             = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text                 = "",
        PlaceholderText      = "Search elements...",
        PlaceholderColor3    = T.TextDim,
        TextColor3           = T.Text,
        Font                 = C.Config.Font,
        TextSize             = 13,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ClearTextOnFocus     = false,
        ZIndex               = 8,
        Parent               = searchBar,
    })
    self.SearchInput = searchInput
    self.SearchBar   = searchBar

    local sOpen = false
    searchBtn.MouseButton1Click:Connect(function()
        sOpen = not sOpen
        if sOpen then
            searchBar.Visible = true
            C:Tween(searchBar, { Size = UDim2.new(0, 185, 0, 30) }, 0.26, Enum.EasingStyle.Quart)
            task.delay(0.1, function() pcall(function() searchInput:CaptureFocus() end) end)
        else
            C:Tween(searchBar, { Size = UDim2.new(0, 0, 0, 30) }, 0.2)
            task.delay(0.21, function()
                searchBar.Visible = false
                searchInput.Text  = ""
                self:_clearSearch()
            end)
        end
    end)
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        self:_doSearch(searchInput.Text)
    end)

    -- ── Window Controls (minimize / close) ──────────────────
    local controls = C:New("Frame", {
        Size                 = UDim2.new(0, 54, 1, 0),
        Position             = UDim2.new(1, -62, 0, 0),
        BackgroundTransparency = 1,
        ZIndex               = 6,
        Parent               = bar,
    })
    C:List(controls, Enum.FillDirection.Horizontal, 6,
        Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
    C:Pad(controls, 0, 0, 0, 8)

    local function makeCtrl(col, icon)
        local b = C:New("TextButton", {
            Size             = UDim2.new(0, 16, 0, 16),
            BackgroundColor3 = col,
            Text             = "",
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            ZIndex           = 7,
            Parent           = controls,
        })
        C:Corner(b, C.Config.CornerRound)
        C:New("TextLabel", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = icon,
            TextColor3           = Color3.fromRGB(0,0,0),
            TextTransparency     = 0.5,
            Font                 = C.Config.FontBold,
            TextSize             = 9,
            ZIndex               = 8,
            Parent               = b,
        })
        b.MouseEnter:Connect(function()
            C:Tween(b, { BackgroundColor3 = col:Lerp(Color3.new(1,1,1), 0.28) }, 0.12)
        end)
        b.MouseLeave:Connect(function()
            C:Tween(b, { BackgroundColor3 = col }, 0.12)
        end)
        return b
    end

    local minBtn   = makeCtrl(T.Warning, "−")
    local closeBtn = makeCtrl(T.Error,   "×")

    minBtn.MouseButton1Click:Connect(function()
        self.IsMinimized = not self.IsMinimized
        local curW = win.AbsoluteSize.X
        if self.IsMinimized then
            C:Tween(win, { Size = UDim2.new(0, curW, 0, 48) }, 0.32, Enum.EasingStyle.Quart)
        else
            C:Tween(win, { Size = UDim2.new(0, curW, 0, self.StoredH) }, 0.32, Enum.EasingStyle.Quart)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        local curW = win.AbsoluteSize.X
        local curH = win.AbsoluteSize.Y
        C:Tween(win, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, curW * 0.9, 0, curH * 0.9),
        }, 0.25)
        task.delay(0.26, function() pcall(function() gui:Destroy() end) end)
    end)

    -- Update StoredH on resize (not while minimized)
    win:GetPropertyChangedSignal("Size"):Connect(function()
        if not self.IsMinimized then
            self.StoredH = win.AbsoluteSize.Y
        end
    end)

    -- Make bar draggable
    C:MakeDraggable(win, bar)

    -- ── Sidebar ─────────────────────────────────────────────
    local sidebar = C:New("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 148, 1, -48),
        Position         = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = win,
    })
    -- Top-right square fill to hide rounded corner at bar junction
    C:New("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = sidebar,
    })
    C:New("UICorner", { CornerRadius = C.Config.CornerLG, Parent = sidebar })
    -- Right border
    C:New("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = sidebar,
    })

    -- Tab scroll list
    local tabList = C:New("ScrollingFrame", {
        Name                    = "TabList",
        Size                    = UDim2.new(1, 0, 1, -50),
        BackgroundTransparency  = 1,
        BorderSizePixel         = 0,
        ScrollBarThickness      = 3,
        ScrollBarImageColor3    = T.Scrollbar,
        CanvasSize              = UDim2.new(0,0,0,0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        ZIndex                  = 3,
        Parent                  = sidebar,
    })
    C:List(tabList, Enum.FillDirection.Vertical, 3)
    C:Pad(tabList, 8, 8, 8, 8)
    self.TabList = tabList

    -- Bottom of sidebar: keybind / version info
    C:New("TextLabel", {
        Size                 = UDim2.new(1, 0, 0, 38),
        Position             = UDim2.new(0, 0, 1, -42),
        BackgroundTransparency = 1,
        Text                 = "Aether  ·  v1.0",
        TextColor3           = T.TextDim,
        Font                 = C.Config.FontMono,
        TextSize             = 10,
        ZIndex               = 3,
        Parent               = sidebar,
    })

    -- ── Content Area ────────────────────────────────────────
    local content = C:New("Frame", {
        Name                 = "Content",
        Size                 = UDim2.new(1, -149, 1, -49),
        Position             = UDim2.new(0, 149, 0, 49),
        BackgroundTransparency = 1,
        ZIndex               = 2,
        Parent               = win,
    })
    self.Content = content

    -- ── Resize Handle ───────────────────────────────────────
    local resizeHandle = C:New("Frame", {
        Name                 = "ResizeHandle",
        Size                 = UDim2.new(0, 22, 0, 22),
        Position             = UDim2.new(1, -22, 1, -22),
        BackgroundTransparency = 1,
        ZIndex               = 12,
        Parent               = win,
    })
    -- Grip dots
    for i = 1, 3 do
        for j = i, 3 do
            C:New("Frame", {
                Size             = UDim2.new(0, 2, 0, 2),
                Position         = UDim2.new(0, (j-1)*5 + 4, 0, (i-1)*5 + 4),
                BackgroundColor3 = T.BorderHigh,
                BorderSizePixel  = 0,
                ZIndex           = 13,
                Parent           = resizeHandle,
            })
        end
    end
    C:MakeResizable(win, resizeHandle)

    return self
end

-- ── Add Tab ───────────────────────────────────────────────────
function Window:AddTab(opts)
    local C = self.Core
    local T = C:T()
    opts = opts or {}
    local name = opts.Name or ("Tab " .. (#self.TabOrder + 1))
    local icon = opts.Icon or "▸"

    -- Sidebar button
    local tabBtn = C:New("TextButton", {
        Name                 = "Tab_" .. name,
        Size                 = UDim2.new(1, 0, 0, 38),
        BackgroundColor3     = T.SurfaceHigh,
        BackgroundTransparency = 1,
        Text                 = "",
        BorderSizePixel      = 0,
        AutoButtonColor      = false,
        LayoutOrder          = #self.TabOrder + 1,
        ZIndex               = 4,
        Parent               = self.TabList,
    })
    C:Corner(tabBtn, C.Config.CornerSM)

    -- Left accent indicator
    local accentLine = C:New("Frame", {
        Size             = UDim2.new(0, 3, 0, 16),
        Position         = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        BackgroundTransparency = 1,
        ZIndex           = 5,
        Parent           = tabBtn,
    })
    C:Corner(accentLine, UDim.new(1, 0))

    -- Icon label
    local iconLbl = C:New("TextLabel", {
        Size                 = UDim2.new(0, 26, 1, 0),
        Position             = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text                 = icon,
        TextColor3           = T.TextDim,
        Font                 = C.Config.FontBold,
        TextSize             = 15,
        ZIndex               = 5,
        Parent               = tabBtn,
    })

    -- Name label
    local nameLbl = C:New("TextLabel", {
        Size                 = UDim2.new(1, -40, 1, 0),
        Position             = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text                 = name,
        TextColor3           = T.TextDim,
        Font                 = C.Config.Font,
        TextSize             = 13,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ZIndex               = 5,
        Parent               = tabBtn,
    })

    -- Tab content (scrolling)
    local tabContent = C:New("ScrollingFrame", {
        Name                    = "Content_" .. name,
        Size                    = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency  = 1,
        BorderSizePixel         = 0,
        ScrollBarThickness      = 4,
        ScrollBarImageColor3    = T.Scrollbar,
        CanvasSize              = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize     = Enum.AutomaticSize.Y,
        Visible                 = false,
        ZIndex                  = 3,
        Parent                  = self.Content,
    })
    C:List(tabContent, Enum.FillDirection.Vertical, 8)
    C:Pad(tabContent, 10, 14, 10, 10)

    -- Tab record
    local tab = {
        Name       = name,
        Button     = tabBtn,
        Content    = tabContent,
        AccentLine = accentLine,
        IconLbl    = iconLbl,
        NameLbl    = nameLbl,
        Active     = false,
    }
    self.Tabs[name] = tab
    table.insert(self.TabOrder, name)

    -- Click to select
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)

    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if not tab.Active then
            C:Tween(tabBtn,  { BackgroundTransparency = 0.6 }, 0.14)
            C:Tween(nameLbl, { TextColor3 = T.TextSub },       0.14)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if not tab.Active then
            C:Tween(tabBtn,  { BackgroundTransparency = 1 },    0.14)
            C:Tween(nameLbl, { TextColor3 = T.TextDim },        0.14)
        end
    end)

    -- Auto-select if first tab
    if #self.TabOrder == 1 then self:SelectTab(name) end

    -- Return tab API
    local tabAPI  = { _win = self, _content = tabContent, _tab = tab }
    local winRef  = self

    function tabAPI:AddSection(sOpts)
        return Window.CreateSection(winRef, tabContent, sOpts)
    end

    return tabAPI
end

-- ── Select Tab ────────────────────────────────────────────────
function Window:SelectTab(name)
    local C = self.Core
    local T = C:T()
    for _, tab in pairs(self.Tabs) do
        tab.Active       = false
        tab.Content.Visible = false
        C:Tween(tab.Button,    { BackgroundTransparency = 1    }, 0.2)
        C:Tween(tab.NameLbl,   { TextColor3 = T.TextDim        }, 0.2)
        C:Tween(tab.IconLbl,   { TextColor3 = T.TextDim        }, 0.2)
        C:Tween(tab.AccentLine,{ BackgroundTransparency = 1    }, 0.2)
    end
    local tab = self.Tabs[name]
    if tab then
        tab.Active          = true
        tab.Content.Visible = true
        C:Tween(tab.Button,    { BackgroundTransparency = 0    }, 0.2)
        C:Tween(tab.NameLbl,   { TextColor3 = T.Text           }, 0.2)
        C:Tween(tab.IconLbl,   { TextColor3 = T.AccentText     }, 0.2)
        C:Tween(tab.AccentLine,{ BackgroundTransparency = 0    }, 0.2)
        self.ActiveTab = name
    end
end

-- ── Search ────────────────────────────────────────────────────
function Window:_doSearch(q)
    q = q:lower():gsub("%s", "")
    if q == "" then self:_clearSearch(); return end
    for _, e in ipairs(self.AllElements) do
        if e.frame and e.frame.Parent then
            local hit = e.name:lower():gsub("%s", ""):find(q, 1, true)
            local trans = hit and 0 or 0.72
            self.Core:Tween(e.frame, { BackgroundTransparency = trans }, 0.14)
        end
    end
end

function Window:_clearSearch()
    for _, e in ipairs(self.AllElements) do
        if e.frame and e.frame.Parent then
            self.Core:Tween(e.frame, { BackgroundTransparency = 0 }, 0.14)
        end
    end
end

-- ── Create Section (shared helper, also called by tabAPI) ─────
function Window.CreateSection(winSelf, parent, opts)
    local C = winSelf.Core
    local T = C:T()
    opts    = opts or {}
    local title = type(opts) == "string" and opts or (opts.Name or opts.Title or "Section")

    -- Section container
    local sec = C:New("Frame", {
        Name             = "Sec_" .. title,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = parent,
    })
    C:Corner(sec)
    C:Stroke(sec, T.Border, 1)

    -- Inner padding frame
    local inner = C:New("Frame", {
        Name                 = "Inner",
        Size                 = UDim2.new(1, 0, 0, 0),
        AutomaticSize        = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex               = 4,
        Parent               = sec,
    })
    C:List(inner, Enum.FillDirection.Vertical, 6)
    C:Pad(inner, 6, 10, 10, 10)

    -- Section header
    local header = C:New("Frame", {
        Size                 = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder          = 0,
        ZIndex               = 5,
        Parent               = inner,
    })
    C:New("Frame", {
        Size             = UDim2.new(0, 2, 0, 12),
        Position         = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = header,
    })
    C:New("TextLabel", {
        Size                 = UDim2.new(1, -12, 1, 0),
        Position             = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text                 = title:upper(),
        TextColor3           = T.TextSub,
        Font                 = C.Config.FontBold,
        TextSize             = 10,
        TextXAlignment       = Enum.TextXAlignment.Left,
        ZIndex               = 6,
        Parent               = header,
    })

    -- Section API (element methods injected by Elements module via Loader)
    local secAPI = {
        _win      = winSelf,
        _inner    = inner,
        _order    = 1,
        _elements = winSelf.AllElements,
    }

    function secAPI:_lo()
        self._order = self._order + 1
        return self._order
    end

    function secAPI:_reg(name, frame)
        table.insert(self._elements, { name = name, frame = frame })
    end

    return secAPI
end

return Window
