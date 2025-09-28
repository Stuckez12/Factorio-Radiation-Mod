local chunk_func = {}


-- File variables
local damage_reduction = 15


-- Settings variables
local mod_name = "Stuckez12-Radiation-"


function chunk_func.add_chunk_data(surface, xpos, ypos, chest_data)
    local data = {
        chest = chest_data,
        damage = 0,
        effect_dist = 0,
        last_updated = game.tick
    }

    data = chunk_func.calc_chunk_damage(data)

    storage.chunk_data[surface] = storage.chunk_data[surface] or {}
    storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
    storage.chunk_data[surface][xpos][ypos] = data
end


function chunk_func.update_chunk_data(surface, xpos, ypos)
    local chunk = storage.chunk_data[surface][xpos][ypos]
    local chests = chunk.chest

    local damage = 0

    for _, chest in pairs(chests) do
        if not chest.valid then goto invalid end

        local inv = chest.get_inventory(defines.inventory.chest)

        for i = 1, #inv do
            local item = inv[i]

            if item and item.valid_for_read then
                local value = storage.radiation_items[item.name]

                if not value then goto skip_item end

                damage = damage + (item.count * value)
            end

            ::skip_item::
        end

        ::invalid::
    end

    local chunk_radius = settings.global[mod_name .. "Chunk-Effect-Radius"].value

    chunk.damage = damage
    chunk.effect_dist = math.min(math.floor(damage / (50 * damage_reduction)), chunk_radius)
    chunk.last_updated = game.tick
end


function chunk_func.delete_chunk_data(surface, xpos, ypos)
    storage.chunk_data[surface][xpos][ypos] = nil
end


function chunk_func.calc_chunk_damage(chunk_data)
    if not chunk_data then return chunk_data end
    if not chunk_data.chests then return chunk_data end
    if next(chunk_data.chests) == nil then return chunk_data end

    local damage = 0

    for chest in chunk_data.chests do
        local inv = entity.get_inventory(define)

        for item, value in pairs(storage.radiation_items) do
            local count = inv.get_item_count(item)

            damage = damage + (count * value)
        end
    end

    chunk_data.damage = damage
    chunk_data.effect_dist = math.min(math.floor((damage / 50) + 0.5) + 1, 8)

    return chunk_data
end


function chunk_func.update_concurrent_damage(character)
    storage.player_connections = storage.player_connections or {}

    local char_data = storage.player_connections[character]

    if not char_data then return end

    local pos = {
        x = math.floor(character.position.x / 32),
        y = math.floor(character.position.y / 32)
    }
    local surface = character.surface.index

    local chunk_radius = settings.global[mod_name .. "Chunk-Effect-Radius"].value

    if pos.x == char_data.chunk.x and pos.y == char_data.chunk.y then return end

    local time_12m = 60 * 60
    local concurrent_damage = 0
    local diameter = (chunk_radius * 2) + 1

    storage.chunk_data = storage.chunk_data or {}

    if not storage.chunk_data[surface] then return end

    for x = (pos.x - chunk_radius), diameter do
        if not storage.chunk_data[surface][x] then goto large_continue end

        for y = (pos.y - chunk_radius), diameter do
            if not storage.chunk_data[surface][x][y] then goto continue end

            local chunk = storage.chunk_data[surface][x][y]

            local chests = chunk.chest or {}
            local damage = 0

            if chunk.last_updated + time_12m >= game.tick then goto calc_damage end
            if storage.chunk_update_limit.current >= storage.chunk_update_limit.max then goto calc_damage end

            storage.chunk_update_limit.current = storage.chunk_update_limit.current + 1

            for _, chest in pairs(chests) do
                if not chest.valid then goto invalid end

                local inv = chest.get_inventory(defines.inventory.chest)

                for i = 1, #inv do
                    local item = inv[i]

                    if item and item.valid_for_read then
                        local value = storage.radiation_items[item.name]

                        if not value then goto skip_item end

                        damage = damage + (item.count * value)
                    end

                    ::skip_item::
                end

                ::invalid::
            end

            chunk.last_updated = game.tick
            chunk.damage = damage
            chunk.effect_dist = math.min(math.floor(damage / 50), chunk_radius)

            ::calc_damage::

            local dx = math.abs(pos.x - x)
            local dy = math.abs(pos.y - y)
            local chunk_dist = math.max(dx, dy)

            local percent = (chunk_dist / chunk.effect_dist)

            if percent ~= percent then percent = 0 end

            local dist_percent = math.max(1 - percent, 0)

            local character_damage = math.max(damage * (dist_percent^2.75), 0)

            concurrent_damage = concurrent_damage + character_damage

            ::continue::
        end

        ::large_continue::
    end

    char_data.concurrent_damage = concurrent_damage
    char_data.chunk.x = pos.x
    char_data.chunk.y = pos.y
end


function chunk_func.chest_placed(event)
    local entity = event.entity

    if entity.type ~= "container" and entity.type ~= "logistic-container" then return end

    chunk_func.add_chest(entity.surface.index, math.floor(entity.position.x / 32), math.floor(entity.position.y / 32), entity)
end


function chunk_func.add_chest(surface, xpos, ypos, chest)
    storage.chunk_data = storage.chunk_data or {}
    storage.chunk_data[surface] = storage.chunk_data[surface] or {}
    storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
    if not storage.chunk_data[surface][xpos][ypos] then 
        chunk_func.add_chunk_data(surface, xpos, ypos, {chest})
    
    end

    local chunk = storage.chunk_data[surface][xpos][ypos]

    table.insert(chunk.chest, chest)
end


function chunk_func.chest_removed(event)
    local entity = event.entity

    if entity.type ~= "container" and entity.type ~= "logistic-container" then return end

    remove_chest(entity.surface.index, math.floor(entity.position.x / 32), math.floor(entity.position.y / 32), entity)
end


function remove_chest(surface, xpos, ypos, chest)
    storage.chunk_data = storage.chunk_data or {}
    storage.chunk_data[surface] = storage.chunk_data[surface] or {}
    storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
    if not storage.chunk_data[surface][xpos][ypos] then return end

    local chunk = storage.chunk_data[surface][xpos][ypos]

    chunk.chest[chest.unit_number] = nil

    for i, entity in pairs(chunk.chest) do
        if not entity.valid then
            table.remove(chunk.chest, i)
        end
    end

    if not next(chunk.chest) then
        chunk_func.delete_chunk_data(surface, xpos, ypos)
    end
end


return chunk_func
