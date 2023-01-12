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

local function cantorKeyGenerator(x, y)
	return (x + y) * (x + y + 1) / 2 + x;
end

local function ThinOutCellList(lastUnexploredKey)
	local player = getPlayer();
	player:getModData().ExplorerTrait = player:getModData().ExplorerTrait or {};
	local ExplorerTraitData = player:getModData().ExplorerTrait;
	--print("ExplorerTraitData in ThinOutCellList: "..tostring(ExplorerTraitData));
	--print("ExplorerTraitData.Cell in ThinOutCellList: "..tostring(ExplorerTraitData.Cell));
	local lowestExplored = lastUnexploredKey;
	for key in pairs(ExplorerTraitData.Cell) do
		if ExplorerTraitData.Cell[key].VisitedOrder < ExplorerTraitData.Cell[lowestExplored].VisitedOrder then
			lowestExplored = key;
		end
	end
	print("DET: Oldest cell key "..lowestExplored..", visited order: "..ExplorerTraitData.Cell[lowestExplored].VisitedOrder..", Cell data is purged.");
	ExplorerTraitData.Cell[lowestExplored] = nil;
end

local function ETDataDump()
	local player = getPlayer();
	player:getModData().ExplorerTrait = player:getModData().ExplorerTrait or {};
	local ExplorerTraitData = player:getModData().ExplorerTrait;
	--print("ExplorerTraitData in ETDataDump: "..tostring(ExplorerTraitData));
	--print("ExplorerTraitData.Cell in ETDataDump: "..tostring(ExplorerTraitData.Cell));
	local totalCells = 0;
	local totalExploredCells = 0;
	local totalTiles = 0;
	local lastUnexploredKey = 0;
	for key in pairs(ExplorerTraitData.Cell) do
		totalCells = totalCells + 1;
		if ExplorerTraitData.Cell[key].ExploredTiles ~= nil then
			totalTiles = totalTiles + #ExplorerTraitData.Cell[key].ExploredTiles;
			if ExplorerTraitData.Cell[key].IsExplored == false then
				lastUnexploredKey = key;
				--print("Cell #"..key.." has "..#ExplorerTraitData.Cell[key].ExploredTiles.." explored tiles, compared to needed "..ETCellPercentageToCountCellExplored);
			else
				print("DET: Cell "..key.." is explored, purging unneded data from it. Removed "..#ExplorerTraitData.Cell[key].ExploredTiles.." tile entries");
				ExplorerTraitData.Cell[key].ExploredTiles = nil;
			end
		end
	end
	print("DET: Data has total of "..totalCells.." cells that contain in total "..totalTiles.." explored tiles");
	if totalCells > SandboxVars.ExplorerTrait.CellsRemembered then 
		print("DET: Data has more than "..SandboxVars.ExplorerTrait.CellsRemembered.." cells, purging oldest one");
		ThinOutCellList(lastUnexploredKey)
	elseif totalTiles > 100000 then
		print("DET: Data has more than 100k tiles, purging oldest one");
		ThinOutCellList(lastUnexploredKey) 
	end
end

function addNewCellToList(cellKey)
	local player = getPlayer();
	player:getModData().ExplorerTrait = player:getModData().ExplorerTrait or {};
	local ExplorerTraitData = player:getModData().ExplorerTrait;
	ExplorerTraitData.Cell[cellKey] = {};
	ExplorerTraitData.Cell[cellKey].ExploredTiles = {};
	ExplorerTraitData.Cell[cellKey].IsExplored = false;
	ExplorerTraitData.Cell[cellKey].VisitedOrder = ExplorerTraitData.VisitedOrder;
	print("DET: Successfully added cell with key "..cellKey..", VisitedOrder: ".. ExplorerTraitData.VisitedOrder);
	ExplorerTraitData.VisitedOrder = ExplorerTraitData.VisitedOrder + 1;
end

function ETLocationUpdate()
	local player = getPlayer();
	if not player:HasTrait("Explorer") or SandboxVars.ExplorerTrait.ShowExploredCellsStat == true then
		local playerX = math.floor(player:getX());
		local playerY = math.floor(player:getY());
		local ExplorerTraitData = player:getModData().ExplorerTrait;

		local size = SandboxVars.ExplorerTrait.ExplorationRadius;
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
	print("DET: initializing")
	if SandboxVars.ExplorerTrait.Dynamic == true or SandboxVars.ExplorerTrait.ShowExploredCellsStat == true then
		Events.EveryOneMinute.Add(ETLocationUpdate);
		Events.EveryTenMinutes.Add(ETDataDump);
		local player = _player;
		player:getModData().ExplorerTrait = player:getModData().ExplorerTrait or {};
		local ExplorerTraitData = player:getModData().ExplorerTrait;
		ExplorerTraitData.ExploredCellsCounter = ExplorerTraitData.ExploredCellsCounter or 0;
		ExplorerTraitData.Cell = ExplorerTraitData.Cell or {};
		ExplorerTraitData.VisitedOrder = ExplorerTraitData.VisitedOrder or 1;
		for key in pairs(ExplorerTraitData.Cell) do -- applying visited order through out existing moddata if it's missing one
			if ExplorerTraitData.Cell[key].VisitedOrder == nil then
				ExplorerTraitData.Cell[key].VisitedOrder = ExplorerTraitData.VisitedOrder
				ExplorerTraitData.VisitedOrder = ExplorerTraitData.VisitedOrder + 1;
				print("DET: Cell #"..key.." didnt have visited order field, now has "..ExplorerTraitData.Cell[key].VisitedOrder);
			end
		end
		ETCellPercentageToCountCellExplored = math.floor(90000 * SandboxVars.ExplorerTrait.PercentageToCountCellExplored * 0.01);
	end
end

Events.OnCreatePlayer.Add(ETInitialize)
