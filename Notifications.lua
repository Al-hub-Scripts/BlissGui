-- ============================================================
--   AETHER UI LIBRARY  ·  Notifications.lua  ·  v1.0
--   Toast notifications · Stack management · Timed dismiss
-- ============================================================

return function(Core)
    local C    = Core
    local queue = {}
    local MAX   = 5

    -- Container pinned to bottom-right
    local gui
    pcall(function() gui = game:GetService("CoreGui"):FindFirstChild("AetherLib") end)
    if not gui then
        pcall(function() gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("AetherLib") end)
    end

    local container
    if gui then
        container = Core:New("Frame", {
            Name                 = "NotifContainer",
            Size                 = UDim2.new(0, 300, 1, 0),
            Position             = UDim2.new(1, -316, 0, 0),
            BackgroundTransparency = 1,
            ZIndex               = 50,
            Parent               = gui,
        })
        Core:List(container, Enum.FillDirection.Vertical, 8,
            Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
        Core:Pad(container, 0, 16, 0, 0)
    end

    -- ── Icon for notification type ─────────────────────────
    local icons = {
        success = "✓",
        error   = "✕",
        warning = "⚠",
        info    = "ℹ",
    }

    -- ── Push a notification ────────────────────────────────
    local Notif = {}

    function Notif:Push(opts)
        opts = opts or {}
        if not container then return end

        -- Trim oldest if over cap
        if #queue >= MAX then
            local oldest = table.remove(queue, 1)
            if oldest and oldest.Destroy then oldest:Destroy() end
        end

        local T        = C:T()
        local nType    = (opts.Type or opts.type or "info"):lower()
        local accent   = C:TypeColor(nType)
        local duration = opts.Duration or opts.duration or C.Config.NotifDuration
        local title    = opts.Title or opts.title or nType:sub(1,1):upper() .. nType:sub(2)
        local msg      = opts.Message or opts.message or opts.Desc or ""

        -- Card
        local card = C:New("Frame", {
            Name             = "Notif_" .. os.clock(),
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            BackgroundTransparency = 0,
            ZIndex           = 51,
            Parent           = container,
        })
        C:Corner(card, C.Config.CornerMD)
        C:Stroke(card, accent, 1, 0.4)

        -- Left accent stripe
        local stripe = C:New("Frame", {
            Size             = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            ZIndex           = 52,
            Parent           = card,
        })
        C:New("UICorner", {
            CornerRadius = C.Config.CornerMD,
            Parent       = stripe,
        })

        -- Icon circle
        local iconBG = C:New("Frame", {
            Size             = UDim2.new(0, 26, 0, 26),
            Position         = UDim2.new(0, 14, 0, 12),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            ZIndex           = 52,
            Parent           = card,
        })
        C:Corner(iconBG, C.Config.CornerRound)
        C:New("TextLabel", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text                 = icons[nType] or "ℹ",
            TextColor3           = Color3.fromRGB(10, 10, 14),
            Font                 = C.Config.FontBold,
            TextSize             = 13,
            ZIndex               = 53,
            Parent               = iconBG,
        })

        -- Title
        C:New("TextLabel", {
            Size                 = UDim2.new(1, -52, 0, 20),
            Position             = UDim2.new(0, 48, 0, 8),
            BackgroundTransparency = 1,
            Text                 = title,
            TextColor3           = T.Text,
            Font                 = C.Config.FontBold,
            TextSize             = 13,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 52,
            Parent               = card,
        })

        -- Message
        local msgLbl = C:New("TextLabel", {
            Size                 = UDim2.new(1, -52, 0, 0),
            Position             = UDim2.new(0, 48, 0, 28),
            AutomaticSize        = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text                 = msg,
            TextColor3           = T.TextSub,
            Font                 = C.Config.Font,
            TextSize             = 12,
            TextXAlignment       = Enum.TextXAlignment.Left,
            TextWrapped          = true,
            RichText             = true,
            ZIndex               = 52,
            Parent               = card,
        })

        -- Progress bar (timer)
        local barBG = C:New("Frame", {
            Size             = UDim2.new(1, 0, 0, 3),
            Position         = UDim2.new(0, 0, 1, -3),
            BackgroundColor3 = T.Border,
            BorderSizePixel  = 0,
            ZIndex           = 52,
            Parent           = card,
        })
        local barFill = C:New("Frame", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = accent,
            BorderSizePixel  = 0,
            ZIndex           = 53,
            Parent           = barBG,
        })

        -- Spacer so AutomaticSize includes bottom padding
        C:New("Frame", {
            Size                 = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            ZIndex               = 52,
            Position             = UDim2.new(0, 0, 1, -14),
            Parent               = card,
        })

        -- Slide in from right
        card.Position = UDim2.new(1, 16, 0, 0)
        C:Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        -- Progress bar drain
        C:Tween(barFill, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear)

        local function dismiss()
            C:Tween(card, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 }, 0.28, Enum.EasingStyle.Quart)
            task.delay(0.3, function()
                pcall(function() card:Destroy() end)
                for i, n in ipairs(queue) do
                    if n == card then table.remove(queue, i); break end
                end
            end)
        end

        table.insert(queue, card)
        task.delay(duration, dismiss)

        -- Click to dismiss early
        card.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dismiss() end
        end)

        return { Card = card, Dismiss = dismiss }
    end

    return Notif
end
