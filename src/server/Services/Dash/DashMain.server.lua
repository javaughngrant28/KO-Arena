
local Players = game:GetService("Players")

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)
local PlayerAPI = require(game.ServerScriptService.Services.Players.PlayerAPI)

local soundUtil = require(game.ReplicatedStorage.Shared.Utils.SoundUtil)

local PLayerLoadedSignal = PlayerAPI.GetPlayerLoadedSignal()
local network: BadNetwork.Server = BadNetwork.new()

local LastTimeDashRegenerated: {[string]: number} = {}
local IsDashingTasks = {}


local GoundDashSound: Sound = game.ReplicatedStorage.Assets.Sounds.Dash.Dash


local function GetDashAmountValue(player: Player): NumberValue
    return player:FindFirstChild('DashAmount') :: NumberValue
end

local function GetIsDashingValue(player: Player): BoolValue
    return player:FindFirstChild('IsDashing') :: BoolValue
end


local function CreateActiveIsDashingTask(player: Player)
    local value = GetIsDashingValue(player)
    value.Value = true
    local thread = task.delay(DashConfig.DURATION,function()
        value.Value = false
    end)
    IsDashingTasks[player.Name] = thread
end

local function CancelActiveDashingTask(playerName: string)
    local dashingTask = IsDashingTasks[playerName]
    if not dashingTask then return end
    task.cancel(dashingTask)
end

local function EnableDashingValueForDuation(player: Player)
    CancelActiveDashingTask(player.Name)
    CreateActiveIsDashingTask(player)
end

local function GroundDash(player: Player)
    local DashAmount = GetDashAmountValue(player)
    DashAmount.Value -= 1
    EnableDashingValueForDuation(player)
    soundUtil.PlayFromPlayerCharacter(player,GoundDashSound)
end

local function RegenerateDash(player: Player)
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
end

local function onCharacterAdded(player: Player)
    local DashAmount = GetDashAmountValue(player)
    LastTimeDashRegenerated[player.Name] = tick()
    DashAmount.Value = DashConfig.MAX_DASH_AMOUNT
end

local function onRemoving(player: Player)
    local playerName = player.Name
    LastTimeDashRegenerated[playerName] = nil
    CancelActiveDashingTask(playerName)
end

local function onPlayerLoaded(player: Player)
    player.CharacterRemoving:Connect(function()
        onRemoving(player)
    end)

    player.CharacterAdded:Connect(function()
        onCharacterAdded(player)
    end)
end



network:On('GroundDashActivated', GroundDash)
network:On('RegenerateDash', RegenerateDash)

PLayerLoadedSignal:Connect(onPlayerLoaded)
Players.PlayerRemoving:Connect(onRemoving)