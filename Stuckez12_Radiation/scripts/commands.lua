local player_management = require("scripts.player_management")
local mod_addons = require("scripts.mod_integrations")

commands.add_command("radiation_add_self", "Add current character to radiation damage list", function(command)
    if command.player_index then
        local player = game.get_player(command.player_index)

        if player and player.valid and player.character.valid then
            player_management.add_character_reference(player.character)

            player.print("Stuckez12 Radiation: Player Character Added To Radiation Calculations")
            log("Player character added to radiation calculations")
        end
    end
end)


commands.add_command("radiation_remove_self", "Removes current character from radiation damage list", function(command)
    if command.player_index then
        local player = game.get_player(command.player_index)

        if player and player.valid and player.character.valid then
            player_management.remove_character_reference(player.character)

            player.print("Stuckez12 Radiation: Player Character Removed From Radiation Calculations")
            log("Player character removed from radiation calculations")
        end
    end
end)


commands.add_command("radiation_display_items", "Logs and prints all items/units that are currently classified as radiative", function(command)
    game.print("Radiative Items: -")
    game.print(serpent.block(storage.radiation_items))
    log("Radiative Items: -")
    log(serpent.block(storage.radiation_items))

    game.print("\nRadiative Fluids: -")
    game.print(serpent.block(storage.radiation_fluids))
    log("Radiative Fluids: -")
    log(serpent.block(storage.radiation_fluids))

    game.print("\nRadiative Units: -")
    game.print(serpent.block(storage.biters))
    log("Radiative Units: -")
    log(serpent.block(storage.biters))
end)


commands.add_command("radiation_refresh", "Refreshes radiation list", function(command)
    mod_addons.integrate_mods()
    game.print("Stuckez12 Radiation: Radiation item list refreshed")
end)
