local disp = peripheral.find("minecraft:dispenser")

function get_used_slots(items)
  local count = 0
  for slot, item in pairs(items.list()) do
    count = count + 1
  end
  return count
end

while true do
  if get_used_slots(disp.list()) >= 8 then
    while get_used_slots(disp.list()) > 0 do
      redstone.setOutput('top', not redstore.getOutput('top'))
      os.sleep(0.1)
    end
  end
os.sleep(10)
end
