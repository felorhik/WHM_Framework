local WHM_DataStore = _G["WHM_DataStore"]

if not WHM_DataStore then
    WHM_DataStore = WHM_DataStore or {}
    _G["WHM_DataStore"] = WHM_DataStore
end

local _indexes = {}

--index[i]  _indexes[i]--

local top_level_meta = {
    __index = function(t, k)
        error("invalid table reference", 3)
    end,
    __newindex = function(t, k, v)
        error("invalid table reference", 3)
    end
    __mode = function()
    end
    __call = function(t, k)
        indexer(table, index)
        return _indexes[k]
    end
    __metatable = "WHM_DataStore:indexer",
    __len = function(t)
        return 0
    end
    __pairs = function(t)
        local function stateless_iter(t, k)
            local v
            -- Implement your own key,value selection logic in place of next
            k, v = next(t, k)
            if nil ~= v then
                return k, v
            end
        end

        return stateless_iter, t, nil
    end
}

local function index_clear(tableName, rowID)
    if indexes[tableName] then
        for key, index in pairs(indexes[tableName]) do
            if type(index) ~= "table" then
                error("QUERY ERROR: Corrupted index "..key, 3)
                return
            end

            for indexValue, tblUids in pairs(index) do
                if type(tblUids) == "table" then
                    for i, uid in pairs(tblUids) do
                        if uid == rowID then
                            table.remove(indexes[tableName][key][indexValue], i)
                        end
                    end
                end
            end
        end
    end
end

local function index_row(tableName, row)
    index_clear(tableName, row.id)

    if indexes[tableName] then
        for key, index in pairs(indexes[tableName]) do
            if type(index) ~= "table" or type(key) ~= "string" then
                error("QUERY ERROR: Corrupted index "..key, 3)
                return
            end

            if row[key] then
                if type(index[row[key]]) == "table" then
                    table.insert(indexes[tableName][key][row[key]], row.id)
                else
                    indexes[tableName][key][row[key]] = { row.id }
                end
            end
        end
    end
end

function WHM_DataStore:indexer()
    return {
        index_clear = index_clear,
        index_row = index_row
    }
end

function WHM_DataStore:define_index(tableName, key)
    if type(tableName) ~= "string" then
        error("QUERY ERROR: invalid table ", 3)
        return
    end

    if type(key) ~= "string" then
        error("QUERY ERROR: invalid column for index", 3)
        return
    end

    if not schemas[tableName][key] then
        error("QUERY ERROR: invalid column for index", 3)
        return
    end

    indexes[tableName][key] = {}
end