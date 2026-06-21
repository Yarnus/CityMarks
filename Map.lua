local _, addon = ...

local active = {}
local pool = {}
local controls

local function clearMarkers()
    for _, frame in ipairs(active) do
        frame:Hide()
        pool[#pool + 1] = frame
    end
    wipe(active)
end

local function acquireMarker(parent)
    local frame = table.remove(pool)
    if not frame then
        frame = CreateFrame("Frame")
    end
    frame:SetParent(parent)
    frame:ClearAllPoints()
    frame:Show()
    active[#active + 1] = frame
    return frame
end

local function hexToRGB(value)
    if not value then
        return 1, 1, 1
    end

    return tonumber(value:sub(1, 2), 16) / 255,
        tonumber(value:sub(3, 4), 16) / 255,
        tonumber(value:sub(5, 6), 16) / 255
end

local function createIcon(parent, x, y, marker, scale)
    local size = 22 * addon.db.iconSize * scale
    local frame = acquireMarker(parent)
    frame:SetSize(size, size)
    frame:SetPoint("CENTER", parent, "TOPLEFT", x * parent:GetWidth(), -y * parent:GetHeight())
    frame:SetFrameStrata("HIGH")
    frame:EnableMouse(false)

    local texture = frame.texture or frame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    texture:SetTexture(marker.icon)
    texture:Show()
    frame.texture = texture
    if frame.label then
        frame.label:Hide()
    end
end

local function createLabel(parent, x, y, text, color, scale)
    local frame = acquireMarker(parent)
    frame:SetSize(180 * scale, 28 * scale)
    frame:SetPoint("CENTER", parent, "TOPLEFT", x * parent:GetWidth(), -y * parent:GetHeight())
    frame:SetFrameStrata("HIGH")
    frame:EnableMouse(false)

    local label = frame.label or frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:ClearAllPoints()
    label:SetPoint("CENTER")
    label:SetText(text)
    label:SetTextColor(hexToRGB(color))
    label:Show()
    frame.label = label

    local font, _, flags = label:GetFont()
    label:SetFont(font, 13 * addon.db.labelSize * scale, flags or "OUTLINE")
    if frame.texture then
        frame.texture:Hide()
    end
end

local function buildVisibleMarkers(city)
    local visible = {}
    local known = addon.db.professionFilter and addon:GetKnownProfessions() or nil
    local hasKnown = known and next(known) ~= nil

    for _, marker in ipairs(city.markers) do
        if not marker.professionID or not hasKnown or known[marker.professionID] then
            visible[#visible + 1] = marker
        end
    end

    return visible
end

local function clusterMarkers(markers)
    if not addon.db.cluster then
        local clusters = {}
        for _, marker in ipairs(markers) do
            clusters[#clusters + 1] = {marker}
        end
        return clusters
    end

    local clusters = {}
    local used = {}

    for index, marker in ipairs(markers) do
        if not used[index] then
            local cluster = {marker}
            used[index] = true

            if not marker.solo then
                for otherIndex = index + 1, #markers do
                    local other = markers[otherIndex]
                    if not used[otherIndex] and not other.solo then
                        local dx = marker.x - other.x
                        local dy = marker.y - other.y
                        if dx * dx + dy * dy < .001 then
                            cluster[#cluster + 1] = other
                            used[otherIndex] = true
                        end
                    end
                end
            end

            clusters[#clusters + 1] = cluster
        end
    end

    return clusters
end

local function clusterText(cluster)
    local names = {}
    for _, marker in ipairs(cluster) do
        names[#names + 1] = addon.L[marker.key] or marker.key
    end
    return table.concat(names, " · ")
end

local function clusterCenter(cluster)
    local x, y = 0, 0
    for _, marker in ipairs(cluster) do
        x = x + marker.x
        y = y + marker.y
    end
    return x / #cluster, y / #cluster
end

local function setTooltip(button, title)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(title)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
end

local function createControls()
    if controls then
        return
    end

    controls = CreateFrame("Frame", nil, WorldMapFrame.BorderFrame, "BackdropTemplate")
    controls:SetSize(64, 30)
    controls:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -55, -6)
    controls:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"})
    controls:SetBackdropColor(0, 0, 0, .65)

    local mode = CreateFrame("Button", nil, controls)
    mode:SetSize(24, 24)
    mode:SetPoint("LEFT", 4, 0)
    mode.icon = mode:CreateTexture(nil, "ARTWORK")
    mode.icon:SetAllPoints()
    mode.icon:SetTexture("Interface\\Icons\\INV_Misc_Map02")
    mode:SetScript("OnClick", function()
        local current = addon.db.displayMode
        addon.db.displayMode = current == "labels" and "icons" or current == "icons" and "both" or "labels"
        addon:RefreshMap()
    end)
    setTooltip(mode, addon.L.CYCLE_MODE)

    local professions = CreateFrame("CheckButton", nil, controls, "UICheckButtonTemplate")
    professions:SetSize(24, 24)
    professions:SetPoint("LEFT", mode, "RIGHT", 6, 0)
    professions:SetScript("OnClick", function(self)
        addon.db.professionFilter = self:GetChecked() and true or false
        addon:RefreshMap()
    end)
    professions:SetScript("OnShow", function(self)
        self:SetChecked(addon.db.professionFilter)
    end)
    setTooltip(professions, addon.L.TOGGLE_PROFESSIONS)
    controls.professions = professions
end

function addon:RefreshMap()
    clearMarkers()

    if not self.db or not self.db.enabled or not WorldMapFrame:IsShown() then
        if controls then
            controls:Hide()
        end
        return
    end

    local mapID = WorldMapFrame:GetMapID()
    local city = mapID and self.Cities[mapID]
    if not city or not self:IsCityEnabled(mapID) then
        if controls then
            controls:Hide()
        end
        return
    end

    createControls()
    controls:SetShown(self.db.mapControls)
    controls.professions:SetChecked(self.db.professionFilter)

    local canvas = WorldMapFrame:GetCanvas()
    local scale = self:GetCityScale(mapID)
    local markers = buildVisibleMarkers(city)

    if self.db.displayMode ~= "labels" then
        for _, marker in ipairs(markers) do
            createIcon(canvas, marker.x, marker.y, marker, scale)
        end
    end

    if self.db.displayMode ~= "icons" then
        for _, cluster in ipairs(clusterMarkers(markers)) do
            local x, y = clusterCenter(cluster)
            createLabel(canvas, x, y, clusterText(cluster), cluster[1].color, scale)
        end
    end
end

function addon:InitializeMap()
    WorldMapFrame:HookScript("OnShow", function()
        self:RefreshMap()
    end)
    WorldMapFrame:HookScript("OnHide", clearMarkers)
    hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
        self:RefreshMap()
    end)

    local canvas = WorldMapFrame:GetCanvas()
    canvas:HookScript("OnSizeChanged", function()
        if WorldMapFrame:IsShown() then
            self:RefreshMap()
        end
    end)
end
