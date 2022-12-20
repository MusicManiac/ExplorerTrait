WorldMapVisited = WorldMapVisited or {}

local function triggerExplorerTrait()
	local player = getPlayer();
	if not player:HasTrait("Explorer") then return end -- end function if player doesn't have the Explorer trait
	local radius = SandboxVars.ExplorerTrait.RevealRadius;
	local px = player:getX()
	local py = player:getY()
	WorldMapVisited.getInstance():setKnownInSquares(px-radius, py-radius, px+radius, py+radius)
end

Events.EveryOneMinute.Add(triggerExplorerTrait)