-- Author      : bonjo
-- Create Date : 1/12/2023 10:29:57 PM

local WHM_Auras, oldrev = LibStub:NewLibrary("WHM_Auras-1.0", 1)
if not WHM_Auras then return end

local WHM_Utilities = _G["EF_Utilities"]
if not WHM_Utilities then
    error("ERROR: Utility Functions Required", 3)
    return
end

local WHM_DataStore = _G["WHM_DataStore"]
if not WHM_DataStore then
    error("ERROR: Utility Functions Required", 3)
    return
end

local evokerSpells = {
    366155, --reversion
    367364, --reversion with echo
    364343 --echo
}

local function update_unit_auras(unit)
	if not WHM_Utilities:is_unit(unit) then
		return
	end

	local auras = WHM_Utilities:auras(unit)
	for index, aura in pairs(auras) then
	    local tableData = {
            name = aura.name,
            icon = aura.icon,
            count = aura.count,
            unit = aura.unit,
            duration = aura.duration,
            expirationTime = aura.expirationTime,
            source = aura.source,
            spellID = aura.spellID
        }

        local result = WHM_DataStore:query("auras", {
            where = {
                {"unit", "=", tableData.unit},
                {"spellID", "=", tableData.spellID},
                {"icon", "=", tableData.icon}
            },
            match_condition = "all"
        }, true)

        if result.count > 0 then
            for uid, matches in pairs(result.entries) do
                WHM_DataStore:update("auras", uid, tableData)
            end
        else
            WHM_DataStore:insert("auras", tableData)
        end
	end
end

function WHM_Auras:update()
    if not WHM_Utilities:is_compact_frame() then
		return
	end

    WHM_Utilities:apply_to_raid_frames("normal",
        function(frame)
            update_unit_auras(frame.unit)
        end)
end

function WHM_Auras:init()
    WHM_DataStore:make_table("auras", {
        name = "string",
        icon = "number",
        count = "number",
        unit = "string",
        duration = "number",
        expirationTime = "number",
        source = "string",
        spellID = "number"
    })

    WHM_DataStore:define_index("auras", "spellID")
    WHM_DataStore:define_index("auras", "unit")
    WHM_DataStore:define_index("auras", "source")
    WHM_DataStore:define_index("auras", "icon")


    self.updateTimer = WHM_Utilities:timer():ScheduleRepeatingTimer("update", 0.5)

    --add setup to enable / disable aura collection
    return self
end

function WHM_Auras:destroy()
    WHM_Utilities:timer():CancelTimer(self.updateTimer)

    return self
end

