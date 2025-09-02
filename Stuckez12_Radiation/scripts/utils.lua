local utils = {}

function utils.is_item(name) return game.item_prototypes[name] ~= nil end

function utils.distance(entity_1, entity_2) return math.sqrt((entity_1.position.x - entity_2.position.x)^2 + (entity_1.position.y - entity_2.position.y)^2) end

return utils
