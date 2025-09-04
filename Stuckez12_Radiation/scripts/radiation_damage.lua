local radiation_funcs = {}

-- Import all files
local utils = require("scripts.utils")
local player_management = require("scripts.player_management")

-- Local variables
local crafter_defines = {
    defines.inventory.crafter_input,
    defines.inventory.crafter_output,
    defines.inventory.crafter_modules,
    defines.inventory.crafter_trash
}
local type_defines = {
    ["container"] = {defines.inventory.chest},
    ["logistic-container"] = {defines.inventory.chest, defines.inventory.logistic_container_trash},
    ["character-corpse"] = {defines.inventory.chest},
    ["assembling-machine"] = crafter_defines,
    ["rocket-silo"] = crafter_defines,
    ["furnace"] = crafter_defines,
    ["car"] = {defines.inventory.car_trunk, defines.inventory.car_ammo, defines.inventory.car_trash, defines.inventory.fuel},
    ["spider-vehicle"] = {defines.inventory.spider_trunk, defines.inventory.spider_ammo, defines.inventory.spider_trash},
    ["reactor"] = {defines.inventory.fuel, defines.inventory.burnt_result},
    ["construction-robot"] = {defines.inventory.robot_cargo},
    ["logistic-robot"] = {defines.inventory.robot_cargo},
    ["locomotive"] = {defines.inventory.fuel},
    ["cargo-wagon"] = {defines.inventory.cargo_wagon}
}
local belt_types = {
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true
}


-- Settings variables
local mod_name = "Stuckez12-Radiation-"
local playing_sound = 0


-- Mod functions
function damage_resistances(player, damage)
    if not player then return damage end

    local armor_inv = player.get_inventory(defines.inventory.character_armor)

    if not armor_inv then return damage end

    local armor = armor_inv[1]

    if not armor or not armor.valid_for_read then return damage end

    local grid = armor.grid

    if not grid then return damage end

    local contents = grid.get_contents()

    -- Reduce then absorb radiation damage
    local absorber_count = 0
    local reducer_count = 0
    local reducer_count_mk2 = 0

    for _, entry in ipairs(contents) do
        if entry.name == "radiation-absorption-equipment" then
            absorber_count = absorber_count + entry.count
        elseif entry.name == "radiation-absorption-equipment-mk2" then
            absorber_count = absorber_count + entry.count + entry.count
        end

        if entry.name == "radiation-reduction-equipment" then
            reducer_count = reducer_count + entry.count
        elseif entry.name == "radiation-reduction-equipment-mk2" then
            reducer_count_mk2 = entry.count
        end
    end

    for i = 1, reducer_count_mk2 do damage = math.max(0, damage * 0.6) end
    for i = 1, reducer_count do damage = math.max(0, damage * 0.8) end

    damage = math.max(0, damage - (absorber_count * 10))

    return damage
end


function play_sound(sound_name, volume, in_sim)
    game.play_sound{
        path = sound_name,
        volume_modifier = volume
    }
end


function area_fetch_entities(player, entities)
    local radius = settings.global[mod_name .. "Radiation-Radius"].value

    if storage.sim_dist then radius = storage.sim_dist end

    return player.surface.find_entities_filtered{
        area = {
            {player.position.x - radius, player.position.y - radius},
            {player.position.x + radius, player.position.y + radius}
        },
        type = entities
    }
end


function player_inventory_damage(player)
    local damage = 0

    local inv_types = {
        defines.inventory.character_main,
        defines.inventory.character_guns,
        defines.inventory.character_ammo,
        defines.inventory.character_armor,
        defines.inventory.character_vehicle,
        defines.inventory.character_trash
    }

    for _, define in pairs(inv_types) do
        local inv = player.get_inventory(define)

        if not inv then goto continue end

        for item, value in pairs(storage.radiation_items) do
            local count = inv.get_item_count(item)

            damage = damage + math.max(count * value, 0)
        end

        ::continue::
    end

    return damage
end


function ore_patch_damage(player, resource)
    local value = storage.radiation_items[resource.name]

    if not value then return 0 end

    local dist_percent = calculate_distance_percent(player, resource)

    if dist_percent == 0 then return 0 end

    return value * dist_percent * math.max(resource.amount / 1000, 1)
end


function belt_damage(player, belt)
    local damage = 0

    local radius = settings.global[mod_name .. "Radiation-Radius"].value

    for i = 1, belt.get_max_transport_line_index() do
        local line = belt.get_transport_line(i)
        local contents = line.get_contents()

        for _, item in pairs(contents) do
            local value = storage.radiation_items[item.name]

            if value then
                local distance = utils.distance(player, belt)

                if distance <= radius then
                    damage = damage + math.max(value * (1 - (distance / radius)) * item.count, 0)
                end
            end
        end
    end

    return damage
end


function prevent_spawn_death(player, damage)
    local world_center_distance = math.sqrt((0 - player.position.x)^2 + (0 - player.position.y)^2)

    local protection_radius = settings.global[mod_name .. "Protection-Radius"].value

    if world_center_distance <= protection_radius then return 0 end

    return damage
end


function calculate_distance_percent(player, entity)
    local radius = settings.global[mod_name .. "Radiation-Radius"].value

    if storage.sim_dist then radius = storage.sim_dist end

    local distance = utils.distance(player, entity)

    return math.max(1 - (distance / radius), 0)
end


function calculate_entity_radiation_damage(player, entity, inv, damage)
    local dist_percent = calculate_distance_percent(player, entity)

    for item, value in pairs(storage.radiation_items) do
        local count = inv.get_item_count(item)

        damage = damage + math.max(count * value * dist_percent, 0)
    end

    return damage
end


function calculate_damage(player)
    local entity_types = {
        "resource",
        "transport-belt",
        "underground-belt",
        "splitter",
        "container",
        "logistic-container",
        "character-corpse",
        "assembling-machine",
        "rocket-silo",
        "furnace",
        "car",
        "spider-vehicle",
        "reactor",
        "item-entity",
        "construction-robot",
        "logistic-robot",
        "locomotive",
        "cargo-wagon",
        "inserter"
    }

    local entities = area_fetch_entities(player, entity_types)
    local damage = 0

    for i=1, #entities do
        local entity = entities[i]

        if belt_types[entity.type] then
            damage = damage + belt_damage(player, entity)

        elseif entity.type == "resource" then
            damage = damage + ore_patch_damage(player, entity)

        elseif entity.type == "item-entity" then
            if entity.valid and entity.stack and entity.stack.valid_for_read then
                local item_name = entity.stack.name
                local count = entity.stack.count

                local value = storage.radiation_items[item_name]

                if value then
                    local dist_percent = calculate_distance_percent(player, entity)

                    damage = damage + (count * value * dist_percent)
                end
            end

        elseif entity.type == "inserter" then
            if entity.held_stack.valid_for_read then
                local value = storage.radiation_items[entity.held_stack.name]

                if value then
                    local dist_percent = calculate_distance_percent(player, entity)

                    damage = damage + (entity.held_stack.count * value * dist_percent)
                end
            end

        else
            local all_defines = type_defines[entity.type]

            if all_defines then 
                for _, define in pairs(all_defines) do
                    local inv = entity.get_inventory(define)

                    if inv then damage = calculate_entity_radiation_damage(player, entity, inv, damage) end
                end
            end
        end
    end

    return damage + player_inventory_damage(player)
end


local health_text = nil


function radiation_funcs.player_radiation_damage(event)
    local damage = 0
    local player = nil

    storage.active_characters = storage.active_characters or {}

    -- Do only when no characters have been detected
    if next(storage.active_characters) == nil then
        player_management.add_all_player_references()
    end

    for _, character in pairs(storage.active_characters) do
        if not (character.valid and character.surface) then goto continue end

        damage = calculate_damage(character)

        if damage == 0 then goto continue end

        playing_sound = playing_sound + 1

        -- Prevent immediate spawn kill by radiation
        -- by dedicating the world center as radiation free
        if not storage.sim_char then -- Skip when in simulation
            damage = prevent_spawn_death(character, damage)
        end

        if damage == 0 then goto continue end

        damage = damage / 15

        if playing_sound == 1 then
            if damage <= 50 and damage ~= 0 then
                play_sound("LowRadiation", 0.2)
            elseif damage <= 250 then
                play_sound("MediumRadiation", 0.4)
            elseif damage > 250 then
                play_sound("HighRadiation", 0.6)
            end
        end

        -- Equipment resistances
        damage = damage_resistances(character, damage)

        character.damage(damage, game.forces.enemy, "Stuckez12-radiation")

        ::continue::

        if playing_sound >= 2 then playing_sound = 0 end
    end
end


return radiation_funcs
