local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Client = script.Parent.Parent

local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local ContextActionComponet = require(Client.Components.ContextAction)
local CharacterEvents = require(Client.Modules.CharacterEvents)
local AnimationUtil = require(game.ReplicatedStorage.Shared.Utils.AnimationUtil)

local maid: MaidModule.Maid = MaidModule.new()
local ContextAction: ContextActionComponet.ContextAction?

local DURATION = 0.6
local FORCE = 80
local MAX_FORCE = Vector3.new(400000,400000,400000)

local AnimationIDs = {
    BackDash = 'rbxassetid://130503476646842',
    ForwardDash = 'rbxassetid://77797973242645',
    LeftDash = "rbxassetid://109512074042537",
    RightDash = "rbxassetid://126019822262324",
}

local AnimationTracks: {[string]: AnimationTrack} = {}


local function CreateBodyVelocity()
    local bv = Instance.new('BodyVelocity')
    bv.MaxForce = MAX_FORCE
    return bv
end

local function GetDirectionalVectorAndAnimation(): (Vector3, AnimationTrack)
    local character = Player.Character
    local rootPart: Part = character.HumanoidRootPart

    local moveDirection = character.Humanoid.MoveDirection

        local forward = rootPart.CFrame.LookVector
        local right = rootPart.CFrame.RightVector 

        local dotForward = moveDirection:Dot(forward)
        local dotRight = moveDirection:Dot(right)

        local movementVectore: Vector3
        local animTrack: AnimationTrack

        if math.abs(dotForward) > math.abs(dotRight) then
            if dotForward > 0 then
                movementVectore = forward --Forward
                animTrack = AnimationTracks.ForwardDash
            else
                movementVectore = -forward --Backward
                animTrack = AnimationTracks.BackDash
            end
        else
            if dotRight > 0 then
                movementVectore = right --Right
                animTrack = AnimationTracks.RightDash
            else
                movementVectore = -right --Left
                animTrack = AnimationTracks.LeftDash
            end
        end
        return movementVectore, animTrack
end

local function Dash(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.End then return end

    local character = Player.Character
    local rootPart: Part = character.HumanoidRootPart
    local startTick = tick()

    local directionVelocity, animationTrack = GetDirectionalVectorAndAnimation()
    directionVelocity *= FORCE

    animationTrack:Play()

    local BodyVelocity = CreateBodyVelocity()
    BodyVelocity.Parent = rootPart

    maid['BodyVelocity'] = BodyVelocity

    maid['RunService'] = RunService.Heartbeat:Connect(function()
        local timePassed = tick() - startTick
        local percentageToGoal = math.clamp(timePassed / DURATION,0,1)
        BodyVelocity.Velocity = directionVelocity * (1 - percentageToGoal)

        if percentageToGoal >= 1 then
            maid:DoCleaning()
        end
    end)

end

local function UnbindConetxtAction()
    if not ContextAction then return end
    ContextAction:Destroy()
    maid:DoCleaning()
end

CharacterEvents.Spawn(function(character: Model)
    ContextAction = ContextActionComponet.new()

    ContextAction:Create('Dash',false)
    ContextAction:BindToAction(Dash)

    AnimationTracks = AnimationUtil.CreateAnimationTracks(character,AnimationIDs)
end)

CharacterEvents.Died(UnbindConetxtAction)
CharacterEvents.Removing(UnbindConetxtAction)