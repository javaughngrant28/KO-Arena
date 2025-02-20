
local Players = game:GetService("Players")

local Client = script.Parent.Parent

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local maidModuel = require(game.ReplicatedStorage.Shared.Modules.Maid)

local EffectMaid: maidModuel.Maid = maidModuel.new()
local IsDashingMaid: maidModuel.Maid = maidModuel.new()

local network: BadNetwork.Client = BadNetwork.new()

local Effects = {
    Trail = require(Client.DashEffects.Trail),
}

local function Activate(playerName: string)
    local Effect = EffectMaid[playerName]
    if Effect then
        Effect:Activate()
    end
end

local function Deactivate(playerName: string)
    local Effect = EffectMaid[playerName]
    if Effect then
        Effect:Deactivate()
    end
end



function CreateEffect(player: Player)
    local DashEffect = player:WaitForChild('DashEffect',30) :: StringValue
    assert(DashEffect,`{player} DashEffect Instance Not Found`)

    local effectName = DashEffect.Value
    local Effect = Effects[effectName]
    assert(Effect,`{effectName} Not Found In Effects Table`)

    EffectMaid[player.Name] = Effect.new(player)
end


local function TrackIsDashingValue(player: Player)
    local IsDashing: BoolValue = player:FindFirstChild('IsDashing')
    IsDashingMaid[player.Name] = IsDashing.Changed:Connect(function(value)
        if value then
            Activate(player.Name)
            else
                Deactivate(player.Name)
        end
    end)
end


local function AddEffect(player: Player)
    CreateEffect(player)
    TrackIsDashingValue(player)
end




Players.PlayerAdded:Connect(AddEffect)

for _, player in Players:GetChildren() do
    AddEffect(player)
end