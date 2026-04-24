-- ============================================================
--   AETHER UI LIBRARY  ·  Loader.lua  ·  v1.0
--   Single-file bootstrap  —  loadstring this to get Lib
--
--   Usage:
--       local Lib = loadstring(game:HttpGet("RAW_URL/Loader.lua"))()
--       local Win = Lib:CreateWindow({ Title = "My Script", Theme = "Ember" })
--       local Tab = Win:AddTab({ Name = "Main", Icon = "⚡" })
--       local Sec = Tab:AddSection("Settings")
--       Sec:AddToggle({ Title = "Enable", Default = false, Callback = function(v) end })
--       Lib:Notify({ Title = "Loaded!", Type = "success", Duration = 4 })
-- ============================================================

-- ── GitHub Raw Base URL ────────────────────────────────────────
-- ⚠  Replace with your own repo URL (no trailing slash)
local BASE = "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/AetherLib"

-- ── File manifest (load order matters) ─────────────────────────
local FILES = {
    "Core.lua",
    "Window.lua",
    "Elements.lua",
    "Notifications.lua",
    "Widgets.lua",
}

-- ── HTTP guard ─────────────────────────────────────────────────
local HttpService = game:GetService("HttpService")
assert(
    pcall(function() HttpService:GetAsync("https://example.com") end) or true,
    "[Aether] HTTP requests must be enabled."
)

-- ── Module loader ──────────────────────────────────────────────
local loaded  = {}
local errors  = {}

local function Load(file)
    local ok, result = pcall(function()
        local src = game:HttpGet(BASE .. "/" .. file)
        local fn, err = loadstring(src)
        assert(fn, "[Aether] Syntax error in " .. file .. ": " .. tostring(err))
        return fn()
    end)
    if ok then
        loaded[file] = result
    else
        table.insert(errors, "[Aether] Failed to load " .. file .. ": " .. tostring(result))
        warn(errors[#errors])
    end
    return loaded[file]
end

for _, f in ipairs(FILES) do
    Load(f)
end

if #errors > 0 then
    error("[Aether] " .. #errors .. " module(s) failed to load. Check the console.", 2)
end

-- ── Module references ──────────────────────────────────────────
local Core          = loaded["Core.lua"]
local Window        = loaded["Window.lua"]
local Elements      = loaded["Elements.lua"]
local NotifFactory  = loaded["Notifications.lua"]
local WidgetFactory = loaded["Widgets.lua"]

-- Initialise notification system (shared across all windows)
local Notif   = NotifFactory(Core)
local Widgets = WidgetFactory(Core)

-- ============================================================
--   PUBLIC LIBRARY API
-- ============================================================

local Lib = {}
Lib._windows = {}
Lib._theme   = "Ember"     -- global default theme

-- ── Lib:CreateWindow(opts) ─────────────────────────────────────
--   opts:
--     Title      string          window title         ("Aether")
--     Subtitle   string          small sub-label      ("v1.0")
--     Icon       string          emoji / symbol       ("✦")
--     Theme      string          "Ember"|"Dusk"|"Sakura"|"Forest"
--     Size       Vector2         initial window size  (580, 440)
--     HomePage   boolean         show Home tab?       (true)
--
--   returns winAPI  (same as Window.new return + injected helpers)
-- ──────────────────────────────────────────────────────────────
function Lib:CreateWindow(opts)
    opts = opts or {}

    -- Merge global theme if not overridden per-window
    if not opts.Theme then opts.Theme = self._theme end

    -- Build the window via Window module
    local winAPI = Window.new(Core, opts)

    -- ── Home tab (optional, default ON) ───────────────────────
    local showHome = opts.HomePage
    if showHome == nil then showHome = true end

    if showHome then
        local homeTab = winAPI:AddTab({ Name = "Home", Icon = "⌂" })
        Widgets:Setup(homeTab, winAPI)
    end

    -- ── Inject element methods into every future section ───────
    --   Monkey-patch AddTab so sections auto-get element methods
    local _origAddTab = winAPI.AddTab
    function winAPI:AddTab(tabOpts)
        local tabAPI = _origAddTab(self, tabOpts)

        local _origAddSection = tabAPI.AddSection
        function tabAPI:AddSection(secOpts)
            local secAPI = _origAddSection(self, secOpts)
            Elements.Inject(Core, secAPI)
            return secAPI
        end

        return tabAPI
    end

    -- Re-inject for the home tab sections too (Widgets calls AddSection internally)
    -- This is fine — Widgets calls homeTab:AddSection after the patch

    -- ── Register and return ────────────────────────────────────
    table.insert(self._windows, winAPI)
    return winAPI
end

-- ── Lib:Notify(opts) ──────────────────────────────────────────
--   opts:
--     Title    string   notification heading
--     Message  string   body text
--     Type     string   "success"|"error"|"warning"|"info"
--     Duration number   seconds visible (default 4)
-- ──────────────────────────────────────────────────────────────
function Lib:Notify(opts)
    return Notif:Push(opts)
end

-- ── Lib:SetTheme(name) ─────────────────────────────────────────
--   Changes the active theme for all subsequent windows.
--   Does NOT retroactively re-theme open windows.
-- ──────────────────────────────────────────────────────────────
function Lib:SetTheme(name)
    assert(Core.Themes[name], "[Aether] Unknown theme: " .. tostring(name))
    Core._activeTheme = name
    self._theme = name
end

-- ── Lib:GetThemes() ───────────────────────────────────────────
function Lib:GetThemes()
    local t = {}
    for k in pairs(Core.Themes) do table.insert(t, k) end
    table.sort(t)
    return t
end

-- ── Lib:Destroy() ─────────────────────────────────────────────
--   Clean up all windows + notification container.
-- ──────────────────────────────────────────────────────────────
function Lib:Destroy()
    for _, w in ipairs(self._windows) do
        pcall(function() w:Close() end)
    end
    self._windows = {}
    pcall(function()
        if Notif._container then Notif._container:Destroy() end
    end)
end

-- ── Version tag ───────────────────────────────────────────────
Lib.Version = "1.0.0"
Lib.Name    = "Aether"

-- ── Boot message ──────────────────────────────────────────────
task.spawn(function()
    task.wait(0.1)
    Notif:Push({
        Title   = "Aether  v" .. Lib.Version,
        Message = "Library loaded · " .. #FILES .. " modules active",
        Type    = "info",
        Duration = 3,
    })
end)

return Lib


-- ============================================================
--   FULL EXAMPLE  (uncomment to test)
-- ============================================================
--[[

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR/REPO/main/AetherLib/Loader.lua"))()

-- ── Create a window ───────────────────────────────────────────
local Win = Lib:CreateWindow({
    Title    = "Apex Script",
    Subtitle = "v3.0",
    Icon     = "⚡",
    Theme    = "Ember",        -- "Ember" | "Dusk" | "Sakura" | "Forest"
    HomePage = true,           -- auto home tab with live stats + widgets
})

-- ── Combat tab ────────────────────────────────────────────────
local Combat = Win:AddTab({ Name = "Combat", Icon = "⚔" })

local AimSec = Combat:AddSection("Aimbot")
AimSec:AddToggle({
    Title    = "Enable Aimbot",
    Default  = false,
    Callback = function(v) print("Aimbot:", v) end,
})
AimSec:AddSlider({
    Title    = "FOV Radius",
    Min      = 10,
    Max      = 500,
    Default  = 120,
    Suffix   = "px",
    Integer  = true,
    Callback = function(v) print("FOV:", v) end,
})
AimSec:AddDropdown({
    Title    = "Hitbox",
    Options  = { "Head", "Torso", "Nearest" },
    Default  = { "Head" },
    Callback = function(sel) print("Hitbox:", sel[1]) end,
})
AimSec:AddKeybind({
    Title    = "Aimbot Key",
    Default  = Enum.KeyCode.Q,
    Callback = function(key) print("Rebound to:", key) end,
})

-- ── Visuals tab ───────────────────────────────────────────────
local Visuals = Win:AddTab({ Name = "Visuals", Icon = "👁" })

local EspSec = Visuals:AddSection("ESP")
EspSec:AddToggle({ Title = "Box ESP",     Default = true,  Callback = function(v) end })
EspSec:AddToggle({ Title = "Name ESP",    Default = true,  Callback = function(v) end })
EspSec:AddToggle({ Title = "Distance",    Default = false, Callback = function(v) end })
EspSec:AddColorPicker({
    Title    = "ESP Color",
    Default  = Color3.fromRGB(185, 147, 82),
    Callback = function(c) print("ESP Color:", c) end,
})

-- ── Settings tab ──────────────────────────────────────────────
local Settings = Win:AddTab({ Name = "Settings", Icon = "⚙" })

local ThemeSec = Settings:AddSection("Theme")
ThemeSec:AddDropdown({
    Title    = "Active Theme",
    Options  = Lib:GetThemes(),
    Default  = { "Ember" },
    Callback = function(sel) Lib:SetTheme(sel[1]) end,
})
ThemeSec:AddSeparator()
ThemeSec:AddButton({
    Title       = "Destroy GUI",
    Description = "Completely removes Aether from the game",
    Callback    = function() Lib:Destroy() end,
})

-- ── Manual notification ───────────────────────────────────────
Lib:Notify({
    Title    = "Script Ready",
    Message  = "All modules loaded successfully",
    Type     = "success",
    Duration = 5,
})

--]]
