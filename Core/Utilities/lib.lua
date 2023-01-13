local WHM_Utilities = _G["WHM_Utilities"]

if not WHM_Utilities then
    WHM_Utilities = WHM_Utilities or {}
    _G["WHM_Utilities"] = WHM_Utilities
end

local LibStub = _G["LibStub"]
if not LibStub then
    error("ERROR: LibStub Functions Required", 3)
    return
end

local AceConsole_ref = nil;
function EF_Utilities:debug(text, prepend, debug)
    if debug then
        if not AceConsole_ref then
            AceConsole_ref = LibStub("AceConsole-3.0")
        end

        if type(text) == "table" then
            text = table.concat(text, ", ")
        end

        AceConsole_ref:Print(prepend..": "..text)
   end
end

local AceEvent_ref = nil
function WHM_Utilities:events()
    if not AceEvent_ref then
        AceEvent_ref = LibStub("AceEvent-3.0")
    end
    return AceEvent_ref
end

function WHM_Utilities:register_event(event, handler)
    return self:events():RegisterMessage(event, handler)
end
function WHM_Utilities:trigger_event(event, args)
    return self:events():SendMessage(event, args)
end

local random = math.random
function WHM_Utilities:uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

local AceTimer_ref = nil;
function WHM_Utilities:timer()
    if not AceTimer_ref then
        AceTimer_ref = LibStub("AceTimer-3.0")
    end

    return AceTimer_ref
end

function WHM_Utilities:is_compact_frame()
    return CompactRaidFrameContainer:IsShown() or CompactPartyFrame:IsShown()
end

function WHM_Utilities:apply_to_raid_frames(type, callback)
    if CompactRaidFrameContainer.ApplyToFrames then
        CompactRaidFrameContainer:ApplyToFrames("normal", callback)
    end
end

function WHM_Utilities:aura(unit, index)
    local rawAura = UnitAura(unit, index)
    local aura = table.pack(rawAura)

    if not aura[1] then
        return nil
    end

    return {
        name = aura[1],
        icon = aura[2],
        count = aura[3],
        dispelType = aura[4],
        duration = aura[5],
        expirationTime = aura[6],
        source = aura[7],
        isStealable = aura[8],
        nameplateShowPersonal = aura[9],
        spellID = aura[10],
    }
end

function WHM_Utilities:auras(unit)
	local index = 1

	local auras = {}
	while (true) do
	    local aura = self:aura(unit, index)
	    if not aura then
	        break
	    end

	    table.insert(auras, aura)
	    index = index + 1
	end

	return auras
end

function WHM_Utilities:is_unit(unit)
    if not unit
        or type(unit) ~= "string"
        or string.find(unit, "target")
        or string.find(unit, "nameplate")
        or string.find(unit, "pet") then
        return false
    end

    return true
end

local WHM_FrameworkDB = nil
function WHM_Utilities:db()
    if not WHM_FrameworkDB then
        local defaults = {
            profile = {
                debugMode = false,
                modules = {
                    ['**'] = {
                        enabled = false
                    }
                }
            }
        }
        defaults = WHM_Utilities:trigger_event("WHM_FrameworkDB:init", defaults)
        WHM_FrameworkDB = LibStub("AceDB-3.0"):New("WHM_FrameworkDB", defaults)
    end

    return WHM_FrameworkDB
end

local AceConfigRegistry = nil
local AceConfigDialog = nil
function WHM_Utilities:register_config(name, command, defaults)
    if not AceConfigRegistry then
        AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    end

    if not AceConfigDialog then
        AceConfigDialog = LibStub("AceConfigDialog-3.0")
    end

    defaults = WHM_Utilities:trigger_event("WHM_Utilities:register_config", defaults)
    AceConfigRegistry:RegisterOptionsTable(name, function() return defaults end, {command})
    AceConfigDialog:AddToBlizOptions(name, name)
end