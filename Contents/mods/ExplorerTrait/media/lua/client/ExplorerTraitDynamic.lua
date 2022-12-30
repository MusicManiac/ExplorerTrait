local fcomp_default = function(a, b) return a < b end

function table.bininsert(t, value, fcomp)
	-- Initialise compare function
	local fcomp = fcomp or fcomp_default
	--  Initialise numbers
	local iStart, iEnd, iMid, iState = 1, #t, 1, 0
	-- Get insert position
		while iStart <= iEnd do
			-- calculate middle
			iMid = math.floor((iStart + iEnd) / 2)
			-- compare
			if fcomp(value, t[iMid]) then
				iEnd, iState = iMid - 1, 0
			else
				iStart, iState = iMid + 1, 1
			end
		end
	if value ~= t[iMid + iState - 1] and value ~= t[iMid + iState + 1] then
		table.insert(t, (iMid + iState), value)
	end
	return (iMid + iState)
end

function cantorKeyGenerator(x, y)
	return (x + y) * (x + y + 1) / 2 + x;
end

function ETDataDump()
	local player = getPlayer();
	player:getModData().ExplorerTrait = player:getModData().ExplorerTrait or {};
	local ExplorerTraitData = player:getModData().ExplorerTrait;
	for key in pairs(ExplorerTraitData.Cell) do
		print("Cell #"..key.." has "..#ExplorerTraitData.Cell[key].ExploredTiles.." explored tiles");
	end
end

function addNewCellToList(cellKey)
	local player = getPlayer();
	player:getModData().ExplorerTrait = player:getModData().ExplorerTrait or {};
	local ExplorerTraitData = player:getModData().ExplorerTrait;
	ExplorerTraitData.Cell[cellKey] = {};
	ExplorerTraitData.Cell[cellKey].ExploredTiles = {};
	ExplorerTraitData.Cell[cellKey].IsExplored = false;
	--print("Successfully added cell with key "..cellKey);
end

function ETLocationUpdate()
	local player = getPlayer();
	if not player:HasTrait("Explorer") or SandboxVars.ExplorerTrait.ShowExploredCellsStat == true then
		local playerX = math.floor(player:getX());
		local playerY = math.floor(player:getY());
		local ExplorerTraitData = player:getModData().ExplorerTrait;

		local size = 10;
		local scoutedAreaMinX = playerX - size;
		local scoutedAreaMinY = playerY - size;
		local scoutedAreaMaxX = playerX + size;
		local scoutedAreaMaxY = playerY + size;
		local lastUsedCellKeys = {};
		for x = scoutedAreaMinX, scoutedAreaMaxX do
			for y = scoutedAreaMinY, scoutedAreaMaxY do
				local cellX = math.floor(x / 300);
				local cellY = math.floor(y / 300);
				local cellKey = cantorKeyGenerator(cellX, cellY);
				if ExplorerTraitData.Cell[cellKey] == nil then
					addNewCellToList(cellKey);
				end
				if ExplorerTraitData.Cell[cellKey].IsExplored == false then
					table.bininsert(lastUsedCellKeys, cellKey)
					local tileKey = cantorKeyGenerator(x, y);
					table.bininsert(ExplorerTraitData.Cell[cellKey].ExploredTiles, tileKey);
				end
			end
		end
		for i, v in pairs(lastUsedCellKeys) do
			if #ExplorerTraitData.Cell[lastUsedCellKeys[i]].ExploredTiles >= ETCellPercentageToCountCellExplored then
				ExplorerTraitData.Cell[lastUsedCellKeys[i]].IsExplored = true;
				ExplorerTraitData.ExploredCellsCounter = ExplorerTraitData.ExploredCellsCounter + 1;
				HaloTextHelper.addTextWithArrow(player, "Cell #"..lastUsedCellKeys[i].." explored. Total cells explored: "..ExplorerTraitData.ExploredCellsCounter, true, HaloTextHelper.getColorGreen());
			end
		end
		if ExplorerTraitData.ExploredCellsCounter >= SandboxVars.ExplorerTrait.CellsToObtain and not player:HasTrait("Explorer") then
			player:getTraits():add("Explorer");
			HaloTextHelper.addTextWithArrow(player, getText("UI_trait_explorer"), true, HaloTextHelper.getColorGreen());
		end
	end
end

function ETInitialize( _playerIndex, _player)
	if SandboxVars.ExplorerTrait.Dynamic == true or SandboxVars.ExplorerTrait.ShowExploredCellsStat == true then
		Events.EveryOneMinute.Add(ETLocationUpdate);
		--Events.EveryTenMinutes.Add(ETDataDump);
		-- print(getPlayer():getModData().ExplorerTrait.ExploredCellsCounter)
		local player = _player;
		player:getModData().ExplorerTrait = player:getModData().ExplorerTrait or {};
		local ExplorerTraitData = player:getModData().ExplorerTrait;
		ExplorerTraitData.ExploredCellsCounter = ExplorerTraitData.ExploredCellsCounter or 0;
		ExplorerTraitData.Cell = ExplorerTraitData.Cell or {};
		ETCellPercentageToCountCellExplored = math.floor(90000 * SandboxVars.ExplorerTrait.PercentageToCountCellExplored * 0.01);
	end
end

-- Events.OnGameStart.Add(ETInitialize);
Events.OnCreatePlayer.Add(ETInitialize)