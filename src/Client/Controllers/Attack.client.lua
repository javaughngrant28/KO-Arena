local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Client = script.Parent.Parent

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local CharacterEvents = require(Client.Components.CharacterEvents)
local CharacterDash = require(Client.Components.CharacterDash)
local ContextAction = require(Client.Components.ContextAction)

local AnimationUtil = require(game.ReplicatedStorage.Shared.Utils.AnimationUtil)
local SoundUtil = require(game.ReplicatedStorage.Shared.Utils.SoundUtil)
local AttackConfig = require(game.ReplicatedStorage.Shared.Configs.AttackConfig)

local network: BadNetwork.Client = BadNetwork.new()

local AttackAnimationIDs = {
    m1 = 'rbxassetid://74291876798296',
    m2 = 'rbxassetid://113378241589125',
    m3 = 'rbxassetid://119287767212046',
}

local SwingSounds = {
    ReplicatedStorage.Assets.Sounds.Attack.Swing1
}

local AttackAnimationTracks: {[string]: AnimationTrack} = {}

local combo = 1
local soundIndex = 1

local lastTimeAttacked = nil
local lastAnimationTackPlayed: AnimationTrack = nil



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

    if lastAnimationTackPlayed then
        lastAnimationTackPlayed:Stop()
    end

    local swingSound: Sound = SwingSounds[soundIndex]
    local animationTarck = AttackAnimationTracks[`m{combo}`]

    lastAnimationTackPlayed = animationTarck

    AnimationUtil.PlayTrackForDuration(animationTarck,AttackConfig.AnimationSpeed)
    SoundUtil.PlayFromPlayerCharacter(player, swingSound)

    combo += 1
    soundIndex += 1

    if AttackAnimationTracks[`m{combo}`] == nil then
        combo = 1
    end

    if soundIndex > #SwingSounds then
        soundIndex = 1
    end
end

local function onCharacterSpawn(character)
    AttackAnimationTracks = AnimationUtil.CreateAnimationTracks(character,AttackAnimationIDs)
    ContextAction.BindKeybind('Attack',1,Attack)
end

local function onCharacterRemoving()
    ContextAction.UnbindKeybind('Attack',Attack)
end

CharacterEvents.Spawn(onCharacterSpawn)
CharacterEvents.Died(onCharacterRemoving)
CharacterEvents.Removing(onCharacterRemoving)

