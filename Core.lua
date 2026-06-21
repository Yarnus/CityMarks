local _, addon = ...

local defaults = {
    enabled = true,
    displayMode = "labels",
    professionFilter = false,
    cluster = true,
    mapControls = true,
    labelSize = 1,
    iconSize = 1,
    enabledCities = {},
    cityScale = {},
}

local function copyDefaults(source, target)
    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = target[key] or {}
            copyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

function addon:ResetDB()
    CityMarksDB = {}
    copyDefaults(defaults, CityMarksDB)
    self.db = CityMarksDB
end

function addon:IsCityEnabled(mapID)
    return self.db.enabledCities[mapID] ~= false
end

function addon:GetCityScale(mapID)
    local city = self.Cities[mapID]
    return (city.scale or 1) * (self.db.cityScale[mapID] or 1)
end

function addon:GetKnownProfessions()
    local known = {}
    local first, second = GetProfessions()

    for _, index in ipairs({first, second}) do
        if index then
            local _, _, _, _, _, _, skillLine = GetProfessionInfo(index)
            if skillLine then
                known[skillLine] = true
            end
        end
    end

    return known
end

function addon:OpenSettings()
    if Settings and Settings.OpenToCategory and self.settingsCategory then
        local categoryID = self.settingsCategory.GetID and self.settingsCategory:GetID()
            or self.settingsCategory.ID
        if categoryID then
            Settings.OpenToCategory(categoryID)
        end
    end
end

SLASH_CITYMARKS1 = "/citymarks"
SLASH_CITYMARKS2 = "/cm"
SlashCmdList.CITYMARKS = function()
    addon:OpenSettings()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    CityMarksDB = CityMarksDB or {}
    copyDefaults(defaults, CityMarksDB)
    addon.db = CityMarksDB

    addon:InitializeMap()
    addon:InitializeSettings()
end)
