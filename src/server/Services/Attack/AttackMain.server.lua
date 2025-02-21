local ServerStorage = game:GetService("ServerStorage")

local HitboxModule = require(ServerStorage.Libraries.MuchachoHitbox)
local BadNetwork = require(game.ReplicatedStorage.Shared.Modules.BadNetwork)
local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local AttackConfig = require(game.ReplicatedStorage.Shared.Configs.AttackConfig)

local network: BadNetwork.Server = BadNetwork.new()
local maid: MaidModule.Maid = MaidModule.new()

local function Hit(humanoid: Humanoid, targetHumanoid: Humanoid)
    if humanoid.Health <= 0 or targetHumanoid.Health <= 0 then return end
    targetHumanoid.Health = 0
end

function Attack(player: Player)
    local character = player.Character
    local rootPart = character.HumanoidRootPart
    local humanoid = character.Humanoid

    local OverlapParams = OverlapParams.new()
    OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
    OverlapParams.FilterDescendantsInstances = {character}

    local hitbox = HitboxModule.CreateHitbox()
    hitbox.VelocityPrediction = true
    hitbox.OverlapParams = OverlapParams
    hitbox.DetectionMode = "HitOnce"
    hitbox.Size = Vector3.new(4, 6, 3)
    hitbox.Offset = CFrame.new(0,0,-2)
    hitbox.CFrame = rootPart

    maid[`{player.Name} HitConnection`] =  hitbox.Touched:Connect(function(_, targetHumanoid: Humanoid)
        Hit(humanoid,targetHumanoid)
    end)

    hitbox:Start()
    task.wait(AttackConfig.HitboxLiftTime)
    hitbox:Destroy()
end


network:On('Attack',Attack)

