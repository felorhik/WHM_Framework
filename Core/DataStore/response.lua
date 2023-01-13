-- Author      : bonjo
-- Create Date : 1/12/2023 10:27:20 PM

local function render_response_row(tableName, row, format)
    local data = {}
    format = format or "*"

    if format == "*" then
        for i, v in pairs(headers[tableName]) do
            data[v] = row[i]
        end
    end

    return data
end

local function build_response(tableName, matches, format, indexOnly)
    local response = {
        matches = 0,
        count = 0,
        entries = {}
    }

    for uid, count in pairs(matches) do
        response.matches = response.matches + count
        response.count = response.count + 1
    end

    if indexOnly then
        response.entries = matches
    end

    for uid, count in pairs(matches) do
        response.matches = response.matches + count
        if not indexOnly then
            table.insert(response.entries, render_response_row(tables[tableName][uid], format))
        end
    end

    return response
end