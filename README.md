<div align="center">

# ✦ BlissGui

**A sleek, terminal-aesthetic UI library for Roblox executors**

*Dark · Minimal · Fast · Six modules, one loadstring*

[![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=flat-square&logo=lua)](https://lua.org)
[![Roblox](https://img.shields.io/badge/Roblox-Executor-red?style=flat-square)](https://roblox.com)
[![Version](https://img.shields.io/badge/version-1.0.0-gold?style=flat-square)](#)

</div>

---

## Quick Start

```lua
local Lib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Al-hub-Scripts/BlissGui/main/Loader.lua"
))()

local Win = Lib:CreateWindow({
    Title    = "My Script",
    Subtitle = "v1.0",
    Theme    = "Ember",
})

local Tab = Win:AddTab({ Name = "Main", Icon = "⚡" })
local Sec = Tab:AddSection("Settings")

Sec:AddToggle({
    Title    = "Enable",
    Default  = false,
    Callback = function(v) print("Toggled:", v) end,
})

Lib:Notify({ Title = "Ready!", Type = "success", Duration = 4 })
```

---

## Themes

| Name | Style |
|------|-------|
| `"Ember"` | Dark background · amber / terminal-gold accents |
| `"Dusk"` | Deep navy · electric blue accents |
| `"Sakura"` | Void black · rose / pink accents |
| `"Forest"` | Dark green · muted sage accents |

```lua
-- Set theme when creating the window
local Win = Lib:CreateWindow({ Title = "Script", Theme = "Dusk" })

-- Or switch globally (affects future windows)
Lib:SetTheme("Sakura")

-- List all available themes
print(table.concat(Lib:GetThemes(), ", "))
```

---

## API Reference

### `Lib:CreateWindow(opts)`

Creates the main GUI window. Returns a `Window` object.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | `"BlissGui"` | Window title text |
| `Subtitle` | string | `""` | Smaller label below title |
| `Icon` | string | `"✦"` | Emoji or symbol in the title bar |
| `Theme` | string | `"Ember"` | One of the four theme names |
| `Size` | Vector2 | `(580, 440)` | Initial window dimensions |
| `HomePage` | boolean | `true` | Auto-create a Home tab with live stats |

```lua
local Win = Lib:CreateWindow({
    Title    = "Apex Hub",
    Subtitle = "v2.5",
    Icon     = "🔥",
    Theme    = "Ember",
    Size     = Vector2.new(620, 480),
    HomePage = true,
})
```

---

### `Win:AddTab(opts)`

Adds a sidebar tab to the window. Returns a `Tab` object.

| Option | Type | Description |
|--------|------|-------------|
| `Name` | string | Tab label |
| `Icon` | string | Emoji shown next to the label |

```lua
local Combat  = Win:AddTab({ Name = "Combat",  Icon = "⚔"  })
local Visuals = Win:AddTab({ Name = "Visuals", Icon = "👁"  })
local Config  = Win:AddTab({ Name = "Config",  Icon = "⚙"  })
```

---

### `Tab:AddSection(title)`

Groups elements under a labeled section. Returns a `Section` object.

```lua
local AimSec = Combat:AddSection("Aimbot")
local EspSec = Visuals:AddSection("ESP Settings")
```

---

## Elements

All elements are methods on a `Section` object.

---

### `Section:AddToggle(opts)`

An on/off switch with animated thumb.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | — | Element label |
| `Description` | string | `""` | Small subtitle text |
| `Default` | boolean | `false` | Initial state |
| `Callback` | function | — | Called with `(bool)` on change |

```lua
local toggle = Sec:AddToggle({
    Title       = "Silent Aim",
    Description = "Redirects bullets to target",
    Default     = false,
    Callback    = function(v)
        print("Silent Aim:", v)
    end,
})

-- Programmatic control
toggle:Set(true)
print(toggle:Get()) -- true
```

---

### `Section:AddSlider(opts)`

A draggable value slider.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | — | Element label |
| `Min` | number | `0` | Minimum value |
| `Max` | number | `100` | Maximum value |
| `Default` | number | Min | Starting value |
| `Suffix` | string | `""` | Unit label (e.g. `"px"`, `"ms"`) |
| `Integer` | boolean | `false` | Round to whole numbers |
| `Callback` | function | — | Called with `(number)` on change |

```lua
local slider = Sec:AddSlider({
    Title    = "Walk Speed",
    Min      = 16,
    Max      = 500,
    Default  = 16,
    Suffix   = "st",
    Integer  = true,
    Callback = function(v)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end,
})

slider:Set(100)
print(slider:Get()) -- 100
```

---

### `Section:AddDropdown(opts)`

A single or multi-select dropdown.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | — | Element label |
| `Options` | table | — | Array of string choices |
| `Multi` | boolean | `false` | Allow multiple selections |
| `Default` | table | `{}` | Array of pre-selected items |
| `Callback` | function | — | Called with `(table)` of selected items |

```lua
-- Single select
local drop = Sec:AddDropdown({
    Title    = "Target Part",
    Options  = { "Head", "Torso", "LeftArm", "RightArm" },
    Default  = { "Head" },
    Callback = function(sel)
        print("Selected:", sel[1])
    end,
})

-- Multi select
local multiDrop = Sec:AddDropdown({
    Title    = "Active Hacks",
    Options  = { "ESP", "Aimbot", "Speed", "NoClip" },
    Multi    = true,
    Default  = { "ESP" },
    Callback = function(sel)
        for _, v in ipairs(sel) do print(v) end
    end,
})

drop:Set({ "Torso" })
print(drop:Get()) -- { "Torso" }
```

---

### `Section:AddButton(opts)`

A clickable action button with ripple effect.

| Option | Type | Description |
|--------|------|-------------|
| `Title` | string | Button label |
| `Description` | string | Small subtitle text |
| `Callback` | function | Called on click |

```lua
Sec:AddButton({
    Title       = "Teleport to Spawn",
    Description = "Moves character to map origin",
    Callback    = function()
        local root = game.Players.LocalPlayer.Character.HumanoidRootPart
        root.CFrame = CFrame.new(0, 10, 0)
    end,
})
```

---

### `Section:AddTextInput(opts)`

A text field with focus styling.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | — | Element label |
| `Default` | string | `""` | Pre-filled value |
| `Placeholder` | string | `""` | Greyed hint text |
| `ClearOnFocus` | boolean | `false` | Clears text when clicked |
| `Callback` | function | — | Called with `(string)` on Enter |

```lua
local input = Sec:AddTextInput({
    Title        = "Player Name",
    Placeholder  = "Enter username...",
    ClearOnFocus = true,
    Callback     = function(text)
        print("Input:", text)
    end,
})

input:Set("Hikage")
print(input:Get())
```

---

### `Section:AddKeybind(opts)`

A rebindable hotkey listener.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | — | Element label |
| `Default` | KeyCode | — | Initial key binding |
| `Callback` | function | — | Called when key is rebound |
| `FireCallback` | function | — | Called when bound key is pressed |
| `HoldCallback` | function | — | Called while bound key is held |

```lua
local bind = Sec:AddKeybind({
    Title        = "Toggle ESP",
    Default      = Enum.KeyCode.Z,
    FireCallback = function()
        print("ESP toggled!")
    end,
    Callback     = function(key)
        print("Rebound to:", key.Name)
    end,
})

bind:Set(Enum.KeyCode.X)
print(bind:Get().Name) -- "X"
```

---

### `Section:AddColorPicker(opts)`

A hue slider + hex input color picker.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | — | Element label |
| `Default` | Color3 | White | Initial color |
| `Callback` | function | — | Called with `(Color3)` on change |

```lua
local picker = Sec:AddColorPicker({
    Title    = "ESP Color",
    Default  = Color3.fromRGB(185, 147, 82),
    Callback = function(color)
        -- color is a Color3 value
        print(color.R, color.G, color.B)
    end,
})

picker:Set(Color3.fromRGB(255, 100, 100))
print(picker:Get())
```

---

### `Section:AddLabel(opts)`

Plain informational text.

```lua
Sec:AddLabel({ Text = "Version: 1.0.0" })
-- or
Sec:AddLabel({ Title = "Status: Active" })
```

---

### `Section:AddParagraph(opts)`

A titled block of rich text.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Title` | string | — | Bold heading |
| `Content` | string | — | Body text (RichText supported) |

```lua
Sec:AddParagraph({
    Title   = "About",
    Content = "This script uses <b>BlissGui v1.0</b> for its interface.\nAll features are safe to use.",
})
```

---

### `Section:AddSeparator()`

A thin horizontal divider line.

```lua
Sec:AddToggle({ Title = "Option A", ... })
Sec:AddSeparator()
Sec:AddToggle({ Title = "Option B", ... })
```

---

## Notifications

```lua
Lib:Notify({
    Title    = "Notification Title",
    Message  = "Optional body text here.",
    Type     = "success",   -- "success" | "error" | "warning" | "info"
    Duration = 5,           -- seconds (default: 4)
})
```

Notifications appear in the bottom-right corner with a progress bar timer and can be clicked to dismiss early. Up to 5 are shown simultaneously.

| Type | Color | Icon |
|------|-------|------|
| `"success"` | Green | ✓ |
| `"error"` | Red | ✕ |
| `"warning"` | Amber | ⚠ |
| `"info"` | Blue | ℹ |

---

## Home Tab (Widgets)

When `HomePage = true` (the default), a Home tab is automatically added with:

- **Live stats grid** — FPS (30-frame rolling avg), ping, clock, memory usage
- **Player card** — avatar thumbnail, display name, username, user ID, place ID
- **Quick actions** — Rejoin, Fullbright toggle, Reset character, Copy JobId

---

## Library Methods

| Method | Description |
|--------|-------------|
| `Lib:CreateWindow(opts)` | Create and open a new window |
| `Lib:Notify(opts)` | Push a toast notification |
| `Lib:SetTheme(name)` | Change active theme (future windows) |
| `Lib:GetThemes()` | Returns sorted list of theme names |
| `Lib:Destroy()` | Remove all windows and clean up |

---

## Full Example

```lua
-- Load the library
local Lib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Al-hub-Scripts/BlissGui/main/Loader.lua"
))()

-- Create window
local Win = Lib:CreateWindow({
    Title    = "Apex Hub",
    Subtitle = "v2.0",
    Icon     = "⚡",
    Theme    = "Ember",
    HomePage = true,
})

-- ── Combat Tab ───────────────────────────────────────────────
local Combat = Win:AddTab({ Name = "Combat", Icon = "⚔" })

local AimSec = Combat:AddSection("Aimbot")
AimSec:AddToggle({
    Title    = "Enable Aimbot",
    Default  = false,
    Callback = function(v) print("Aimbot:", v) end,
})
AimSec:AddSlider({
    Title    = "FOV Radius",
    Min      = 10, Max = 500, Default = 120,
    Suffix   = "px", Integer = true,
    Callback = function(v) print("FOV:", v) end,
})
AimSec:AddDropdown({
    Title    = "Target Part",
    Options  = { "Head", "Torso", "Nearest" },
    Default  = { "Head" },
    Callback = function(sel) print("Part:", sel[1]) end,
})
AimSec:AddKeybind({
    Title        = "Aimbot Key",
    Default      = Enum.KeyCode.Q,
    FireCallback = function() print("Aimbot activated") end,
})

-- ── Visuals Tab ──────────────────────────────────────────────
local Visuals = Win:AddTab({ Name = "Visuals", Icon = "👁" })

local EspSec = Visuals:AddSection("ESP")
EspSec:AddToggle({ Title = "Box ESP",  Default = true,  Callback = function(v) end })
EspSec:AddToggle({ Title = "Name ESP", Default = true,  Callback = function(v) end })
EspSec:AddToggle({ Title = "Distance", Default = false, Callback = function(v) end })
EspSec:AddSeparator()
EspSec:AddColorPicker({
    Title    = "ESP Color",
    Default  = Color3.fromRGB(185, 147, 82),
    Callback = function(c) print("Color changed") end,
})

-- ── Player Tab ───────────────────────────────────────────────
local Player = Win:AddTab({ Name = "Player", Icon = "👤" })

local SpeedSec = Player:AddSection("Movement")
local speedSlider = SpeedSec:AddSlider({
    Title    = "Walk Speed",
    Min      = 16, Max = 500, Default = 16,
    Suffix   = "st", Integer = true,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char then char.Humanoid.WalkSpeed = v end
    end,
})
SpeedSec:AddSlider({
    Title    = "Jump Power",
    Min      = 50, Max = 500, Default = 50,
    Integer  = true,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char then char.Humanoid.JumpPower = v end
    end,
})
SpeedSec:AddButton({
    Title    = "Reset Speed",
    Callback = function() speedSlider:Set(16) end,
})

-- ── Settings Tab ─────────────────────────────────────────────
local Settings = Win:AddTab({ Name = "Settings", Icon = "⚙" })

local ThemeSec = Settings:AddSection("Appearance")
ThemeSec:AddDropdown({
    Title    = "Theme",
    Options  = Lib:GetThemes(),
    Default  = { "Ember" },
    Callback = function(sel) Lib:SetTheme(sel[1]) end,
})
ThemeSec:AddSeparator()
ThemeSec:AddButton({
    Title       = "Destroy GUI",
    Description = "Completely removes BlissGui",
    Callback    = function() Lib:Destroy() end,
})

-- Notify on load
Lib:Notify({
    Title    = "Apex Hub",
    Message  = "Script loaded and ready.",
    Type     = "success",
    Duration = 5,
})
```

---

## File Structure

```
BlissGui/
├── Loader.lua          ← Entry point (loadstring this)
├── Core.lua            ← Theme engine & utilities
├── Window.lua          ← Window, tabs, drag, resize, search
├── Elements.lua        ← All UI elements
├── Notifications.lua   ← Toast notification system
└── Widgets.lua         ← Home tab dashboard
```

---

<div align="center">

made with ♡ by **Al-hub-Scripts**

</div>
