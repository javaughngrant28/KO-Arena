local Player = game.Players.LocalPlayer
local DashAmount = Player:WaitForChild("DashAmount", 20)

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local network: BadNetwork.Client = BadNetwork.new()

local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)
local RegenDelay = DashConfig.RegenDelay
local MAX = DashConfig.MAX_DASH_AMOUNT

local regenTask

local function startRegen()
    if regenTask then task.cancel(regenTask) end
    
    regenTask = task.spawn(function()
        while DashAmount.Value < MAX do
            task.wait(RegenDelay)
            if DashAmount.Value < MAX then
                network:Fire('RegenerateDash')
            else
                break
            end
        end
    end)
end

DashAmount:GetPropertyChangedSignal("Value"):Connect(function()
    if DashAmount.Value < MAX then
        startRegen()
    end
end)
