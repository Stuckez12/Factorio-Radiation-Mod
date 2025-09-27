for _, player in pairs(game.players) do
    if player.gui.screen.overlay then
        player.gui.screen.overlay.destroy()
    end
end
