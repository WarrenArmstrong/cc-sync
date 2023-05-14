


local function load_state(filename)
    local state = {}
    local file = io.open(filename,"r")
    for l, line in file:lines() do
        if nil ~= line then
            local var = ""
            local value = tonumber(0)
            -- valid keeps track of if the current line is valid
            local valid = false
            for k, v in string.gmatch(line,"=") do
                if 0 == k then
                    var = v
                elseif 1 == k then
                    value = tonumber(v)
                    if nil ~= value then
                        valid = true
                    end
                else
                    valid = false
                end
            end
            if valid then
                state[var] = value
            else
                print("Int Persist: Bad line[" .. tostring(l) .. "]: " .. line)
            end
        end
    end
    file.close()
    return state
end

local function save_state(file, state)
    local good = true
    for k, v in pairs(state) do
        file.write(k .. "=" .. tostring(v) .. "\n")
    end
    file.flush()
    -- acording to the api these function have no indication
    -- of problems so just assume the write was succesfull?
    return good
end

local function set_index(file, index)
    file.write(tostring(index))
    file.flush()
end

local function get_index(file)
    return tonumber(file.readAll())
end

local function index_to_filename(filename, index)
    return filename .. '.' .. tostring(index)
end

local g_filename = nil

function init(filename, initial_state)
    g_filename = filename
    local state = initial_state
    local index_file = nil
    local index = 0
    if fs.exists(filename) then
        index_file = fs.open(filename, "r")
        index = get_index(index_file)
        index_file.close()
        if nil == index then
            print("Int Persist: Index file corrupt. Reseting index to 0...")
            index_file = fs.open(filename, "w")
            set_index(index_file, 0)
            index_file.close()
            index = 0
        end
        -- get the file that should have the state
        local state_file_name = index_to_filename(filename, index)
        if fs.exists(state_file_name) then        
            state = load_state(state_file_name)
        else
            print("Int Persist: Could not recover from corrupt index file, starting fresh...")
        end
    else
        print("Int Persist: Index file not found assuming fresh state...")
        -- Initilize the file and reopen it for reading
        index_file = fs.open(filename, "w")
        set_index(index_file, 0)
        index_file.close()
    end

    return state
end


function save(state)
    local index_file = nil
    local state_file = nil
    local index = 0

    index_file = fs.open(g_filename, "r")
    if nil == index_file then
        print("Init before calling save!")
        return
    end

    -- after we arquire the index we will need to change it so 
    -- reopen the file for writing
    index = get_index(index_file)
    index_file.close()

    if nil == index then
        print("Int Persist: Corrupted index file. Resetting to zero...")
        -- set it to 1 so it will go back to zero
        -- when it is incramented
        index = 1
    end

    index_file = fs.open(g_filename, "w")

    -- make sure to write to the other index
    -- so we can fall back on the first index if needed
    index = (index + 1) % 2

    -- open the state file for writing
    state_file = fs.open(index_to_filename(g_filename, index), "w")

    save_state(state_file, state)

    state_file.close()

    -- if the previous function finished we are safe to update the index
    set_index(index_file, index)

    index_file.close()
end
