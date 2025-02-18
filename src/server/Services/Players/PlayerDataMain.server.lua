
local DataStoreService = game:GetService('DataStoreService')
local DataStore = DataStoreService:GetDataStore('Data_0')

local PlayerDataAPI = require(game.ServerScriptService.Services.Players.PlayerDataAPI)

local DefaultPlayerData = require(game.ServerScriptService.Services.Players.DefaultPlayerData)
local DataToInstance = require(game.ServerScriptService.Modules.DataToInstance)


local Players = game:GetService('Players')

Players.PlayerAdded:Connect(function(player: Player)
	
	-- local success: boolean, value: {any}? = pcall(DataStore.GetAsync, DataStore, player.UserId)
	local success = true
	local value = nil

	if not success then
		player:Kick('Failed To Load: Rejoin')
		return
	end

	local Data = value or DefaultPlayerData.Template
	local InstanceData = DefaultPlayerData.GetInstanceDataSyncedWithSavedData(Data)
	PlayerDataAPI._Set(player.Name, Data)
	DataToInstance.Fire(player, InstanceData)
end)


Players.PlayerRemoving:Connect(function(player: Player)
	local playerName = player.Name
	local playerData = PlayerDataAPI._Get(playerName)
	if playerData == nil then return end

	-- local success: boolean, _ = pcall(DataStore.SetAsync, DataStore, player.UserId,playerData)
	local success = true
	if success then
		print('Saved Player Data:', player)
		else
			print('Faild To Save PlayerData')
	end

	PlayerDataAPI._Clear(playerName)
end)