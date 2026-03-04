local SS = SimpleSeq

local FRAME_WIDTH = 300
local FRAME_HEIGHT = 420
local ROW_HEIGHT = 22
local SPELL_LIST_HEIGHT = 220

local spellRows = {}

function SS:CreateUI()
    if self.uiFrame then return end

    local f = CreateFrame("Frame", "SimpleSeqFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f.TitleBg:SetHeight(30)
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOP", f.TitleBg, "TOP", 0, -3)
    f.title:SetText("SimpleSeq Config")

    local profileLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profileLabel:SetPoint("TOPLEFT", f.InsetBg, "TOPLEFT", 8, -6)
    profileLabel:SetTextColor(0.7, 0.7, 0.7)
    f.profileLabel = profileLabel

    local inputBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    inputBox:SetSize(190, 25)
    inputBox:SetPoint("TOPLEFT", f.InsetBg, "TOPLEFT", 12, -24)
    inputBox:SetAutoFocus(false)
    inputBox:SetMaxLetters(100)
    f.inputBox = inputBox

    local addBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    addBtn:SetSize(60, 25)
    addBtn:SetPoint("LEFT", inputBox, "RIGHT", 6, 0)
    addBtn:SetText("Add")
    f.addBtn = addBtn

    local function AddSpell()
        local text = inputBox:GetText()
        if not text or text:match("^%s*$") then return end
        text = text:match("^%s*(.-)%s*$")
        local profile = SS:GetCurrentProfile()
        table.insert(profile.spells, text)
        inputBox:SetText("")
        inputBox:SetFocus()
        SS:RefreshSpellList()
        SS:SyncButtonSpell()
    end

    addBtn:SetScript("OnClick", AddSpell)
    inputBox:SetScript("OnEnterPressed", function()
        AddSpell()
    end)

    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", inputBox, "BOTTOMLEFT", -4, -8)
    scrollFrame:SetSize(FRAME_WIDTH - 40, SPELL_LIST_HEIGHT)
    f.scrollFrame = scrollFrame

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(FRAME_WIDTH - 56, 1)
    scrollFrame:SetScrollChild(content)
    f.content = content

    local sliderLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sliderLabel:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 52)
    f.sliderLabel = sliderLabel

    local slider = CreateFrame("Slider", "SimpleSeqDelaySlider", f, "OptionsSliderTemplate")
    slider:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 28)
    slider:SetSize(FRAME_WIDTH - 40, 17)
    slider:SetMinMaxValues(100, 1000)
    slider:SetValueStep(10)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText("100ms")
    slider.High:SetText("1000ms")
    f.slider = slider

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.max(100, math.min(1000, math.floor(value)))
        local profile = SS:GetCurrentProfile()
        profile.delay = value
        f.sliderLabel:SetText("Key Delay: " .. value .. "ms")
    end)

    self.uiFrame = f
end

function SS:RefreshSpellList()
    if not self.uiFrame then return end
    local content = self.uiFrame.content
    local profile = self:GetCurrentProfile()

    for _, row in ipairs(spellRows) do
        row:Hide()
        row:SetParent(nil)
    end
    wipe(spellRows)

    self.uiFrame.profileLabel:SetText("Profile: " .. (self.currentProfile or "N/A"))

    for i, spellName in ipairs(profile.spells) do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(FRAME_WIDTH - 56, ROW_HEIGHT)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)

        local idx = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        idx:SetPoint("LEFT", 2, 0)
        idx:SetText(i .. ".")
        idx:SetWidth(20)
        idx:SetJustifyH("RIGHT")

        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", idx, "RIGHT", 6, 0)
        name:SetText(spellName)
        name:SetWidth(180)
        name:SetJustifyH("LEFT")

        if not SS:IsSpellAvailable(spellName) then
            name:SetTextColor(0.5, 0.5, 0.5)
        end

        local delBtn = CreateFrame("Button", nil, row, "UIPanelCloseButton")
        delBtn:SetSize(20, 20)
        delBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        delBtn.spellIndex = i
        delBtn:SetScript("OnClick", function(self)
            local idx = self.spellIndex
            local p = SS:GetCurrentProfile()
            table.remove(p.spells, idx)
            if SS.currentStep > #p.spells and #p.spells > 0 then
                SS.currentStep = 1
            end
            SS:RefreshSpellList()
            SS:SyncButtonSpell()
        end)

        spellRows[i] = row
    end

    content:SetHeight(math.max(1, #profile.spells * ROW_HEIGHT))
end

function SS:RefreshDelaySlider()
    if not self.uiFrame then return end
    local profile = self:GetCurrentProfile()
    self.uiFrame.slider:SetValue(profile.delay)
    self.uiFrame.sliderLabel:SetText("Key Delay: " .. profile.delay .. "ms")
end

function SS:SyncButtonSpell()
    if not self.button then return end
    self:PresetSpell()
end

function SS:ToggleUI()
    if not self.uiFrame then
        self:CreateUI()
    end
    if self.uiFrame:IsShown() then
        self.uiFrame:Hide()
    else
        self:RefreshSpellList()
        self:RefreshDelaySlider()
        self.uiFrame:Show()
    end
end

SLASH_SIMPLESEQ1 = "/sq"
SLASH_SIMPLESEQ2 = "/simpleseq"
SlashCmdList["SIMPLESEQ"] = function()
    SS:ToggleUI()
end
