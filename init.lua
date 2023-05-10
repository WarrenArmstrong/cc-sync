function get_contents(branch)
    paths = http.get("https://pdhaambzdi.execute-api.us-east-1.amazonaws.com/" .. branch).readAll()

    for path in string.gmatch(paths, "([^,]+)") do
        print("Downloading: " .. path)
        content = http.get("https://raw.githubusercontent.com/WarrenArmstrong/cc-sync/" .. branch .. "/" .. path).readAll()

        f = fs.open(path, "w")
        f.write(content)
        f.close()
    end
end

local arg1 = ...

if arg1 ~= nil then
    get_contents(arg1)
end