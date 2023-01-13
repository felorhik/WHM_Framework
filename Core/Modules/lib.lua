local WHM_Modules = _G["WHM_Modules"]

if not WHM_Modules then
    WHM_Modules = WHM_Modules or {}
    _G["WHM_Modules"] = WHM_Modules
end

local WHM_Modules = _G["WHM_Modules"]
if not WHM_Modules then
    error("ERROR: Utility Functions Required", 3)
    return
end

WHM_Modules.modules = {}

function WHM_Modules:set(module)
    WHM_Modules.modules[module] = LibStub(module)
    WHM_Modules:trigger_event("WHM_Modules:set", module)
end

function WHM_Modules:get(module)
    return WHM_Modules.modules[module]
end

function WHM_Modules:remove(module)
    WHM_Modules.modules[module] = nil
    WHM_Modules:trigger_event("WHM_Modules:remove", module)
end