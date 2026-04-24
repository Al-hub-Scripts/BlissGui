-- ============================================================
--   BLISS GUI LIBRARY  ·  Loader.lua  ·  v1.0
--   Single-file bootstrap — loadstring this to get Lib
--
--   Quick start:
--       local Lib = loadstring(game:HttpGet(
--           "https://raw.githubusercontent.com/Al-hub-Scripts/BlissGui/main/Loader.lua"
--       ))()
--       local Win = Lib:CreateWindow({ Title = "My Script", Theme = "Ember" })
--       local Tab = Win:AddTab({ Name = "Main", Icon = "⚡" })
--       local Sec = Tab:AddSection("Settings")
--       Sec:AddToggle({ Title = "Enable", Default = false, Callback = function(v) end })
--       Lib:Notify({ Title = "Loaded!", Type = "success", Duration = 4 })
-- ============================================================

-- ── GitHub Raw Base URL ────────────────────────────────────────
local BASE = "https://raw.githubusercontent.com/Al-hub-Scripts/BlissGui/main"

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
    "[BlissGui] HTTP requests must be enabled. Enable them in Game Settings."
)

-- ── Module loader ──────────────────────────────────────────────
local loaded  = {}
local errors  = {}

local function Load(file)
    local ok, result = pcall(function()
        local src = game:HttpGet(BASE .. "/" .. file)
        local fn, err = loadstring(src)
        assert(fn, "[BlissGui] Syntax error in " .. file .. ": " .. tostring(err))
        return fn()
    end)
    if ok then
        loaded[file] = result
    else
        table.insert(errors, "[BlissGui] Failed to load " .. file .. ": " .. tostring(result))
        warn(errors[#errors])
    end
    return loaded[file]
end

for _, f in ipairs(FILES) do
    Load(f)
end

if #errors > 0 then
    error("[BlissGui] " .. #errors .. " module(s) failed to load. Check the output console.", 2)
end

-- ── Module references ──────────────────────────────────────────
local Core          = loaded["Core.lua"]
local Window        = loaded["Window.lua"]
local Elements      = loaded["Elements.lua"]
local NotifFactory  = loaded["Notifications.lua"]
local WidgetFactory = loaded["Widgets.lua"]

local Notif   = NotifFactory(Core)
local Widgets = WidgetFactory(Core)

-- ============================================================
--   PUBLIC LIBRARY API
-- ============================================================

local Lib = {}
Lib._windows = {}
Lib._theme   = "Ember"

function Lib:CreateWindow(opts)
    opts = opts or {}
    if not opts.Theme then opts.Theme = self._theme end
    local winAPI = Window.new(Core, opts)

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

    local showHome = opts.HomePage
    if showHome == nil then showHome = true end
    if showHome then
        local homeTab = winAPI:AddTab({ Name = "Home", Icon = "⌂" })
        Widgets:Setup(homeTab, winAPI)
    end

    table.insert(self._windows, winAPI)
    return winAPI
end

function Lib:Notify(opts)
    return Notif:Push(opts)
end

function Lib:SetTheme(name)
    assert(Core.Themes[name], "[BlissGui] Unknown theme: " .. tostring(name))
    Core._activeTheme = name
    self._theme = name
end

function Lib:GetThemes()
    local t = {}
    for k in pairs(Core.Themes) do table.insert(t, k) end
    table.sort(t)
    return t
end

function Lib:Destroy()
    for _, w in ipairs(self._windows) do
        pcall(function() w:Close() end)
    end
    self._windows = {}
    pcall(function()
        if Notif._container then Notif._container:Destroy() end
    end)
end

Lib.Version = "1.0.0"
Lib.Name    = "BlissGui"

task.spawn(function()
    task.wait(0.1)
    Notif:Push({
        Title    = "BlissGui  v" .. Lib.Version,
        Message  = "Library ready · " .. #FILES .. " modules loaded",
        Type     = "info",
        Duration = 3,
    })
end)

return Lib
