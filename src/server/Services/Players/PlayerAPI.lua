
local Signal = require(game.ReplicatedStorage.Shared.Modules.Signal)

local PlayerLoadedSignal = Signal.new()



local PlayerAPI = {}

function PlayerAPI.GetPlayerLoadedSignal(): Signal.Signal
    return PlayerLoadedSignal
end

return PlayerAPI