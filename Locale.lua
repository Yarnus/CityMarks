local _, addon = ...

addon.L = {}

function addon:RegisterLocale(locale, strings)
    if locale ~= "enUS" and locale ~= GetLocale() then
        return
    end

    for key, value in pairs(strings) do
        self.L[key] = value
    end
end
