
local funcLib = require(game.ReplicatedStorage.Shared.Modules.FuncLib)



local function setCollisions(character: Model)
    if not character then return end
    funcLib.SetCollisionGroup(character,'Char')
end

local function RemoveCharcter(player: Player)
    local CharacterModel: Model? = player.Character
    if not CharacterModel then return end
    CharacterModel:Destroy()
    player.Character = nil
    task.wait()
end

local function LoadCharacter(player: Player): Model
    player.CharacterAppearanceLoaded:Once(setCollisions)
    player:LoadCharacter()

    local character = player.Character or player.CharacterAdded:Wait()
    setCollisions(character)

    return character
end

local function GetCFrameFormPart(part: Part): CFrame
    local size = part.Size
    local position = part.Position

    local randomOffset = Vector3.new(
            math.random() * size.X - size.X / 2,
            math.random() * size.Y - size.Y / 2,
            math.random() * size.Z - size.Z / 2
        )
    
        return CFrame.new(position + randomOffset)
end

local function GetRandomPartFromFolder(folder: Folder) : BasePart
    local parts = folder:GetChildren() :: {BasePart}
    local randomIndex = math.random(1,#parts)
    local part = parts[randomIndex] :: BasePart
    assert(part:IsA("BasePart"),`Instance Found In Part Folder`)
    return part
end

local SpawnCharacter = {}

function SpawnCharacter.InPart(player: Player, part: BasePart): Model
    RemoveCharcter(player)

    local character = LoadCharacter(player) :: Model
    local spawnCFrame = GetCFrameFormPart(part) :: CFrame

    task.defer(workspace.PivotTo, character, spawnCFrame)
    return character
end

function SpawnCharacter.AtRandomPartInFolder(player: Player, folder: Folder): Model
    assert(folder and folder:IsA('Folder'), `Folder Invalid`)

    RemoveCharcter(player)

    local character = LoadCharacter(player) :: Model
    local part = GetRandomPartFromFolder(folder) :: Part
    local spawnCFrame = GetCFrameFormPart(part) :: CFrame

    task.defer(workspace.PivotTo, character, spawnCFrame)
    return character
end

return SpawnCharacter