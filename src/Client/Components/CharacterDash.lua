
local Player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Client = script.Parent.Parent

local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local AnimationUtil = require(game.ReplicatedStorage.Shared.Utils.AnimationUtil)
local CharacterEvents = require(Client.Components.CharacterEvents)

local maid: MaidModule.Maid = MaidModule.new()

local AnimationIDs = {
    Backward = 'rbxassetid://130503476646842',
    Forward = 'rbxassetid://77797973242645',
    Left = "rbxassetid://109512074042537",
    Right = "rbxassetid://126019822262324",
}

local lastAnimationTrackPlayed: AnimationTrack = nil

local CharacterDash = {}


CharacterDash.AnimationTracks = {
    Forward = true,
    Backward = true,
    Right = true,
    Left = true,
}


function CharacterDash.GetDirectionalVectorAndAnimationName(): (Vector3, string)
    local character = Player.Character
    local rootPart: Part = character.HumanoidRootPart

    local moveDirection = character.Humanoid.MoveDirection

        local forward = rootPart.CFrame.LookVector
        local right = rootPart.CFrame.RightVector 

        local dotForward = moveDirection:Dot(forward)
        local dotRight = moveDirection:Dot(right)

        local movementVectore: Vector3
        local diractionName: string

        if math.abs(dotForward) > math.abs(dotRight) then
            if dotForward > 0 then
                movementVectore = forward --Forward
                diractionName = 'Forward'
            else
                movementVectore = -forward --Backward
                diractionName = 'Backward'
            end
        else
            if dotRight > 0 then
                movementVectore = right --Right
                diractionName = 'Right'
            else
                movementVectore = -right --Left
                diractionName = 'Left'
            end
        end
        return movementVectore, diractionName
end

function CharacterDash.Active(animTrack: AnimationTrack, duration: number, velocity: Vector3, force: number, maxVelocity: Vector3)
    CharacterDash.Cencel()

    local character = Player.Character
    local rootPart: Part = character.HumanoidRootPart
    local startTick = tick()

    lastAnimationTrackPlayed = animTrack
    AnimationUtil.PlayTrackForDuration(animTrack,duration)

    velocity *= force

    local BodyVelocity = Instance.new('BodyVelocity')
    maid['BV'] = BodyVelocity
    BodyVelocity.MaxForce = maxVelocity
    BodyVelocity.Parent = rootPart

    maid['RunService'] = RunService.Heartbeat:Connect(function()
        local timePassed = tick() - startTick
        local percentageToGoal = math.clamp(timePassed / duration,0,1)
        BodyVelocity.Velocity = velocity * (1 - percentageToGoal)

        if percentageToGoal >= 0.78 then
            CharacterDash.Cencel()
        end
    end)

end

function CharacterDash.Cencel()
    maid:DoCleaning()
    if lastAnimationTrackPlayed then
        lastAnimationTrackPlayed:Stop()
    end
end

CharacterEvents.Spawn(function(character: Model)
    CharacterDash.AnimationTracks = AnimationUtil.CreateAnimationTracks(character,AnimationIDs)
 end)

return CharacterDash