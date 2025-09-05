local player_management = require("scripts.player_management")

commands.add_command("radiation_add_self", "Add current character to radiation damage list", function(command)
    if command.player_index then
        local player = game.get_player(command.player_index)

        if player and player.valid and player.character.valid then
            player_management.add_character_reference(player.character)

            player.print("Stuckez12 Radiation: Player Character Added To Radiation Calculations")
        end
    end
end)


commands.add_command("radiation_remove_self", "Removes current character from radiation damage list", function(command)
    if command.player_index then
        local player = game.get_player(command.player_index)

        if player and player.valid and player.character.valid then
            player_management.remove_character_reference(player.character)

            player.print("Stuckez12 Radiation: Player Character Removed From Radiation Calculations")
        end
    end
end)