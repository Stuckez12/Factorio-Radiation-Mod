-- local chunk_func = {}


-- function chunk_func.add_chunk_data(surface, xpos, ypos, chests)
--     local data = {
--         chests: chests,
--         damage: 0,
--         effect_dist: 0
--     }

--     data = chunk_func.calc_chunk_damage(data)

--     storage.chunk_data[surface] = storage.chunk_data[surface] or {}
--     storage.chunk_data[surface][xpos] = storage.chunk_data[surface][xpos] or {}
--     storage.chunk_data[surface][xpos][ypos] = data
-- end


-- function chunk_func.update_chunk_data()

-- end


-- function chunk_func.delete_chunk_data()

-- end


-- function chunk_func.search_chunk(surface, xpos, ypos)
--     local x1 = xpos * 32
--     local y1 = ypos * 32

--     local x2 = x1 + 31
--     local y2 = y1 + 31

--     return surface.find_entities_filtered{
--         area = {
--             {x1, y1},
--             {x2, y2}
--         },
--         type = {"container", "logistic-container"}
--     }
-- end


-- function chunk_func.calc_chunk_damage(chunk_data)
--     if next(chunk_data.chests) == nil then return 0 end

--     local damage = 0

--     for chest in chunk_data.chests do
--         local inv = entity.get_inventory(define)

--         for item, value in pairs(storage.radiation_items) do
--             local count = inv.get_item_count(item)

--             damage = damage + (count * value)
--         end
--     end

--     chunk_data.damage = damage
--     chunk_data.effect_dist = math.min(math.floor((damage / 50) + 0.5) + 1, 8)

--     return chunk_data
-- end


-- function chunk_func.scan_world()
--     if not storage.scan_world and next(storage.chunk_list) == nil then return game.print("Stuckez12 Radiation: Fully Migrated") end

--     if next(storage.chunk_list) == nil then
--         game.print("Stuckez12 Radiation: Migrating older mod version to <= 0.12.0")
--         game.print("Stuckez12 Radiation: Fetching all chunks")
        
--         for _, surface in pairs(game.surfaces) do
--             for chunk in surface.get_chunks() do
--                 table.insert(storage.chunk_list, {
--                     x = chunk.x,
--                     y = chunk.y,
--                     surface = surface
--                 })

--                 storage.chunk_count = storage.chunk_count + 1
--             end
--         end

--         game.print("Stuckez12 Radiation: " .. storage.chunk_count .. " chunks fetched. Now searching 100 chunks per tick for chests")
        
--         storage.scan_world = false

--         return
--     end

--     for i = 1, 100 do
--         local chunk = next(storage.chunk_list)

--         if chunk == nil then game.print("Stuckez12 Radiation: Fully Migrated") return

--         local chests = chunk_func.search_chunk(chunk.surface, chunk.x, chunk.y)

--         if next(chests) == nil then goto continue end

--         chunk_func.add_chunk_data(surface, xpos, ypos, chests)

--         ::continue::
--     end
-- end


-- return chunk_func
