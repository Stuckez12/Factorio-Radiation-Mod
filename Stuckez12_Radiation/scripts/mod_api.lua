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

    storage.radiation_items[item] = value
    log("Stuckez12-Radiation Mod API >>> Item: " .. item .. " added to radiation list with value: " .. tostring(value))
end


local function add_radioactive_resource(resource, value)
    -- resource validation
    if type(resource) ~= "string" then
        error(remote_error .. "Provided resource name is invalid. Expected a string not a " .. type(resource))
    end
    
    if not utils.is_resource(resource) then
        error(remote_error .. "Provided resource name: " .. resource .. "is not a valid resource.")
    end
    
    -- radiation value validaton
    if type(value) ~= "number" then
        error(remote_error .. "Provided radiation value for resource: " .. resource .. " is invalid. Expected a number not a " .. type(value))
    end

    if value <= 0 or value > 1000 then
        error(remote_error .. "Provided radiation value for resource: " .. resource .. " must be a positive number between 0 and 1000. (0 < value <= 1000)")
    end

    storage.radiation_items[resource] = value
    log("Stuckez12-Radiation Mod API >>> Resource: " .. resource .. " added to radiation list with value: " .. tostring(value))
end


local function remove_radioactive_item(item)
    storage.radiation_items[item] = nil
    log("Stuckez12-Radiation Mod API >>> Item/Resource: " .. item .. " removed from radiation list")
end


remote.add_interface("Stuckez12_Radiation", {
    add_radioactive_item = add_radioactive_item,
    remove_radioactive_item = remove_radioactive_item
})
