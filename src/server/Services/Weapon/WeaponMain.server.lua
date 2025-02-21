local function UpdateIdleAnimatin()
    local charcater: Model = self._PLAYER.Character
    local animate: Script = charcater:WaitForChild('Animate')
    local idleValue: StringValue = animate:WaitForChild('idle')
    local animation1: Animation = idleValue:WaitForChild('Animation1')
    local animation2: Animation = idleValue:WaitForChild('Animation2')
    
    animation1.AnimationId = self._ANIMATION_IDS.Idle.Animation1
    animation2.AnimationId = self._ANIMATION_IDS.Idle.Animation2
end


local function _AttachWeaponModel()
	local Character: Model = self._PLAYER.Character
	local leftHand: MeshPart = Character['Left Arm']
	local rightHand: MeshPart = Character['Right Arm']

	local weaponModel: Model = self.__MODEL_REFERENCE:Clone()
	self.__Maid['WeaponModel'] = weaponModel

	local leftHandle: MeshPart = weaponModel.LeftHandle
	local rightHandle: MeshPart = weaponModel.RightHandle

	local leftWeld: Weld = leftHandle.Weld
	local rightWeld: Weld = rightHandle.Weld

	leftWeld.Part0 = leftHand
	rightWeld.Part0 = rightHand

	weaponModel.Parent = Character
end