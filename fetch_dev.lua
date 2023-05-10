local tArgs = {...}
if #tArgs ~= 1 then
    print("please specify file name to fetch")
    return
end

local file_name = tArgs[1]
local fetch_url = "https://raw.githubusercontent.com/WarrenArmstrong/cc-sync/content-dev/"


local response = http.get(fetch_url .. file_name)

if nil == response then
    print("failed")
    return
end

if "string" == type(response) then
    print("Response: " .. response)
    return
end

local open_file = fs.open(file_name, "w")
open_file.write(response.readAll())
open_file.flush()

print("done")