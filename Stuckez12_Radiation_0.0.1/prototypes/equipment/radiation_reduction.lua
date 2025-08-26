data:extend({
  {
        type = "item",
        name = "radiation-reduction-equipment",
        icon = "__Stuckez12_Radiation__/graphics/icon/reduction.png",
        icon_size = 128,
        place_as_equipment_result = "radiation-reduction-equipment",
        subgroup = "equipment",
        order = "b[battery]-c[radiation-reduction-equipment]",
        stack_size = 8
    },
    {
        type = "battery-equipment",
        name = "radiation-reduction-equipment",
        sprite = {
            filename = "__Stuckez12_Radiation__/graphics/icon/reduction.png",
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
