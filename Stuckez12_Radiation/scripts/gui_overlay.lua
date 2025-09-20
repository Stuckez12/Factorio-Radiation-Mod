local gui_overlay = {}


function gui_overlay.create_radiation_display(player)
    local screen_flow = player.gui.screen

    if not screen_flow.overlay then
        local add_overlay = screen_flow.add{
            type = "flow",
            name = "overlay",
            direction = "vertical"
        }

        add_overlay.style.left_padding = 0
        add_overlay.style.right_padding = 0
        add_overlay.style.top_padding = 0
        add_overlay.style.bottom_padding = 0
        add_overlay.style.width = player.display_resolution.width
        add_overlay.style.height = player.display_resolution.height
        add_overlay.style.horizontally_stretchable = true
        add_overlay.style.vertically_stretchable = true
        add_overlay.style.horizontal_align = "center"
        add_overlay.style.vertical_align = "center"
    end

    if not screen_flow.overlay.logo then
        local add_overlay = screen_flow.overlay.add{
            type = "sprite",
            name = "logo",
            sprite = "no_sprite",
            color = {r = 1, g = 0, b = 0, a = 0.5},
            ignored_by_interaction = true
        }
    end
end


function gui_overlay.update_sprite_overlay(player, damage)
    local screen_flow = player.gui.screen

    if not screen_flow.overlay or not screen_flow.overlay.logo then
        create_radiation_display(player)
    end

    local sprite = screen_flow.overlay.logo
    local index = tostring(math.random(1,10))
    local image = "no_sprite"

    if not player.mod_settings["Stuckez12-Radiation-Enable-GUI-Effect"].value then
        sprite.sprite = image

        goto continue
    end

    if damage <= 50 and damage > 0 then
        image = "GUILowRadiation" .. index
    elseif damage <= 250 and damage > 50 then
        image = "GUIMediumRadiation" .. index
    elseif damage > 250 then
        image = "GUIHighRadiation" .. index
    end

    sprite.sprite = image

    ::continue::
end


return gui_overlay
