local Player = game.Players.LocalPlayer
local DashAmount = Player:WaitForChild("DashAmount", 20)
local IsDashing: NumberValue = Player:WaitForChild("IsDashing", 20)

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local network: BadNetwork.Client = BadNetwork.new()

local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)
local RegenDelay = DashConfig.RegenDelay
local MAX = DashConfig.MAX_DASH_AMOUNT

local regenTask

local function startRegen()
    if regenTask then task.cancel(regenTask) end
    
    regenTask = task.spawn(function()
        -- Wait until IsDashing is false before starting regeneration
        while IsDashing.Value do
            task.wait() -- Yield until IsDashing becomes false
        end
        
        while DashAmount.Value < MAX do
            task.wait(RegenDelay)
            if DashAmount.Value < MAX and not IsDashing.Value then
                network:Fire('RegenerateDash')
            else
                break
            end
        end
    end)
end

DashAmount:GetPropertyChangedSignal("Value"):Connect(function()
    if DashAmount.Value < MAX and not IsDashing.Value then
        startRegen()
    end
end)

-- Listen for when IsDashing becomes false to start regeneration
IsDashing:GetPropertyChangedSignal("Value"):Connect(function()
    if not IsDashing.Value and DashAmount.Value < MAX then
        startRegen()
    end
end)
