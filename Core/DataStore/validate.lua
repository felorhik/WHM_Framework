-- Author      : bonjo
-- Create Date : 1/12/2023 10:28:05 PM

local function validate_match_condition(match_condition)
    if type(match_condition) ~= "string" then
        error("QUERY ERROR: invalid match condition", 3)
        return false
    end

    if match_condition == "any" then
        return true
    end

    if match_condition == "all" then
        return true
    end

    error("QUERY ERROR: unknown match condition", 3)
    return false
end

local function validate_where(tableName, where)
    if type(tableName) ~= "string" then
        error("QUERY ERROR: invalid table ", 3)
        return false
    end

    if type(where) ~= "table" then
        error("QUERY ERROR: invalid schema ", 3)
        return false
    end

    local isSingle = false
    local isFirst = true
    for i, v in pairs(where) do
        if type(v) == "string" and isFirst then
            return validate_where_row(tableName, where)
        end

        if not validate_where_row(tableName, v) then
            return false
        end

        isFirst = false
    end

    return true
end

local function validate_where_row(tableName, where)
    if type(where[1]) ~= "string" then
        error("QUERY ERROR: invalid index", 3)
        return false
    end

    if not indexes[tableName][where[1]] then
        error("QUERY ERROR: invalid index", 3)
        return false
    end

    if type(where[2]) ~= "string" then
        error("QUERY ERROR: invalid condition", 3)
        return false
    end

    if type(schemas[tableName]) ~= "table" then
        error("QUERY ERROR: no schema defined", 3)
        return false
    end

    if type(where[3]) ~= schemas[tableName][where[1]] then
        if type(where[3]) ~= "nil" then
            error("QUERY ERROR: invalid value type ["..type(where[3]).."] should be ["..schemas[tableName][where[1]].."]", 3)
            return false
        end
    end

    return true
end

local function validate_table(tableName, schema)
    if type(tableName) ~= "string" then
        error("QUERY ERROR: invalid table", 3)
        return false
    end

    if type(schema) ~= "table" then
        error("QUERY ERROR: invalid schema, must be a table", 3)
        return false
    end

    for key, value in pairs(schema) do
        if type(key) ~= "string" or type(value) ~= "string" then
            error("QUERY ERROR: schemas must use strings", 3)
            return false
        end

        if value ~= "string" and value ~= "number" then
            error("QUERY ERROR: invalid schema type", 3)
            return false
        end
    end

    return true
end

local function validate_delete(tableName, data)
    if type(tableName) ~= "string" then
        error("QUERY ERROR: invalid table ", 3)
        return false
    end

    if not tables[tableName] then
        error("QUERY ERROR: "..tableName.." does not exist", 3)
        return false
    end

    if not tables[tableName][uid] then
        error("QUERY ERROR: no record found", 3)
        return false
    end

    return true
end

local function validate_update(tableName, uid, data)
    if type(tableName) ~= "string" then
        error("QUERY ERROR: invalid table ", 3)
        return false
    end

    if not tables[tableName] then
        error("QUERY ERROR: "..tableName.." does not exist", 3)
        return false
    end

    if not tables[tableName][uid] then
        error("QUERY ERROR: no record found", 3)
        return false
    end

    for key, value in pairs(data) do
        if not schemas[tableName][key] then
            error("QUERY ERROR: "..tableName.." has no column "..key, 3)
            return false
        end

        if type(value) ~= schemas[tableName][key] then
            error("QUERY ERROR: "..key.." needs to be a "..schemas[tableName][key], 3)
            return false
        end

        tables[tableName][uid][key] = value
    end

    return true
end

local function validate_insert(tableName, data)
    if type(tableName) ~= "string" then
        error("QUERY ERROR: invalid table ", 3)
        return false
    end

    for key, value in pairs(data) do
        if not schemas[tableName][key] then
            error("QUERY ERROR: "..tableName.." has no column "..key, 3)
            return false
        end

        if type(value) ~= schemas[tableName][key] then
            error("QUERY ERROR: "..key.." needs to be a "..schemas[tableName][key], 3)
            return false
        end
    end

    return true
end