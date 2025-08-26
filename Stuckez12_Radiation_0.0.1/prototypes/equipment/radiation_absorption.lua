data:extend({
  {
        type = "item",
        name = "radiation-absorption-equipment",
        icon = "__Stuckez12_Radiation__/graphics/icon/absorption.png",
        icon_size = 128,
        place_as_equipment_result = "radiation-absorption-equipment",
        subgroup = "equipment",
        order = "b[battery]-c[radiation-absorption-equipment]",
        stack_size = 8
    },
    {
        type = "battery-equipment",
        name = "radiation-absorption-equipment",
        sprite = {
            filename = "__Stuckez12_Radiation__/graphics/icon/absorption.png",
            width = 128,
            height = 128,
            priority = "medium"
        },
        shape = {
            width = 1,
            height = 1,
            type = "full"
        },
        energy_source = {
            type = "electric",
            buffer_capacity = "1MJ",
            input_flow_limit = "500kW",
            usage_priority = "primary-input"
        },
        categories = {"armor"}
    }
})
