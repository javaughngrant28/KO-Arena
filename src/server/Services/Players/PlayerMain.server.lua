
local Players = game:GetService("Players")

local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local SpawnCharacter = require(game.ServerScriptService.Components.SpawnCharacter)

local PlayerAPI = require(game.ServerScriptService.Services.Players.PlayerAPI)

local PLayerLoadedSignal = PlayerAPI.GetPlayerLoadedSignal()

local function onPlayerAdded(player: Player)
    local playerLoaded: Instance = player:WaitForChild('FinishedLoading',20)
    if not playerLoaded then return end

    task.wait(0.2)
    PLayerLoadedSignal:Fire(player)
    
    local spawnLocations: Folder = game.Workspace.Map.SpawnLocations
    SpawnCharacter.AtRandomPartInFolder(player,spawnLocations)
end

local function onPlayerRemoving(player: Player)
    local playerName = player.Name
    print(playerName)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
