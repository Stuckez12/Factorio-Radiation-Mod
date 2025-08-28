require("scripts.mod_api")

-- Global Variables
storage.radiation_items = {
    ["uranium-ore"] = 1,
    ["uranium-238"] = 2,
    ["uranium-235"] = 5,
    ["uranium-fuel-cell"] = 10,
    ["depleted-uranium-fuel-cell"] = 7,
    ["nuclear-fuel"] = 10,
    ["uranium-rounds-magazine"] = 2,
    ["uranium-cannon-shell"] = 3,
    ["explosive-uranium-cannon-shell"] = 4,
    ["atomic-bomb"] = 50
}


storage.belt_entities = {
    "transport-belt",
    "underground-belt",
    "splitter"
}


-- Settings Variables
local mod_name = "Stuckez12-Radiation-"
local playing_sound = 0


-- Mod Functions
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

    for _, entry in ipairs(contents) do
        if entry.name == "radiation-absorption-equipment" then
            absorber_count = entry.count
        end

        if entry.name == "radiation-reduction-equipment" then
            reducer_count = entry.count
        end
    end

    for i = 1, reducer_count do damage = math.max(0, damage * 0.95) end

    damage = math.max(0, damage - (absorber_count * 10))

    return damage / 10
end


function play_sound(sound_name, volume)
    game.play_sound{
        path = sound_name,
        volume_modifier = volume
    }
end


function area_fetch_entities(player, entities)
    local R_RADIUS = settings.global[mod_name .. "Radiation-Radius"].value

    return player.surface.find_entities_filtered{
      area = {
        {player.position.x - R_RADIUS, player.position.y - R_RADIUS},
        {player.position.x + R_RADIUS, player.position.y + R_RADIUS}
      },
      type = entities
    }
end


function player_inventory_damage(player)
    local inventory = player.get_main_inventory()
    local damage = 0

    if not inventory then return 0 end

    for item, value in pairs(storage.radiation_items) do
        local amount = inventory.get_item_count(item)
        damage = damage + (amount * value)
    end

    return damage
end


function ore_patch_damage(player)
    local ore_entities = area_fetch_entities(player, {"resource"})
    local damage = 0

    local R_RADIUS = settings.global[mod_name .. "Radiation-Radius"].value

    for _, resource in pairs(ore_entities) do
        local value = storage.radiation_items[resource.name]

        if not value then goto continue end

        local distance = math.sqrt((resource.position.x - player.position.x)^2 + (resource.position.y - player.position.y)^2)

        if distance <= R_RADIUS then
            damage = damage + (value * (1 - (distance / R_RADIUS)) * math.max(resource.amount / 1000, 1))
        end

        ::continue::
    end

    return damage
end


function belt_damage(player)
    local belt_entities = area_fetch_entities(player, storage.belt_entities)
    local damage = 0

    local R_RADIUS = settings.global[mod_name .. "Radiation-Radius"].value
    
    for _, belt in pairs(belt_entities) do
        for i = 1, belt.get_max_transport_line_index() do
            local line = belt.get_transport_line(i)
            local contents = line.get_contents()

            for _, item in pairs(contents) do
                local value = storage.radiation_items[item.name]

                if value then
                    local distance = math.sqrt((belt.position.x - player.position.x)^2 + (belt.position.y - player.position.y)^2)

                    if distance <= R_RADIUS then
                        damage = damage + math.max(value * (1 - (distance / R_RADIUS)) * item.count, 0)
                    end
                end
            end
        end
    end

    return damage
end


function container_damage(player)
    local container_entities = area_fetch_entities(player, {"container"})
    local damage = 0

    local R_RADIUS = settings.global[mod_name .. "Radiation-Radius"].value

    for _, container in pairs(container_entities) do
        local inv = container.get_inventory(defines.inventory.chest)

        local distance = math.sqrt((container.position.x - player.position.x)^2 + (container.position.y - player.position.y)^2)

        for item, value in pairs(storage.radiation_items) do
            local amount = inv.get_item_count(item)
            damage = damage + math.max(amount * value * (1 - (distance / R_RADIUS)), 0)
        end
    end

    return damage
end


function corpse_damage(player)
    local corpse_entities = area_fetch_entities(player, {"character-corpse"})
    local damage = 0

    local R_RADIUS = settings.global[mod_name .. "Radiation-Radius"].value

    for _, corpse in pairs(corpse_entities) do
        local inv = corpse.get_inventory(defines.inventory.chest)

        local distance = math.sqrt((corpse.position.x - player.position.x)^2 + (corpse.position.y - player.position.y)^2)

        for item, value in pairs(storage.radiation_items) do
            local amount = inv.get_item_count(item)
            damage = damage + math.max(amount * value * (1 - (distance / R_RADIUS)), 0)
        end
    end

    return damage
end


function prevent_spawn_death(player, damage)
    local world_center_distance = math.sqrt((0 - player.position.x)^2 + (0 - player.position.y)^2)

    local P_RADIUS = settings.global[mod_name .. "Protection-Radius"].value

    if world_center_distance <= P_RADIUS then return 0 end

    return damage
end


function building_damage(player)
    local building_entities = area_fetch_entities(player, {"assembling-machine", "rocket-silo", "furnace"})
    local damage = 0

    local R_RADIUS = settings.global[mod_name .. "Radiation-Radius"].value

    for _, building in pairs(building_entities) do
        local inv_in = building.get_inventory(defines.inventory.crafter_input)
        local inv_out = building.get_inventory(defines.inventory.crafter_output)

        local distance = math.sqrt((building.position.x - player.position.x)^2 + (building.position.y - player.position.y)^2)

        for item, value in pairs(storage.radiation_items) do
            damage = damage + math.max(inv_in.get_item_count(item) * value * (1 - (distance / R_RADIUS)), 0)
            damage = damage + math.max(inv_out.get_item_count(item) * value * (1 - (distance / R_RADIUS)), 0)
        end
    end

    return damage
end


local damage_functions = {
    player_inventory_damage,
    ore_patch_damage,
    belt_damage,
    container_damage,
    corpse_damage,
    building_damage
}


function player_radiation_damage(event)
    local damage = 0

    for _, player in pairs(game.connected_players) do
        if not (player.character and player.valid and player.surface) then goto continue end

        for _, fn in pairs(damage_functions) do damage = damage + fn(player) end
        if damage == 0 then goto continue end

        playing_sound = playing_sound + 1

        -- Prevent immediate spawn kill by radiation
        -- by dedicating the world center as radiation free
        damage = prevent_spawn_death(player, damage)

        if damage == 0 then goto sound_end end

        if playing_sound == 1 then
            if damage <= 50 and damage ~= 0 then
                play_sound("LowRadiation", 0.2)
            elseif damage <= 250 then
                play_sound("MediumRadiation", 0.4)
            elseif damage > 250 then
                play_sound("HighRadiation", 0.6)
            end
        end

        ::sound_end::

        -- Equipment resistances
        damage = damage_resistances(player, damage)

        player.character.damage(damage, game.forces.enemy, "radiation")

        ::continue::

        if playing_sound >= 2 then playing_sound = 0 end
    end
end


script.on_nth_tick(30, player_radiation_damage)
