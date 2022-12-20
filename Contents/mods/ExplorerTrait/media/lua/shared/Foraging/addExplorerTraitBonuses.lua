require "Foraging/forageSystem";
require "Foraging/forageDefinitions";

local function addExplorerTraitBonuses()

    forageSystem = forageSystem or {};
    forageSystem.traitBonuses = forageSystem.traitBonuses or {}
    forageSystem.weatherEffectModifiers = forageSystem.weatherEffectModifiers or {}
    forageSystem.darknessEffectModifiers = forageSystem.darknessEffectModifiers or {}
    forageSystem.traitBonuses["Explorer"] = 0.5;
    forageSystem.weatherEffectModifiers["Explorer"] = 10;
    forageSystem.darknessEffectModifiers["Explorer"] = 2;

    forageSkills = forageSkills or {}
    forageSkills["Explorer"] = {
		name                    = "Explorer",
		type                    = "trait",
		visionBonus             = 0.5,
		weatherEffect           = 10,
		darknessEffect          = 2,
		specialisations         = {
			["Berries"]             = 3,
			["Mushrooms"]           = 3,
			["Firewood"]            = 3,
            ["ForestRarities"]      = 3,
			["WildPlants"]			= 3,
			["WildHerbs"]			= 3,
        }
	};
end

Events.OnGameBoot.Add(addExplorerTraitBonuses)