local mod_name = "Stuckez12-Radiation-"

data:extend({
  {
    type = "int-setting",
    name = mod_name .. "Radiation-Radius",
    setting_type = "runtime-global",
    default_value = 4,
    minimum_value = 2,
    maximum_value = 20
  }
})
