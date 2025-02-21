
local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local PlayerAPI = require(game.ServerScriptService.Services.Players.PlayerAPI)

local maid: MaidModule.Maid = MaidModule.new()

local PlayerLoadedSignal = PlayerAPI.GetPlayerLoadedSignal()
local WeaponModel: Model = game.ReplicatedStorage.Assets.Models.Gloves1

local IdleAnimationIDs = {
    Animation1 = 'rbxassetid://128827501832882',
	Animation2 = 'rbxassetid://128827501832882',
}

local WalkAnimationID = 'rbxassetid://114939245972552'
local RunAnimationID = 'rbxassetid://114939245972552'


local function GiveWeapon(character: Model)
    local leftHand: MeshPart = character['Left Arm']
	local rightHand: MeshPart = character['Right Arm']

	local weaponModel: Model = WeaponModel:Clone()

	local leftHandle: MeshPart = weaponModel.LeftHandle
	local rightHandle: MeshPart = weaponModel.RightHandle

	local leftWeld: Weld = leftHandle.Weld
	local rightWeld: Weld = rightHandle.Weld

	leftWeld.Part0 = leftHand
	rightWeld.Part0 = rightHand

	weaponModel.Parent = character
end

local function UpdateAnimations(character: Model)
    local animate: Script = character:WaitForChild('Animate')
    local idleValue: StringValue = animate:WaitForChild('idle')
    local animation1: Animation = idleValue:WaitForChild('Animation1')
    local animation2: Animation = idleValue:WaitForChild('Animation2')
    local run: StringValue = animate:WaitForChild('run')
    local walk: StringValue = animate:WaitForChild('walk')
    local runAnimation: Animation = run:WaitForChild('RunAnim')
    local walkAnimation: Animation = walk:WaitForChild('WalkAnim')

    animation1.AnimationId = IdleAnimationIDs.Animation1
    animation2.AnimationId = IdleAnimationIDs.Animation2
    runAnimation.AnimationId = RunAnimationID
    walkAnimation.AnimationId = WalkAnimationID
end

function onCharacterAdded(charcater: Model)
    GiveWeapon(charcater)
    UpdateAnimations(charcater)
end

local function onRemoving(playerName: string)
    maid[`{playerName} CharacterAdded`] = nil
    maid[`{playerName} CharacterRemoving`] = nil
end

PlayerLoadedSignal:Connect(function(player: Player)
    local characterInGame = player.Character
    if characterInGame then
        onCharacterAdded(characterInGame)
    end

    maid[`{player.Name} CharacterAdded`] = player.CharacterAdded:Connect(onCharacterAdded)
    maid[`{player.Name} CharacterRemoving`] = player.CharacterRemoving:Connect(function()
        onRemoving(player.Name)
    end)
end)
