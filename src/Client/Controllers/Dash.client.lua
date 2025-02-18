local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer
local Client = script.Parent.Parent

local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local ContextActionComponet = require(Client.Components.ContextAction)
local CharacterEvents = require(Client.Modules.CharacterEvents)

local maid: MaidModule.Maid = MaidModule.new()
local ContextAction: ContextActionComponet.ContextAction?

local DURATION = 0.8
local MAX_FORCE = 200

local function easeOutExpo(t: number)
    return if t == 1 then 1 else 1 - math.pow(2, -10 * t)
end

local function DirectonalVectore(): Vector3
    local character = Player.Character
    local rootPart: Part = character.HumanoidRootPart

    local moveDirection = character.Humanoid.MoveDirection

        local forward = rootPart.CFrame.LookVector
        local right = rootPart.CFrame.RightVector 
    
        local dotForward = moveDirection:Dot(forward)
        local dotRight = moveDirection:Dot(right)

        local movementVectore: Vector3

        if math.abs(dotForward) > math.abs(dotRight) then
            if dotForward > 0 then
                movementVectore = forward --Forward
            else
                movementVectore = -forward --Backward
            end
        else
            if dotRight > 0 then
                movementVectore = right --Right
            else
                movementVectore = -right --Left
            end
        end
        return movementVectore
end

local function Dash(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.End then return end

    local character = Player.Character
    local rootPart: Part = character.HumanoidRootPart
    local startTick = tick()

    local DIRACTION = DirectonalVectore()

    maid['RunService'] = RunService.Heartbeat:Connect(function()
        local elapsedTime = tick() - startTick
        local alpha = math.clamp(elapsedTime / DURATION, 0, 1)
        local curvedAlpha = easeOutExpo(alpha)

        local x_Force = math.lerp(MAX_FORCE, 0, curvedAlpha)

        local force = rootPart.AssemblyMass + x_Force
        rootPart.AssemblyLinearVelocity = DIRACTION * force

        if alpha >= 1 then
            maid['RunService'] = nil
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
end)

CharacterEvents.Died(UnbindConetxtAction)
CharacterEvents.Removing(UnbindConetxtAction)