-- WHM_Framework is a World of Warcraft® user interface addon.
-- Author      : bonjo
-- Create Date : 1/12/2023 10:09:30 PM
local addonName, addonTable = ...

addonTable.WHM_Framework = LibStub("AceAddon-3.0"):NewAddon("WHM_Framework")

local WHM_Framework = _G["WHM_Framework"]
if not WHM_Framework then
    error("ERROR: Utility Functions Required", 3)
    return
end

local WHM_Framework = addonTable.WHM_Framework

function WHM_Framework:OnInitialize()
    WHM_Utilities:db()
    WHM_DataStore:init()
    WHM_Utilities:register_config("WHM_Framework", "/ef", {
        type = "group",
        childGroups = "tree",
        name = "General Options",
        args  = {
            instructions = {
                type = "description",
                name = "WHM Framework is an addon to simplify apis and make interface modification simple",
                fontSize = "medium",
                order = 1,
            }
        }
    })

    WHM_Modules:set("WHM_Auras-1.0")
    WHM_Utilities:debug("Active")
end

function WHM_Framework:OnEnable()
    WHM_Utilities:debug("Enabled")
end

function WHM_Framework:OnDisable()
    WHM_Utilities:debug("Disabled")
    WHM_Modules:clear()
end