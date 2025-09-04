local mod_name = "Stuckez12-Radiation-"

data:extend({
    {
        type = "int-setting",
        name = mod_name .. "Radiation-Radius",
        setting_type = "runtime-global",
        default_value = 12,
        minimum_value = 8,
        maximum_value = 20
    },
    {
        type = "int-setting",
        name = mod_name .. "Protection-Radius",
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 0,
        maximum_value = 125
    }
})
