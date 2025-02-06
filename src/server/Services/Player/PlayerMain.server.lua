local Players = game:GetService("Players")

local SpawnCharacter = require(game.ServerScriptService.Components.SpawnCharacter)

local currentMap = game.Workspace.Map

local function SpawnCharacterInMap(player: Player)
    local spawnLocations = currentMap:FindFirstChild('SpawnLocations') :: Folder
    assert(
        spawnLocations and spawnLocations:IsA('Folder'),
        `Spawn Location Folder Invalid: {spawnLocations} In Map: {currentMap}`
    )

    SpawnCharacter.AtRandomPartInFolder(player,spawnLocations)
end

Players.PlayerAdded:Connect(function(player: Player)
    SpawnCharacterInMap(player)
end)