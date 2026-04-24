-- ============================================================
--   AETHER UI LIBRARY  ·  Widgets.lua  ·  v1.0
--   Home tab · FPS · Ping · Clock · Player · Custom stats
-- ============================================================

return function(Core)
    local C            = Core
    local RunService   = game:GetService("RunService")
    local Players      = game:GetService("Players")
    local lp           = Players.LocalPlayer

    local Widgets = {}

    -- ── Setup: called with the Home tabAPI + window ref ───────
    function Widgets.Setup(homeTabAPI, winRef)
        local T      = C:T()
        local tabContent = homeTabAPI._content  -- the ScrollingFrame

        -- ── TOP INFO ROW (greeting + status) ──────────────────
        local infoSec = homeTabAPI:AddSection("Dashboard")

        -- Greeting label (auto-generated)
        local hour  = tonumber(os.date("%H"))
        local greet = hour < 12 and "Good morning" or (hour < 18 and "Good afternoon" or "Good evening")
        local pname = lp and lp.DisplayName or "User"
        infoSec:AddLabel({ Text = greet .. ", " .. pname .. "  ·  " .. os.date("%A, %B %d") })
        infoSec:AddSeparator()

        -- ── STATS GRID ─────────────────────────────────────────
        local statSec = homeTabAPI:AddSection("Live Stats")

        -- We create a 2×2 widget grid inside this section
        local gridFrame = C:New("Frame", {
            Name          = "WidgetGrid",
            Size          = UDim2.new(1, 0, 0, 120),
            BackgroundTransparency = 1,
            LayoutOrder   = statSec:_lo(),
            ZIndex        = 5,
            Parent        = statSec._inner,
        })
        C:Grid(gridFrame, UDim2.new(0.5, -5, 0, 54), UDim2.new(0, 6, 0, 6))

        -- ── Widget factory (small stat card) ──────────────────
        local function makeStatCard(icon, labelText, startVal, color, key)
            local card = C:New("Frame", {
                BackgroundColor3 = T.BG,
                BorderSizePixel  = 0,
                ZIndex           = 6,
                Parent           = gridFrame,
            })
            C:Corner(card)
            C:Stroke(card, T.Border, 1)

            -- Accent top stripe
            C:New("Frame", {
                Size             = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = color or T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 7,
                Parent           = card,
            })

            C:New("TextLabel", {
                Size                 = UDim2.new(0, 22, 0, 22),
                Position             = UDim2.new(0, 8, 0, 10),
                BackgroundTransparency = 1,
                Text                 = icon,
                TextColor3           = color or T.Accent,
                Font                 = C.Config.FontBold,
                TextSize             = 15,
                ZIndex               = 7,
                Parent               = card,
            })

            C:New("TextLabel", {
                Size                 = UDim2.new(1, -36, 0, 14),
                Position             = UDim2.new(0, 33, 0, 10),
                BackgroundTransparency = 1,
                Text                 = labelText,
                TextColor3           = T.TextDim,
                Font                 = C.Config.Font,
                TextSize             = 10,
                TextXAlignment       = Enum.TextXAlignment.Left,
                ZIndex               = 7,
                Parent               = card,
            })

            local valLbl = C:New("TextLabel", {
                Size                 = UDim2.new(1, -12, 0, 22),
                Position             = UDim2.new(0, 8, 0, 28),
                BackgroundTransparency = 1,
                Text                 = tostring(startVal),
                TextColor3           = T.Text,
                Font                 = C.Config.FontMono,
                TextSize             = 17,
                TextXAlignment       = Enum.TextXAlignment.Left,
                ZIndex               = 7,
                Parent               = card,
            })

            return valLbl
        end

        local T = C:T()
        local fpsLbl  = makeStatCard("◎", "FPS",     "—", T.Success,  "fps")
        local pingLbl = makeStatCard("⟳", "PING ms", "—", T.Info,     "ping")
        local timeLbl = makeStatCard("◷", "TIME",    os.date("%H:%M"), T.Warning, "time")
        local memLbl  = makeStatCard("▣", "MEMORY",  "—", T.Accent,   "mem")

        -- Live updates
        local fpsBuffer = {}
        local conn = RunService.RenderStepped:Connect(function(dt)
            -- Rolling FPS average
            table.insert(fpsBuffer, 1 / dt)
            if #fpsBuffer > 30 then table.remove(fpsBuffer, 1) end
            local sum = 0
            for _, v in ipairs(fpsBuffer) do sum = sum + v end
            local avg = math.round(sum / #fpsBuffer)

            pcall(function() fpsLbl.Text = tostring(avg) end)
            pcall(function() timeLbl.Text = os.date("%H:%M") end)
            pcall(function()
                if lp then
                    local ping = math.round(lp:GetNetworkPing() * 1000)
                    pingLbl.Text = tostring(ping)
                    pingLbl.TextColor3 = ping < 80 and C:T().Success
                        or (ping < 150 and C:T().Warning or C:T().Error)
                end
            end)
            pcall(function()
                local mem = math.round(collectgarbage("count") / 1024)
                memLbl.Text = tostring(mem) .. " MB"
            end)
        end)

        -- Cleanup connection when GUI is destroyed
        if winRef and winRef.GUI then
            winRef.GUI.AncestryChanged:Connect(function()
                if not winRef.GUI.Parent then conn:Disconnect() end
            end)
        end

        -- ── PLAYER INFO CARD ───────────────────────────────────
        local playerSec = homeTabAPI:AddSection("Player")

        local playerFrame = C:New("Frame", {
            Name             = "PlayerCard",
            Size             = UDim2.new(1, 0, 0, 72),
            BackgroundColor3 = T.BG,
            BorderSizePixel  = 0,
            LayoutOrder      = playerSec:_lo(),
            ZIndex           = 5,
            Parent           = playerSec._inner,
        })
        C:Corner(playerFrame)
        C:Stroke(playerFrame, T.Border, 1)

        -- Avatar thumbnail (using HeadShot)
        local avatar = C:New("ImageLabel", {
            Size             = UDim2.new(0, 52, 0, 52),
            Position         = UDim2.new(0, 10, 0.5, -26),
            BackgroundColor3 = T.Surface,
            Image            = "",
            ZIndex           = 6,
            Parent           = playerFrame,
        })
        C:Corner(avatar, C.Config.CornerSM)
        pcall(function()
            local thumb = Players:GetUserThumbnailAsync(lp.UserId,
                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            avatar.Image = thumb
        end)

        -- Name / userId / job
        C:New("TextLabel", {
            Size                 = UDim2.new(1, -80, 0, 20),
            Position             = UDim2.new(0, 70, 0, 12),
            BackgroundTransparency = 1,
            Text                 = (lp and lp.DisplayName or "Unknown"),
            TextColor3           = T.Text,
            Font                 = C.Config.FontBold,
            TextSize             = 14,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = playerFrame,
        })
        C:New("TextLabel", {
            Size                 = UDim2.new(1, -80, 0, 16),
            Position             = UDim2.new(0, 70, 0, 32),
            BackgroundTransparency = 1,
            Text                 = "@" .. (lp and lp.Name or "unknown") .. "  ·  ID: " .. (lp and lp.UserId or "?"),
            TextColor3           = T.TextSub,
            Font                 = C.Config.FontMono,
            TextSize             = 11,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = playerFrame,
        })
        -- Game info
        C:New("TextLabel", {
            Size                 = UDim2.new(1, -80, 0, 14),
            Position             = UDim2.new(0, 70, 0, 50),
            BackgroundTransparency = 1,
            Text                 = "📍 " .. game.PlaceId .. "  ·  " .. (workspace:FindFirstChildWhichIsA("Terrain") and "Active" or "Unknown"),
            TextColor3           = T.TextDim,
            Font                 = C.Config.Font,
            TextSize             = 10,
            TextXAlignment       = Enum.TextXAlignment.Left,
            ZIndex               = 6,
            Parent               = playerFrame,
        })

        -- ── QUICK ACTIONS ──────────────────────────────────────
        local actionSec = homeTabAPI:AddSection("Quick Actions")

        local actions = {
            { label = "Rejoin",    icon = "⟳", cb = function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
            end },
            { label = "Fullbright", icon = "☀", cb = function()
                game:GetService("Lighting").Brightness = 2
                game:GetService("Lighting").ClockTime  = 14
            end },
            { label = "Reset Char", icon = "⟲", cb = function()
                pcall(function() lp.Character.Humanoid.Health = 0 end)
            end },
            { label = "Copy JobId", icon = "⎘", cb = function()
                pcall(function() game:GetService("GuiService"):SetClipboard(game.JobId) end)
            end },
        }

        local actionGrid = C:New("Frame", {
            Name          = "ActionGrid",
            Size          = UDim2.new(1, 0, 0, 68),
            BackgroundTransparency = 1,
            LayoutOrder   = actionSec:_lo(),
            ZIndex        = 5,
            Parent        = actionSec._inner,
        })
        C:Grid(actionGrid, UDim2.new(0.5, -5, 0, 30), UDim2.new(0, 6, 0, 6))

        local T = C:T()
        for _, act in ipairs(actions) do
            local btn = C:New("TextButton", {
                BackgroundColor3 = T.BG,
                Text             = act.icon .. "  " .. act.label,
                TextColor3       = T.TextSub,
                Font             = C.Config.Font,
                TextSize         = 12,
                BorderSizePixel  = 0,
                AutoButtonColor  = false,
                ZIndex           = 6,
                Parent           = actionGrid,
            })
            C:Corner(btn, C.Config.CornerSM)
            C:Stroke(btn, T.Border, 1)
            C:Hover(btn, T.BG, T.SurfaceHigh)
            C:Ripple(btn, 6)
            btn.MouseButton1Click:Connect(function()
                pcall(act.cb)
            end)
        end

        -- ── CUSTOM STAT SLOTS (user-editable) ─────────────────
        Widgets._customStats = {}

        function Widgets:AddStat(opts)
            opts = opts or {}
            local statSec2 = homeTabAPI:AddSection(opts.SectionName or "Custom Stats")
            statSec2:AddLabel({ Text = (opts.Name or "Stat") .. ": " .. tostring(opts.Default or "—") })
            local api = {}
            function api:Set(v)
                -- Future: update label dynamically
            end
            return api
        end
    end

    return Widgets
end
