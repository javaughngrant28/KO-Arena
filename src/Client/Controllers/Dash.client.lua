
local Player = game.Players.LocalPlayer
local DashAmount: NumberValue = Player:WaitForChild('DashAmount', 20)

local Client = script.Parent.Parent

local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local CharacterEvents = require(Client.Modules.CharacterEvents)
local CharacterDash = require(Client.Components.CharacterDash)
local ContextAction = require(Client.Components.ContextAction)
local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)

local network: BadNetwork.Client = BadNetwork.new()

local LastTimeDashed: number


local function CanDash(): boolean
    if DashAmount.Value <= 0 then return false end
    if LastTimeDashed and (tick()  - LastTimeDashed) < DashConfig.Cooldown then
        return false
    end

    return true
end



local function Dash(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.End then return Enum.ContextActionResult.Sink end
    if not CanDash() then return Enum.ContextActionResult.Sink end

    if Player.Character.Humanoid.FloorMaterial == Enum.Material.Air then
        return Enum.ContextActionResult.Pass
    end

    local dirationVelocity: Vector3, animName: string =  CharacterDash.GetDirectionalVectorAndAnimationName()
    local animationTarck: AnimationTrack = CharacterDash.AnimationTracks[animName]

    network:Fire('GroundDashActivated')
    LastTimeDashed = tick()

    CharacterDash.Active(animationTarck,DashConfig.DURATION,dirationVelocity,DashConfig.FORCE,DashConfig.MAX_FORCE)
end



CharacterEvents.Spawn(function()
   ContextAction.BindKeybind('Dash',2,Dash)
end)

local function UnbindConetxtAction()
    ContextAction.UnbindKeybind('Dash',Dash)
end

CharacterEvents.Died(UnbindConetxtAction)
CharacterEvents.Removing(UnbindConetxtAction)