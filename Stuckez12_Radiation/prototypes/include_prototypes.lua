require("prototypes.equipment.radiation_absorption")
require("prototypes.equipment.radiation_absorption_mk2")
require("prototypes.equipment.radiation_reduction")
require("prototypes.equipment.radiation_reduction_mk2")
require("prototypes.equipment.radiation_suit")
require("prototypes.entities.radiation_wall")

-- Tech Research To Unlock Equipment
data:extend({
    {
        type = "technology",
        name = "radiation-protection",
        icon = "__Stuckez12_Radiation__/graphics/icon/tech.png",
        icon_size = 128,
        prerequisites = {"uranium-mining", "power-armor"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "radiation-absorption-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-reduction-recipe"
            }
        },
        unit = {
            count = 400,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        },
        localised_name = {"technology-name.radiation-protection"},
        localised_description = {"technology-description.radiation-protection"},
        order = "g-e-a"
    },
    {
        type = "technology",
        name = "advanced-radiation-protection",
        icon = "__Stuckez12_Radiation__/graphics/icon/tech.png",
        icon_size = 128,
        prerequisites = {"radiation-protection", "power-armor-mk2", "nuclear-power"},
        effects = {
            {
                type = "unlock-recipe",
                recipe = "radiation-absorption-mk2-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-reduction-mk2-recipe"
            },
            {
                type = "unlock-recipe",
                recipe = "radiation-suit-recipe"
            }
            ,
            {
                type = "unlock-recipe",
                recipe = "radiation-wall-recipe"
            }
        },
        unit = {
            count = 1200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1}
            },
            time = 30
        },
        localised_name = {"technology-name.advanced-radiation-protection"},
        localised_description = {"technology-description.advanced-radiation-protection"},
        order = "g-e-a"
    }
})
