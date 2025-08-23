local mod_name = "Stukez12-Radiation-"

data:extend({
  {
    type = "int-setting",
    name = mod_name .. "Radiation-Radius",
    setting_type = "runtime-global",
    default_value = 4,
    minimum_value = 2,
    maximum_value = 20
  },
  {
    type = "int-setting",
    name = mod_name .. "Inventory-Damage-Per-Item",
    setting_type = "runtime-global",
    default_value = 4,
    minimum_value = 1,
    maximum_value = 10
  }
})
