local WHM_DataStore = _G["WHM_DataStore"]

if not WHM_DataStore then
    WHM_DataStore = WHM_DataStore or {}
    _G["WHM_DataStore"] = WHM_DataStore
end

local WHM_Utilities = _G["WHM_Utilities"]
if not WHM_Utilities then
    error("ERROR: Utility Functions Required", 3)
    return
end

local headers = {}
local indexes = {}
local schemas = {}
local tables = {}

local function compare_all_matches(row, matches)
    for uid, count in pairs(matches) do
        if not row[uid] then
            matches[uid] = nil
        else
            matches[uid] = count + row[uid]
        end
    end

    return matches
end

local function compare_any_matches(row, matches)
    for uid, count in pairs(row) do
        if not matches[uid] then
            matches[uid] = count
        else
            matches[uid] = matches[uid] + count
        end
    end

    return matches
end

local function compare_matches(row, matches, match_condition)
    if next(matches) == nil then
        return row
    end

    if match_condition == "all" then
        return compare_all_matches(row, matches)
    end

    return compare_any_matches(row, matches)
end

local function run_where_passed(values, matches)
    for i, uid in pairs(values) do
        if matches[uid] then
            matches[uid] = matches[uid] + 1
        else
            matches[uid] = 1
        end
    end

    return matches
end

local function run_where_row(tableName, index, condition, value, matches)
    matches = matches or {}

    for indexedValue, values in pairs(indexes[tableName][index]) do
        if condition == "=" then
            if indexedValue == value then
                matches = run_where_passed(values, matches)
            end
        elseif condition == ">" then
            if indexedValue > value then
                matches = run_where_passed(values, matches)
            end
        elseif condition == "<" then
            if indexedValue < value then
                matches = run_where_passed(values, matches)
            end
        elseif condition == "!=" then
            if indexedValue ~= value then
                matches = run_where_passed(values, matches)
            end
        elseif condition == ">=" then
            if indexedValue >= value then
                matches = run_where_passed(values, matches)
            end
        elseif condition == "<=" then
            if indexedValue <= value then
                matches = run_where_passed(values, matches)
            end
        end
    end

    return matches
end

local function run_where(tableName, where, matches, match_condition)
    if not validate_where(tableName, where) then
        return
    end

    if not validate_match_condition(match_condition) then
        return
    end

    matches = matches or {}

    local isFirst = true
    local row = {}
    for i, v in pairs(where) do
        currentMatches = {}
        if type(v) == "string" and isFirst then
            row = run_where_row(tableName, where[1], where[2], where[3], row)
            return compare_matches(row, matches, match_condition)
        end

        row = run_where_row(tableName, v[1], v[2], v[3], row)
        matches = compare_matches(row, matches, match_condition)

        isFirst = false
    end

    return matches
end

local function get_matches(query)
    if type(tableName) ~= "string" then
        error("QUERY ERROR: invalid table ", 3)
        return
    end

    if type(query) ~= "table" then
        error("QUERY ERROR: Invalid Query", 3)
        return
    end

    local matches = {}
    if query.where then
        if not query.match_condition then
            query.match_condition = "any"
        end
        matches = run_where(tableName, query.where, matches, query.match_condition)
    end
end

local function build_row(tableName, data, row)
    row = row or {EF_Utilities:uuid()}
    for i, v in pairs(headers[tableName]) do
        if data[v] then
            row[i] = data[v]
        end
    end

    return row
end

local function update_row(tableName, uid, data)
    local row = build_row(tableName, data, tables[tableName][uid])
    local response = render_response_row(tableName, row)

    tables[tableName][uid] = row
    self:indexer():index_row(tableName, response)

    return response
end

function WHM_DataStore:init()
    indexes = {}
    schemas = {}
    tables = {}

    self.registeredEvents = {}

    return self
end

function WHM_DataStore:make_table(tableName, schema)
    if not validate_table(tableName, schema) then
        return
    end

    headers[tableName] = setup_headers(schema)
    tables[tableName] = {}
    schemas[tableName] = setup_schema(schema)
    indexes[tableName] = {}

    self:define_index(tableName, "id")
end

function WHM_DataStore:query(tableName, query, indexOnly)
    local matches = get_matches(tableName, query)

    WHM_Utilities:trigger_event("WHM_DataStore:query", self)

    return build_response(tableName, matches, query.format, indexOnly)
end

function WHM_DataStore:insert(tableName, data)
    if not validate_insert(tableName, data) then
        return
    end

    local row = build_row(tableName, data)
    local response = render_response_row(tableName, row)
    tables[tableName][response.id] = row
    index_row(tableName, response)

    WHM_Utilities:trigger_event("EF_DataStore:insert", self)

    return data
end

function WHM_DataStore:update(tableName, query, data)
    if not validate_update(tableName, uid, data) then
        return
    end

    local matches = get_matches(tableName, query)
    local response = {
        count =
        matches =
    }

    for uid, count in pairs(matches) do
        table.insert(response, update_row(tableName, uid, data))
    end

    WHM_Utilities:trigger_event("WHM_DataStore:update", self)

    return response
end

function WHM_DataStore:delete(tableName, uid)
    if not validate_delete(tableName, uid) then
        return
    end

    self:indexer():clear_index(tableName, response)
    tables[tableName][uid] = nil

    WHM_Utilities:trigger_event("WHM_DataStore:delete", self)
end