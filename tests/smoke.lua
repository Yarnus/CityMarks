local addon = {}
local eventFrame
local currentLocale = "enUS"

function GetLocale()
    return currentLocale
end

function GetProfessions()
    return nil, nil
end

function GetProfessionInfo()
    return nil
end

function wipe(value)
    for key in pairs(value) do
        value[key] = nil
    end
end

local function noOp()
end

local objectMethods = {
    GetFont = function()
        return "Fonts\\FRIZQT__.TTF", 12, ""
    end,
    GetHeight = function()
        return 600
    end,
    GetMapID = function()
        return 2393
    end,
    GetScript = function(self, script)
        local scripts = rawget(self, "scripts")
        return scripts and scripts[script]
    end,
    GetWidth = function()
        return 1000
    end,
    GetChecked = function(self)
        return self.checked
    end,
    IsShown = function()
        return true
    end,
    SetChecked = function(self, value)
        self.checked = value
    end,
    SetScript = function(self, script, handler)
        local scripts = rawget(self, "scripts") or {}
        rawset(self, "scripts", scripts)
        scripts[script] = handler
    end,
}

for _, method in ipairs({
    "ClearAllPoints",
    "EnableMouse",
    "Hide",
    "HookScript",
    "RegisterEvent",
    "SetAllPoints",
    "SetBackdrop",
    "SetBackdropColor",
    "SetFont",
    "SetFrameStrata",
    "SetHeight",
    "SetMinMaxValues",
    "SetObeyStepOnDrag",
    "SetParent",
    "SetPoint",
    "SetScrollChild",
    "SetShown",
    "SetSize",
    "SetText",
    "SetTextColor",
    "SetTexture",
    "SetValue",
    "SetValueStep",
    "SetWidth",
    "Show",
}) do
    objectMethods[method] = noOp
end

local objectMeta = {
    __index = function(_, key)
        return objectMethods[key]
    end,
}

local function newObject()
    local object = setmetatable({}, objectMeta)
    object.Text = setmetatable({}, objectMeta)
    return object
end

function CreateFrame(_, name, _, template)
    local frame = newObject()
    frame.CreateFontString = newObject
    frame.CreateTexture = newObject

    if template == "OptionsSliderTemplate" and name then
        _G[name .. "Text"] = newObject()
        _G[name .. "Low"] = newObject()
        _G[name .. "High"] = newObject()
    end

    if not eventFrame then
        eventFrame = frame
    end
    return frame
end

WorldMapFrame = newObject()
WorldMapFrame.BorderFrame = newObject()
local canvas = newObject()
function WorldMapFrame:GetCanvas()
    return canvas
end

Settings = {
    OpenToCategory = noOp,
    RegisterAddOnCategory = noOp,
    RegisterCanvasLayoutCategory = function()
        return {ID = 1}
    end,
}

GameTooltip = newObject()
GameTooltip_Hide = noOp
SlashCmdList = {}

function hooksecurefunc()
end

local function loadAddonFile(path)
    local chunk = assert(loadfile(path))
    chunk("CityMarks", addon)
end

loadAddonFile("Locale.lua")
loadAddonFile("Data.lua")
loadAddonFile("Core.lua")
loadAddonFile("Map.lua")
loadAddonFile("Settings.lua")

assert(#addon.CityOrder == 7, "expected seven supported cities")
assert(addon.Cities[2393], "expected Silvermoon data")
assert(addon.L.SETTINGS == "Settings", "expected English locale")

for _, locale in ipairs({"enUS", "zhCN", "zhTW"}) do
    currentLocale = locale
    local localizedAddon = {}
    local chunk = assert(loadfile("Locale.lua"))
    chunk("CityMarks", localizedAddon)

    for _, city in pairs(addon.Cities) do
        assert(localizedAddon.L[city.name], locale .. " is missing city key " .. city.name)
        for _, marker in ipairs(city.markers) do
            assert(localizedAddon.L[marker.key], locale .. " is missing marker key " .. marker.key)
        end
    end
end

eventFrame.scripts.OnEvent()

assert(CityMarksDB, "expected saved variables")
assert(addon.settingsCategory, "expected settings category")
assert(SlashCmdList.CITYMARKS, "expected settings slash command")

addon:RefreshMap()
print("CityMarks smoke test passed")
