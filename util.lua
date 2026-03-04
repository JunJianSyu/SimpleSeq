SimpleSeq = SimpleSeq or {}
SimpleSeq.VERSION = "1.0.0"

local SS = SimpleSeq

function SS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00CCFFSimpleSeq|r: " .. tostring(msg))
end

function SS:GetProfileKey()
    local _, classToken = UnitClass("player")
    local specIndex = GetSpecialization() or 0
    return classToken .. "-" .. specIndex
end

function SS:IsSpellAvailable(spellName)
    if not spellName or spellName == "" then
        return false
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellName)
        return info ~= nil
    end
    local name = GetSpellInfo(spellName)
    return name ~= nil
end

function SS:GetNextValidSpell(spells, startIndex)
    if not spells or #spells == 0 then
        return nil, nil
    end
    local count = #spells
    for i = 0, count - 1 do
        local idx = ((startIndex - 1 + i) % count) + 1
        local spell = spells[idx]
        if spell and self:IsSpellAvailable(spell) then
            return spell, idx
        end
    end
    return nil, nil
end
