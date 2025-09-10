local mod_addons = {}


function Cerys_Compatible()
    storage.radiation_items["cerys-radioactive-module-decayed"] = 4
    storage.radiation_items["cerys-radioactive-module-charged"] = 9
    storage.radiation_items["plutonium-rounds-magazine"] = 8
    storage.radiation_items["plutonium-238"] = 7
    storage.radiation_items["plutonium-239"] = 4
    storage.radiation_items["plutonium-fuel"] = 14
    storage.radiation_items["mixed-oxide-fuel-cell"] = 18
    storage.radiation_items["depleted-mixed-oxide-fuel-cell"] = 8
    storage.radiation_items["cerys-nuclear-scrap"] = 2
    storage.radiation_items["cerysian-science-pack"] = 6
    storage.radiation_items["cerys-neutron-bomb"] = 25
    storage.radiation_items["cerys-hydrogen-bomb"] = 80

    -- Fluids
    storage.radiation_fluids["mixed-oxide-waste-solution"] = 1

    log("Cerys Mod - Items Added")
end


function PlutoniumEnergy_Compatible()
    storage.radiation_items["plutonium-238"] = 7
    storage.radiation_items["plutonium-239"] = 4
    storage.radiation_items["plutonium-fuel-cell"] = 16
    storage.radiation_items["depleted-plutonium-fuel-cell"] = 10
    storage.radiation_items["MOX-fuel-cell"] = 14
    storage.radiation_items["depleted-MOX-fuel-cell"] = 9
    storage.radiation_items["breeder-fuel-cell"] = 15
    storage.radiation_items["depleted-breeder-fuel-cell"] = 11
    storage.radiation_items["plutonium-atomic-artillery-shell"] = 75
    storage.radiation_items["plutonium-rounds-magazine"] = 8
    storage.radiation_items["plutonium-cannon-shell"] = 7
    storage.radiation_items["explosive-plutonium-cannon-shell"] = 8
    storage.radiation_items["plutonium-fuel"] = 14

    log("PlutoniumEnergy Mod - Items Added")
end


function Bobs_Warfare_Compatibility()
    storage.radiation_items["bob-uranium-bullet"] = 2
    storage.radiation_items["bob-atomic-artillery-shell"] = 60
    storage.radiation_items["bob-shotgun-uranium-shell"] = 2
    storage.radiation_items["bob-uranium-bullet-projectile"] = 2
    
    log("Bob's Warfare Mod - Items Added")
end


local compatible_mod_funcs = {
    ["Cerys-Moon-of-Fulgora"] = Cerys_Compatible,
    ["PlutoniumEnergy"] = PlutoniumEnergy_Compatible,
    ["bobwarfare"] = Bobs_Warfare_Compatibility
}


function mod_addons.integrate_mods()
    storage.radiation_items = {
        ["uranium-ore"] = 1,
        ["uranium-238"] = 2,
        ["uranium-235"] = 5,
        ["uranium-fuel-cell"] = 10,
        ["depleted-uranium-fuel-cell"] = 7,
        ["nuclear-fuel"] = 10,
        ["uranium-rounds-magazine"] = 2,
        ["uranium-cannon-shell"] = 3,
        ["explosive-uranium-cannon-shell"] = 4,
        ["atomic-bomb"] = 50
    }

    storage.radiation_fluids = {}

    storage.biters = {
        ["big-biter"] = 10,
        ["behemoth-biter"] = 50,
        ["big-spitter"] = 8,
        ["behemoth-spitter"] = 40
    }

    for name, version in pairs(script.active_mods) do
        if compatible_mod_funcs[name] then
            compatible_mod_funcs[name]()
        end
    end

    log("Init Func Complete")
end


return mod_addons
