local _, addon = ...

local controls = {}

local function addLabel(parent, text, template, x, y)
    local label = parent:CreateFontString(nil, "ARTWORK", template or "GameFontNormal")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(text)
    return label
end

local function addCheckbox(parent, text, x, y, getValue, setValue)
    local button = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button.Text:SetText(text)
    button:SetScript("OnClick", function(self)
        setValue(self:GetChecked() and true or false)
        addon:RefreshMap()
    end)
    button:SetScript("OnShow", function(self)
        self:SetChecked(getValue())
    end)
    controls[#controls + 1] = button
    return button
end

local sliderIndex = 0
local function addSlider(parent, text, x, y, width, minimum, maximum, step, getValue, setValue)
    sliderIndex = sliderIndex + 1
    local name = "CityMarksSlider" .. sliderIndex
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetWidth(width)
    slider:SetMinMaxValues(minimum, maximum)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    _G[name .. "Text"]:SetText(text)
    _G[name .. "Low"]:SetText(minimum)
    _G[name .. "High"]:SetText(maximum)
    slider:SetScript("OnValueChanged", function(self, value)
        if self.updating then
            return
        end
        value = math.floor(value / step + .5) * step
        setValue(value)
        addon:RefreshMap()
    end)
    slider:SetScript("OnShow", function(self)
        self.updating = true
        self:SetValue(getValue())
        self.updating = false
    end)
    controls[#controls + 1] = slider
    return slider
end

local function addRadio(parent, text, value, x, y)
    local button = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
    button:SetPoint("TOPLEFT", x, y)
    button.Text:SetText(text)
    button:SetScript("OnClick", function()
        addon.db.displayMode = value
        for _, control in ipairs(controls) do
            if control.mode then
                control:SetChecked(control.mode == value)
            end
        end
        addon:RefreshMap()
    end)
    button:SetScript("OnShow", function(self)
        self:SetChecked(addon.db.displayMode == value)
    end)
    button.mode = value
    controls[#controls + 1] = button
end

function addon:InitializeSettings()
    local panel = CreateFrame("Frame")
    panel.name = self.L.ADDON_NAME

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -28, 4)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(700, 900)
    scroll:SetScrollChild(content)

    addLabel(content, self.L.ADDON_NAME, "GameFontNormalLarge", 16, -16)
    addLabel(content, self.L.DESCRIPTION, "GameFontHighlight", 16, -44)

    addCheckbox(content, self.L.ENABLED, 12, -78,
        function() return self.db.enabled end,
        function(value) self.db.enabled = value end)
    addCheckbox(content, self.L.PROFESSION_FILTER, 12, -110,
        function() return self.db.professionFilter end,
        function(value) self.db.professionFilter = value end)
    addCheckbox(content, self.L.CLUSTER, 12, -142,
        function() return self.db.cluster end,
        function(value) self.db.cluster = value end)
    addCheckbox(content, self.L.MAP_CONTROLS, 12, -174,
        function() return self.db.mapControls end,
        function(value) self.db.mapControls = value end)

    addLabel(content, self.L.DISPLAY_MODE, "GameFontNormal", 16, -220)
    addRadio(content, self.L.LABELS, "labels", 12, -242)
    addRadio(content, self.L.ICONS, "icons", 170, -242)
    addRadio(content, self.L.BOTH, "both", 328, -242)

    addSlider(content, self.L.LABEL_SIZE, 20, -300, 220, .5, 2, .1,
        function() return self.db.labelSize end,
        function(value) self.db.labelSize = value end)
    addSlider(content, self.L.ICON_SIZE, 310, -300, 220, .5, 2, .1,
        function() return self.db.iconSize end,
        function(value) self.db.iconSize = value end)

    addLabel(content, self.L.CITIES, "GameFontNormalLarge", 16, -370)

    local y = -405
    for _, mapID in ipairs(self.CityOrder) do
        local currentMapID = mapID
        local city = self.Cities[currentMapID]
        addCheckbox(content, self.L[city.name], 12, y,
            function() return self:IsCityEnabled(currentMapID) end,
            function(value) self.db.enabledCities[currentMapID] = value end)
        addSlider(content, self.L.CITY_SCALE, 250, y - 4, 220, .6, 1.5, .1,
            function() return self.db.cityScale[currentMapID] or 1 end,
            function(value) self.db.cityScale[currentMapID] = value end)
        y = y - 58
    end

    local reset = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    reset:SetSize(160, 24)
    reset:SetPoint("TOPLEFT", 16, y - 10)
    reset:SetText(self.L.RESET)
    reset:SetScript("OnClick", function()
        self:ResetDB()
        for _, control in ipairs(controls) do
            local onShow = control:GetScript("OnShow")
            if onShow then
                onShow(control)
            end
        end
        self:RefreshMap()
    end)

    local category = Settings.RegisterCanvasLayoutCategory(panel, self.L.ADDON_NAME)
    Settings.RegisterAddOnCategory(category)
    self.settingsCategory = category
end
