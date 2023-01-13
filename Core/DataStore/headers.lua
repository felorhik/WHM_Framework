-- Author      : bonjo
-- Create Date : 1/12/2023 10:26:57 PM

local function setup_headers(schema)
    local headers = {}
    table.insert(headers, "id")

    for key, value in pairs(schema) do
        table.insert(headers, key)
    end

    return headers
end