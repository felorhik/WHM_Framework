-- Author      : bonjo
-- Create Date : 1/12/2023 10:27:40 PM

local function setup_schema(schema)
    local formattedSchema = {}
    formattedSchema.id = "number"

    for key, value in pairs(schema) do
        formattedSchema[key] = value
    end

    return formattedSchema
end