
local function initExplorerTrait()
	local explorer = TraitFactory.addTrait(
		"Explorer",
		getText("UI_trait_explorer"),
		1,
		getText("UI_trait_explorerdesc"),
		false
	);
end

Events.OnGameBoot.Add(initExplorerTrait);