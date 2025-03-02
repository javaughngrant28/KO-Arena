local UserInputService = game:GetService("UserInputService")

local Player = game.Players.LocalPlayer
local IsDashing: NumberValue = Player:WaitForChild('IsDashing', 20)

local Client = script.Parent.Parent

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local ContextAction = require(Client.Components.ContextAction)
local CharacterEvents = require(Client.Components.CharacterEvents)
local CharacterDash = require(Client.Components.CharacterDash)
local AnimationUtil = require(game.ReplicatedStorage.Shared.Utils.AnimationUtil)

local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)
local AirDashConfig = require(game.ReplicatedStorage.Shared.Configs.AirDashConfig)

local network: BadNetwork.Client = BadNetwork.new()
local maid: MaidModule.Maid = MaidModule.new()

local spinAnimationID = 'rbxassetid://99700892967637'
local spinAnimation: AnimationTrack = nil


local function CanAirDash()
    if IsDashing.Value == true then return false end
    return true
end

function AirDash()
    if not CanAirDash() then return end

    local character = Player.Character
    local humanoid: Humanoid = character:FindFirstChild('Humanoid')
    local rootPart: Part = character:FindFirstChild('HumanoidRootPart')

    rootPart.Anchored = true
    AnimationUtil.PlayTrackForDuration(spinAnimation,AirDashConfig.SPIN_DURATION)
    task.wait(AirDashConfig.SPIN_DURATION)

    if humanoid.Health <= 0 then return end
    rootPart.Anchored = false

    local dirationVelocity = rootPart.CFrame.LookVector
    local animationTarck: AnimationTrack = CharacterDash.AnimationTracks['Forward']

    network:Fire('AirDashActivated')
    CharacterDash.Active(animationTarck,AirDashConfig.DURATION,dirationVelocity,AirDashConfig.FORCE,AirDashConfig.MAX_FORCE)
end

CharacterEvents.Spawn(function(character: Model)
    spinAnimation = AnimationUtil.LoadAnimationTrack(character,spinAnimationID)
    ContextAction.BindKeybind('Dash',1,AirDash)
end)
