require("scripts.mod_api")
require("scripts.commands")

local radiation_funcs = require("scripts.radiation_damage")
local player_management = require("scripts.player_management")
local mod_addons = require("scripts.mod_integrations")
-- local chunk_func = require("scripts.chunk_func")


-- Global Variables
storage.active_characters = {}
storage.player_connections = {}
storage.radiation_items = storage.radiation_items or {}
storage.radiation_fluids = storage.radiation_fluids or {}
storage.integrated_mods = storage.integrated_mods or {}
-- storage.chunk_data = storage.chunk_data or {}
storage.biters = storage.biters or {}

-- storage.scan_world = storage.scan_world or false
-- storage.chunk_list = storage.chunk_list or {}
-- storage.chunk_count = storage.chunk_count or 0


-- Mod Config
script.on_init(mod_addons.integrate_mods)
script.on_configuration_changed(mod_addons.integrate_mods)


-- Interval damage event
script.on_nth_tick(20, radiation_funcs.player_radiation_damage)
script.on_nth_tick(4, radiation_funcs.update_gui_logo)

-- script.on_nth_tick(1, chunk_func.scan_world)


-- Events when a player character is created
script.on_event(defines.events.on_player_created, player_management.add_player)
script.on_event(defines.events.on_player_respawned, player_management.add_player)
script.on_event(defines.events.on_player_joined_game, player_management.add_player)


-- Events when a player character is destroyed
script.on_event(defines.events.on_player_died, player_management.verify_character_references)


-- -- Other player events
-- script.on_event(defines.events.on_player_changed_position, radiation_funcs.update_character_pos)
