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

storage.entities = {
    "assembling-machine",
    "furnace", 
    "chemical-plant",
    "centrifuge",
    "container",
    "logistic-container",
    "car",
    "cargo-wagon",
    "reactor",
    "rocket-silo",
    "lab",
    "inserter"
}

storage.belt_entities = {
    "transport-belt",
    "underground-belt",
    "splitter"
}

script.on_init(initialise_new_game)


-- Settings Variables
local mod_name = "Stukez12-Radiation-"


-- Mod Functions
function player_radiation_damage(event)
    for _, player in pairs(game.connected_players) do
        if not (player.character and player.valid and player.surface) then goto continue end

        local damage = 0

        damage = player_inventory_damage(player)
        damage = damage + ore_patch_damage(player)
        damage = damage + belt_damage(player)

        ::continue::
    end
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
                        damage = damage + (value * (1 - (distance / R_RADIUS)) * item.count * 0.5)
                    end
                end
            end
        end
    end

    return damage
end


script.on_nth_tick(60, player_radiation_damage)
