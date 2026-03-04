local SS = SimpleSeq

function SS:GetCurrentSpell()
    local profile = self:GetCurrentProfile()
    local spells = profile.spells
    if not spells or #spells == 0 then
        return nil
    end
    local current = spells[self.currentStep]
    if current and self:IsSpellAvailable(current) then
        return current
    end
    local spell, idx = self:GetNextValidSpell(spells, self.currentStep)
    if spell then
        self.currentStep = idx
    end
    return spell
end

function SS:CreateButton()
    if self.button then return end
    local btn = CreateFrame("Button", "SimpleSeqButton", UIParent, "SecureActionButtonTemplate")
    btn:SetAttribute("type", "spell")
    btn:SetAttribute("useOnKeyDown", true)
    btn:RegisterForClicks("AnyDown", "AnyUp")
    btn.lastCast = 0
    btn.debounced = false
    self.button = btn
end

function SS:BindKey()
    if not self.button then return end
    if InCombatLockdown() then return end

    local existing = GetBindingAction("1")
    if existing and existing ~= "" and existing ~= "CLICK SimpleSeqButton:LeftButton" then
        self:Print("Key '1' was bound to [" .. existing .. "], SimpleSeq overriding")
    end

    SetOverrideBindingClick(self.button, false, "1", "SimpleSeqButton")
end

function SS:PresetSpell()
    if not self.button then return end
    local spell = self:GetCurrentSpell()
    if spell then
        self.button:SetAttribute("type", "spell")
        self.button:SetAttribute("spell", spell)
    else
        self.button:SetAttribute("type", "")
    end
end

function SS:SetupButtonHandlers()
    if not self.button then return end

    self.button:SetScript("PreClick", function(btn)
        local profile = SS:GetCurrentProfile()
        local delay = (profile.delay or 150) / 1000
        local now = GetTime()

        if (now - btn.lastCast) < delay then
            btn:SetAttribute("type", "")
            btn.debounced = true
            return
        end

        local spell = SS:GetCurrentSpell()
        if spell then
            btn:SetAttribute("type", "spell")
            btn:SetAttribute("spell", spell)
        else
            btn:SetAttribute("type", "")
        end
        btn.lastCast = now
        btn.debounced = false
    end)

    self.button:SetScript("PostClick", function(btn)
        if btn.debounced then return end

        local profile = SS:GetCurrentProfile()
        local spells = profile.spells
        if not spells or #spells == 0 then return end

        local nextStep = SS.currentStep + 1
        if nextStep > #spells then
            nextStep = 1
        end

        local spell, idx = SS:GetNextValidSpell(spells, nextStep)
        if spell then
            SS.currentStep = idx
            btn:SetAttribute("spell", spell)
        else
            SS.currentStep = 1
            btn:SetAttribute("type", "")
        end
    end)
end
