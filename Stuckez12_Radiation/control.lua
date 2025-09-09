require("scripts.mod_api")
require("scripts.commands")

local radiation_funcs = require("scripts.radiation_damage")
local player_management = require("scripts.player_management")
local mod_addons = require("scripts.mod_integrations")


-- Global Variables
storage.active_characters = {}
storage.radiation_items = storage.radiation_items or {}
storage.radiation_fluids = storage.radiation_fluids or {}
storage.integrated_mods = storage.integrated_mods or {}
storage.biters = storage.biters or {}


-- Mod Config
script.on_init(mod_addons.integrate_mods)
script.on_configuration_changed(mod_addons.integrate_mods)


-- Interval damage event
script.on_nth_tick(20, radiation_funcs.player_radiation_damage)


-- Events when a player character is created
script.on_event(defines.events.on_player_created, player_management.add_player)
script.on_event(defines.events.on_player_respawned, player_management.add_player)
script.on_event(defines.events.on_player_joined_game, player_management.add_player)


-- Events when a player character is destroyed
script.on_event(defines.events.on_player_died, player_management.verify_character_references)
