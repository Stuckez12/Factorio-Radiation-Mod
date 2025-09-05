require("scripts.mod_api")
require("scripts.commands")

local radiation_funcs = require("scripts.radiation_damage")
local player_management = require("scripts.player_management")


-- Global Variables
storage.active_characters = storage.active_characters or {}
storage.radiation_items = storage.radiation_items or {
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


-- Interval damage event
script.on_nth_tick(20, radiation_funcs.player_radiation_damage)


-- Events when a player character is created
script.on_event(defines.events.on_player_created, player_management.add_player)
script.on_event(defines.events.on_player_respawned, player_management.add_player)
script.on_event(defines.events.on_player_joined_game, player_management.add_player)

-- Events when a player character is destroyed
script.on_event(defines.events.on_player_died, player_management.verify_character_references)
