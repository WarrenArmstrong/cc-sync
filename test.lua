os.loadAPI("int_persist.lua")



local state = {x=24, data=-232, house=32}

state = int_persist.init("test", state)

while true do
    state.x = state.x + 1
    --state.data = state.data
    state.house = state.x + state.house
    int_persist.save()
end