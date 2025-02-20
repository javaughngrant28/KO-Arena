local maidModuel = require(game.ReplicatedStorage.Shared.Modules.Maid)

local Trail = {}
Trail.__index = Trail

Trail._Player = nil
Trail._MAID = nil
Trail._TrailInstances = {}

Trail._Perams = {
    Name = 'Default'
}


function Trail.new(player: Player, perams: {[string]: any})
    local self = setmetatable({}, Trail)
    self:__Constructor(player, perams)
    return self
end

function Trail:Activate()
    self:__EnableTrails(true)
end

function Trail:Deactivate()
    self:__EnableTrails(false)
end

function Trail:_TrailsToCharacter(trails: Model, character: Model)
    for _, trailInstance: Part in ipairs(trails:GetChildren()) do
        local matchingPart: Part = character:FindFirstChild(trailInstance.Name)
        if matchingPart then
            local clonedTrail: Part = trailInstance:Clone()
            for _, child: Instance in clonedTrail:GetChildren() do
                child.Parent = matchingPart
                if child:IsA('Trail') then
                    child.Enabled = false
                    table.insert(self._TrailInstances,child)
                end
            end
            clonedTrail:Destroy()
        end
    end
end

function Trail:_CharacterSetUp(character: Model)
    local model = game.ReplicatedStorage.Assets.Trails:FindFirstChild(self._Perams.Name)
    assert(model,`{self._Perams.Name} Trail Model Not Found`)

    self._TrailInstances = {}
    self:_TrailsToCharacter(model,character)
end

function Trail:_Initialize()
    local player: Player = self._Player

    if player.Character then
        self:_CharacterSetUp(player.Character)
    end

    self._MAID['Character Added'] = player.CharacterAdded:Connect(function(character)
        self:_CharacterSetUp(character)
    end)
end

function Trail:__Constructor(player: Player, perams: {[string]: any})
    self._MAID = maidModuel.new()
    self._Player = player
    self._TrailInstances = {}
    if perams then
        for key, value in perams do
            if self._Perams[key] then
                self._Perams[key] = value
                else
                    warn(`{key} Key Not Found In Perms {unpack(self._Perams)}`)
            end
        end
    end
    self:_Initialize()
end

function Trail:__EnableTrails(value: boolean)
    for _, trail: Trail in self._TrailInstances do
        trail.Enabled = value
    end
end

function Trail:Destroy()
    self._MAID:Destroy()
    for index, _ in pairs(self) do
        self[index] = nil
    end
end

return Trail