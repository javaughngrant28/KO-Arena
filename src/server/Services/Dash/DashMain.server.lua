local Players = game:GetService("Players")


local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)
local PlayerAPI = require(game.ServerScriptService.Services.Players.PlayerAPI)

local soundUtil = require(game.ReplicatedStorage.Shared.Utils.SoundUtil)

local PLayerLoadedSignal = PlayerAPI.GetPlayerLoadedSignal()
local network: BadNetwork.Server = BadNetwork.new()

local LastTimeDashRegenerated: {[string]: number} = {}

local GoundDashSound: Sound = game.ReplicatedStorage.Assets.Sounds.Dash.Dash


local function GetDashAmountValue(player: Player): NumberValue
    local DashAmount: NumberValue = player:FindFirstChild('DashAmount')
    assert(DashAmount,`{player}: No DashAmount Instance Found`)
    return DashAmount
end

PLayerLoadedSignal:Connect(function(player: Player)
   local DashAmount = GetDashAmountValue(player)
   LastTimeDashRegenerated[player.Name] = tick()
    DashAmount.Value = DashConfig.MAX_DASH_AMOUNT
end)

network:On('GroundDashActivated',function(player: Player)
    local DashAmount = GetDashAmountValue(player)
    DashAmount.Value -= 1
    soundUtil.PlayFromPlayerCharacter(player,GoundDashSound)
end)

network:On('RegenerateDash', function(player: Player)
    if (tick() - LastTimeDashRegenerated[player.Name]) < DashConfig.RegenDelay then
        return
    end

    local DashAmount = GetDashAmountValue(player)
    LastTimeDashRegenerated[player.Name] = tick()

    if DashAmount.Value >= DashConfig.MAX_DASH_AMOUNT then
        DashAmount.Value = DashConfig.MAX_DASH_AMOUNT
        else
            DashAmount.Value += 1
    end
end)

Players.PlayerRemoving:Connect(function(player: Player)
    LastTimeDashRegenerated[player.Name] = nil
end)