function get_contents(branch)
    pathRes = http.get("https://pdhaambzdi.execute-api.us-east-1.amazonaws.com/" .. branch)
    paths = pathRes.readAll()

    for path in string.gmatch(paths, "([^,]+)") do
        print("Downloading: " .. path)
        contentRes = http.get("https://raw.githubusercontent.com/WarrenArmstrong/cc-sync/" .. branch .. "/" .. path)
        content = contentRes.readAll()

        f = fs.open(path, "w")
        f.write(content)
        f.close()
    end
end

local arg1, = ...

if arg1 != nil
    get_cotnets(arg1)
end