require("prototypes.include_equipment")


local sounds = {
    {
        name = "LowRadiation",
        dir = "__Stuckez12_Radiation__/sounds/low_radiation/low-radiation-",
        count = 7
    },
    {
        name = "MediumRadiation",
        dir = "__Stuckez12_Radiation__/sounds/medium_radiation/medium-radiation-",
        count = 7
    },
    {
        name = "HighRadiation",
        dir = "__Stuckez12_Radiation__/sounds/high_radiation/high-radiation-",
        count = 7
    }
}

for _, sound in pairs(sounds) do
    local variations = {}
    
    for i = 1, sound.count do
        table.insert(variations, {
            filename = sound.dir .. i .. ".wav",
            volume = 1.0
        })
    end

    data:extend({
        {
            type = "sound",
            name = sound.name,
            variations = variations
        },
        {
            type = "damage-type",
            name = "radiation"
        }
    })
end
