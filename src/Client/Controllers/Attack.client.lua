local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Client = script.Parent.Parent

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local CharacterEvents = require(Client.Modules.CharacterEvents)
local ContextAction = require(Client.Components.ContextAction)
local AttackConfig = require(game.ReplicatedStorage.Shared.Configs.AttackConfig)

local network: BadNetwork.Client = BadNetwork.new()


local lastTimeAttacked = nil

local function CanAttack()
    if lastTimeAttacked and (tick() - lastTimeAttacked) < AttackConfig.Cooldown then
        return false
    end
    return true
end



local function Attack(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.End then return end
    if not CanAttack() then return end
    lastTimeAttacked = tick()
    network:Fire('Attack')
end

local function onCharacterSpawn()
    ContextAction.BindKeybind('Attack',1,Attack)
end

local function onCharacterRemoving()
    ContextAction.UnbindKeybind('Attack',Attack)
end

CharacterEvents.Spawn(onCharacterSpawn)
CharacterEvents.Died(onCharacterRemoving)
CharacterEvents.Removing(onCharacterRemoving)

