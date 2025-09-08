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
    ["cargo-wagon"] = {defines.inventory.cargo_wagon},
    ["ammo-turret"] = {defines.inventory.turret_ammo}
}
local belt_types = {
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true
}
local damage_reduction = 15
local wall_resistance = 200


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
            {math.floor(player.position.x) - radius, math.floor(player.position.y) - radius},
            {player.position.x + radius, player.position.y + radius}
        },
        type = entities
    }
end


function bresenham_wall_grid_count(wall_grid, dest_x, dest_y, p_x, p_y)
    local wall_count = 0;

    local dx = math.abs(p_x - dest_x)
    local dy = math.abs(p_y - dest_y)
    local x, y = dest_x, dest_y

    local sx, sy
    if dest_x < p_x then sx = 1 else sx = -1 end
    if dest_y < p_y then sy = 1 else sy = -1 end

    if dx > dy then
        local err = math.floor(dx / 2)

        while x ~= p_x do
            if wall_grid[x][y] then wall_count = wall_count + 1 end

            err = err - dy

            if err < 0 then
                y = y + sy
                err = err + dx
            end

            x = x + sx
        end
    else
        local err = math.floor(dy / 2)

        while y ~= p_y do
            if wall_grid[x][y] then wall_count = wall_count + 1 end

            err = err - dx

            if err < 0 then
                x = x + sx
                err = err + dy
            end
            y = y + sy
        end
    end

    if wall_grid[x][y] then wall_count = wall_count + 1 end

    return wall_count
end


function radiation_wall_block(player, entity, wall_grid, wall_found, damage)
    if not wall_found then return damage end

    local player_pos = settings.global[mod_name .. "Radiation-Radius"].value + 1

    local start_x = math.floor(player.position.x) - settings.global[mod_name .. "Radiation-Radius"].value
    local start_y = math.floor(player.position.y) - settings.global[mod_name .. "Radiation-Radius"].value

    local x_pos = (math.floor(entity.position.x) - start_x) + 1
    local y_pos = (math.floor(entity.position.y) - start_y) + 1

    local wall_count = bresenham_wall_grid_count(wall_grid, x_pos, y_pos, player_pos, player_pos)

    return math.max(damage - (wall_count * wall_resistance * damage_reduction), 0)
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

    return math.max((1 - (distance / radius)) ^ 2, 0)
end


function calculate_entity_radiation_damage(player, entity, inv, wall_grid, wall_found, damage)
    local dist_percent = calculate_distance_percent(player, entity)
    local calculated_damage = 0

    for item, value in pairs(storage.radiation_items) do
        local count = inv.get_item_count(item)

        calculated_damage = calculated_damage + math.max(count * value * dist_percent, 0)
    end

    return damage + radiation_wall_block(player, entity, wall_grid, wall_found, calculated_damage)
end


function get_wall_grid(player)
    local wall_entities = area_fetch_entities(player, {"wall"})
    local wall_grid = {}

    local radius = (settings.global[mod_name .. "Radiation-Radius"].value * 2) + 1

    for i = 1, radius do
        wall_grid[i] = {}

        for j = 1, radius do
            wall_grid[i][j] = false
        end
    end

    local start_x = math.floor(player.position.x) - settings.global[mod_name .. "Radiation-Radius"].value
    local start_y = math.floor(player.position.y) - settings.global[mod_name .. "Radiation-Radius"].value

    local detected_wall = false

    for i=1, #wall_entities do
        local wall = wall_entities[i]

        local x_pos = (math.floor(wall.position.x) - start_x) + 1
        local y_pos = (math.floor(wall.position.y) - start_y) + 1

        wall_grid[x_pos][y_pos] = true
        detected_wall = true
    end

    return wall_grid, detected_wall
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
        "inserter",
        "ammo-turret"
    }

    local entities = area_fetch_entities(player, entity_types)
    local wall_grid, wall_found = get_wall_grid(player)
    local damage = 0
    local calculated_damage = 0

    for i=1, #entities do
        local entity = entities[i]

        if belt_types[entity.type] then
            calculated_damage = belt_damage(player, entity)

            damage = damage + radiation_wall_block(player, entity, wall_grid, wall_found, calculated_damage)

        elseif entity.type == "resource" then
            calculated_damage = ore_patch_damage(player, entity)

            damage = damage + radiation_wall_block(player, entity, wall_grid, wall_found, calculated_damage)

        elseif entity.type == "item-entity" then
            if entity.valid and entity.stack and entity.stack.valid_for_read then
                local item_name = entity.stack.name
                local count = entity.stack.count

                local value = storage.radiation_items[item_name]

                if value then
                    local dist_percent = calculate_distance_percent(player, entity)

                    calculated_damage = count * value * dist_percent

                    damage = damage + radiation_wall_block(player, entity, wall_grid, wall_found, calculated_damage)
                end
            end

        elseif entity.type == "inserter" then
            if entity.held_stack.valid_for_read then
                local value = storage.radiation_items[entity.held_stack.name]

                if value then
                    local dist_percent = calculate_distance_percent(player, entity)

                    calculated_damage = (entity.held_stack.count * value * dist_percent)

                    damage = damage + radiation_wall_block(player, entity, wall_grid, wall_found, calculated_damage)
                end
            end

        else
            local all_defines = type_defines[entity.type]

            if all_defines then 
                for _, define in pairs(all_defines) do
                    local inv = entity.get_inventory(define)

                    if inv then damage = calculate_entity_radiation_damage(player, entity, inv, wall_grid, wall_found, damage) end
                end
            end
        end
    end

    return damage + player_inventory_damage(player)
end


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

        damage = damage / damage_reduction

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
