local chunk_func = {}


function chunk_func.add_chunk_data(surface, xpos, ypos, chest_data)
    local data = {
        ["chest"] = chest_data,
        ["damage"] = 0,
        ["effect_dist"] = 0
    }

    data = chunk_func.calc_chunk_damage(data)

    storage.chunk_data[surface] = storage.chunk_data[surface] or {}
    storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
    storage.chunk_data[surface][xpos][ypos] = data
end


function chunk_func.update_chunk_data(surface, xpos, ypos)
    local chunk_data = storage.chunk_data[surface][xpos][ypos]
end


function chunk_func.delete_chunk_data(surface, xpos, ypos)
    storage.chunk_data[surface][xpos][ypos] = nil
end


function chunk_func.calc_chunk_damage(chunk_data)
    if not chunk_data then return 0 end
    if not chunk_data.chests then return 0 end
    if next(chunk_data.chests) == nil then return 0 end

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


function chunk_func.apply_chunk_damage(chunk_data)
    -- equation for chunk damage to apply to character
    -- damage * ((1 - (chunk_dist / effect_dist))^2.75)

    -- chunk dist is how far away chunk wise the player is from the chunk radiation source
    -- will use bresenham_wall_grid_count but for chunks instead
end


return chunk_func
