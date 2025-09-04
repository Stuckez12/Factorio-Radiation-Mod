# Factorio Radiation Mod

A simple world environment addon that includes radiation as a new hazard.
Inspired by TibsRadiationMod


# Development Roadmap
## Version 0.9
Add in a radiation resistant wall that can be incorporated to factory designs and protection.
- Each wall between the player character reduces radiation damage by 500 (value subject to change)
DEV NOTE: further reduce the number of calls to the radiation calculation per player. if they dont move, save and re apply damage (robots/trains/spidertron can affect damage (is the filter area check the main issue of performance decrease))

## Version 0.10
Behemouth biters emit radiation themselves (cause they're green why else)
- If possible, their corpses will emit radiation as well
Construction and logistic robots take radiation damage when holding radioactive items (applying the same radiation calculations used on characters to robots will kill performance. Also to discourage the use of moving radioactive items using robots short distances)

## Version 0.11
Add pipe contents to be included in radiation damage.
Mainly for mods that have/want to have radioactive liquids in pipes/storage tanks
Add in overlay of a radiation symbol. It's opacity is linked to the damage the character takes (glitch effect if possible).

## Version 0.12
Implement MK-3 Absorption and Reduction equipment
- Absorption MK 3: Reduces radiation damage by 50 per equipment.
- Reduction MK 3: Reduces radiation damage by 60% per equipment.

## Version 0.13
Menu Simulations showing off the new features and interactions this mod offers.
- Player walking over uranium ore and dying
- Player fighting biters with radiation wall. Wall is breached and player dies.
- Chest surrounded with resistant walls having uranium fuel cells.

## Version 1.0
Official release of the mod
Adding in mod achievements in relation to radiation