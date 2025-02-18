

local defaultData = require(game.ServerScriptService.Services.Players.DefaultPlayerData)
local LoadedData: {[string]: defaultData.DataTemplate} = {}


game:BindToClose(function()
	while next(LoadedData) do
		task.wait()
	end
end)


local function GetData(playerName: string): defaultData.DataTemplate
    assert(playerName,'Player Name Prop Nil')
    assert(typeof(playerName) =="string", 'PlayerName Prop must Be a String')

    local data =  LoadedData[playerName]
    assert(data,`No Data Found For Player: {playerName}`)

    return data
end

local PlayerDataAPI = {}

function PlayerDataAPI._Set(playerName: string, data: defaultData.DataTemplate)
    local existingData = LoadedData[playerName]
    
    if existingData then 
        error(`Existing Data Found With Same Matching KeyName: {playerName} - {unpack(existingData)}`) 
    end
    
    LoadedData[playerName] = data
end

function PlayerDataAPI._Get(playerName: string): defaultData.DataTemplate?
    local existingData = LoadedData[playerName]
    return existingData
end

function PlayerDataAPI._Clear(playerName: string)
    LoadedData[playerName] = nil
end

function PlayerDataAPI.GetLastWeaponEquipped(playerName: string): string
    local data = GetData(playerName)
    return data.LastWeaponEquipped
end

function PlayerDataAPI.GetHiderAbilityNames(playerName: string): {string}
    local data = GetData(playerName)
    return data.EquippedHiderAbilities
end

function PlayerDataAPI.GetSeekerAbilityNames(playerName: string)
    local data = GetData(playerName)
    return data.EquippedSeekerAbilities
end

return PlayerDataAPI