local SS = SimpleSeq

local DEFAULT_DELAY = 150
local MIN_DELAY = 100
local MAX_DELAY = 1000

local function ClampDelay(value)
    if type(value) ~= "number" then return DEFAULT_DELAY end
    return math.max(MIN_DELAY, math.min(MAX_DELAY, math.floor(value)))
end

local function ValidateDB()
    if not SS.db then return end
    for key, profile in pairs(SS.db) do
        if type(key) ~= "string" or not key:match("^%u+-%d+$") then
            SS.db[key] = nil
        elseif type(profile) ~= "table" then
            SS.db[key] = { spells = {}, delay = DEFAULT_DELAY }
        else
            if type(profile.spells) ~= "table" then
                profile.spells = {}
            end
            profile.delay = ClampDelay(profile.delay)
        end
    end
end

function SS:LoadProfile(profileKey)
    if not self.db then return end
    if not self.db[profileKey] then
        self.db[profileKey] = { spells = {}, delay = DEFAULT_DELAY }
    end
    local profile = self.db[profileKey]
    profile.delay = ClampDelay(profile.delay)
    self.currentProfile = profileKey
    self.currentStep = 1
end

function SS:GetCurrentProfile()
    if self.db and self.currentProfile and self.db[self.currentProfile] then
        return self.db[self.currentProfile]
    end
    return { spells = {}, delay = DEFAULT_DELAY }
end

SS.frame = CreateFrame("Frame")
SS.frame:RegisterEvent("ADDON_LOADED")
SS.frame:RegisterEvent("PLAYER_LOGIN")
SS.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
SS.frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

SS.frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "SimpleSeq" then
            if not SimpleSeqDB then
                SimpleSeqDB = {}
            end
            SS.db = SimpleSeqDB
            ValidateDB()
        end

    elseif event == "PLAYER_LOGIN" then
        local key = SS:GetProfileKey()
        SS:LoadProfile(key)
        SS:CreateButton()
        SS:BindKey()
        SS:SetupButtonHandlers()
        SS:PresetSpell()
        SS:Print("v" .. SS.VERSION .. " loaded — " .. key)

    elseif event == "PLAYER_ENTERING_WORLD" then
        if not SS.currentProfile then
            local key = SS:GetProfileKey()
            SS:LoadProfile(key)
        end
        if SS.button and not InCombatLockdown() then
            SS:BindKey()
        end

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local newKey = SS:GetProfileKey()
        if newKey == SS.currentProfile then return end
        SS:LoadProfile(newKey)
        if SS.button and not InCombatLockdown() then
            SS:PresetSpell()
            SS:BindKey()
        end
        if SS.uiFrame and SS.uiFrame:IsShown() then
            SS:RefreshSpellList()
            SS:RefreshDelaySlider()
        end
        SS:Print("Profile switched: " .. newKey)
    end
end)
