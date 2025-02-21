local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Client = script.Parent.Parent

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local CharacterEvents = require(Client.Components.CharacterEvents)
local CharacterDash = require(Client.Components.CharacterDash)
local ContextAction = require(Client.Components.ContextAction)
local AttackConfig = require(game.ReplicatedStorage.Shared.Configs.AttackConfig)

local network: BadNetwork.Client = BadNetwork.new()


local lastTimeAttacked = nil

local AttackAnimationIDs = {
    m1 = 'rbxassetid://74291876798296',
    m2 = 'rbxassetid://113378241589125',
    m3 = 'rbxassetid://119287767212046',
}

local IdleAnimationIDs = {
    Animation1 = 'rbxassetid://128827501832882',
	Animation2 = 'rbxassetid://128827501832882',
}

local WalkAnimationID = 'rbxassetid://114939245972552'
local RunAnimationID = 'rbxassetid://114939245972552'



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
    CharacterDash.Cencel()
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

