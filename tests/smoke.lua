local addon = {}
local eventFrame
local currentLocale = "enUS"
local openedCategory
local lastFontFlags
local shadowColorSet = false
local shadowOffsetSet = false

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
    SetFont = function(_, _, _, flags)
        lastFontFlags = flags
    end,
    SetShadowColor = function()
        shadowColorSet = true
    end,
    SetShadowOffset = function()
        shadowOffsetSet = true
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
    return object
end

function CreateFrame(_, name, _, template)
    local frame = newObject()
    frame.CreateFontString = newObject
    frame.CreateTexture = newObject

    if template == "UICheckButtonTemplate" then
        frame.Text = newObject()
    elseif template == "UIRadioButtonTemplate" then
        frame.text = newObject()
    end

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
    OpenToCategory = function(categoryID)
        openedCategory = categoryID
    end,
    RegisterAddOnCategory = noOp,
    RegisterCanvasLayoutCategory = function()
        return {
            GetID = function()
                return "CityMarks"
            end,
        }
    end,
}

GameTooltip = newObject()
GameTooltip_Hide = noOp
SlashCmdList = {}
hash_SlashCmdList = {}
ChatFrameUtil = {
    ImportAllListsToHash = function()
        for name, handler in pairs(SlashCmdList) do
            local index = 1
            local command = _G["SLASH_" .. name .. index]
            while command do
                hash_SlashCmdList[command:upper()] = handler
                index = index + 1
                command = _G["SLASH_" .. name .. index]
            end
        end
    end,
}

function hooksecurefunc()
end

local function loadAddonFile(path)
    local chunk = assert(loadfile(path))
    chunk("CityMarks", addon)
end

loadAddonFile("Locale.lua")
loadAddonFile("Locales/enUS.lua")
loadAddonFile("Locales/zhCN.lua")
loadAddonFile("Locales/zhTW.lua")
loadAddonFile("Data.lua")
loadAddonFile("Core.lua")
loadAddonFile("Map.lua")
loadAddonFile("Settings.lua")

SLASH_OTHER1 = "/cm"
SlashCmdList.OTHER = function()
    error("conflicting /cm command was called")
end

assert(#addon.CityOrder == 7, "expected seven supported cities")
assert(addon.Cities[2393], "expected Silvermoon data")
assert(addon.L.SETTINGS == "Settings", "expected English locale")

local expectedNames = {
    enUS = "CityMarks",
    zhCN = "城市标记",
    zhTW = "城市標記",
}

for _, locale in ipairs({"enUS", "zhCN", "zhTW"}) do
    currentLocale = locale
    local localizedAddon = {}
    for _, path in ipairs({
        "Locale.lua",
        "Locales/enUS.lua",
        "Locales/zhCN.lua",
        "Locales/zhTW.lua",
    }) do
        local chunk = assert(loadfile(path))
        chunk("CityMarks", localizedAddon)
    end

    assert(localizedAddon.L.ADDON_NAME == expectedNames[locale], locale .. " was not selected")
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
assert(SLASH_CITYMARKS2 == "/cmarks", "expected unique short alias")
assert(SLASH_CITYMARKS3 == "/cm", "expected /cm alias")
assert(hash_SlashCmdList["/CM"] == SlashCmdList.CITYMARKS, "expected /cm in the live command routing table")

hash_SlashCmdList["/CM"]()
assert(openedCategory == "CityMarks", "expected slash command to open settings")

addon:RefreshMap()
assert(lastFontFlags == "OUTLINE", "expected map labels to use an outline")
assert(shadowColorSet, "expected map labels to use a shadow color")
assert(shadowOffsetSet, "expected map labels to use a shadow offset")
print("CityMarks smoke test passed")
