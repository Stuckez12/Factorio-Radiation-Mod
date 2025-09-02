local utils = require("scripts.utils")

local remote_error = "Stuckez12-Radiation Mod API Error:\n"

local function add_radioactive_item(item, value)
    -- item validation
    if type(item) ~= "string" then
        error(remote_error .. "Provided item name is invalid. Expected a string not a " .. type(item))
    end
    
    if not utils.is_item(item) then
        error(remote_error .. "Provided item name: " .. item .. "is not a valid item.")
    end
    
    -- radiation value validaton
    if type(value) ~= "number" then
        error(remote_error .. "Provided radiation value for item: " .. item .. " is invalid. Expected a number not a " .. type(value))
    end

    if value <= 0 or value > 1000 then
        error(remote_error .. "Provided radiation value for item: " .. item .. " must be a positive number between 0 and 1000. (0 < value <= 1000)")
    end

    storage.Radioactive_Items[item] = value
    log("Stuckez12-Radiation Mod API >>> Item: " .. item .. " added to radiation list with value: " .. tostring(value))
end

local function remove_radioactive_item(item)
    storage.Radioactive_Items[item] = nil
    log("Stuckez12-Radiation Mod API >>> Item: " .. item .. " removed from radiation list")
end

remote.add_interface("Stuckez12_Radiation", {
    add_radioactive_item = add_radioactive_item,
    remove_radioactive_item = remove_radioactive_item
})
