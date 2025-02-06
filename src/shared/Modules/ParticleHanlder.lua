local Debris = game:GetService("Debris")

local ParticleManager = {}

local function IncrementParticleScale(emitter: ParticleEmitter, value: number)

	local numberSequence = emitter.Size
	local updatedKeypoints = {}

	for _, keypoint in ipairs(numberSequence.Keypoints) do
		-- If the keypoint time is not 0, increment the value
		if keypoint.Time ~= 0 then
			table.insert(updatedKeypoints, NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value + value))
		else
			-- If the time is 0, keep the original keypoint
			table.insert(updatedKeypoints, keypoint)
		end
	end
	-- Create a new NumberSequence with the updated keypoints
	local newNumberSequence = NumberSequence.new(updatedKeypoints)
	emitter.Size = newNumberSequence
end


-- Utility function for creating a weld between two parts
local function createWeld(part0: Part, part1: Part)
	local weld = Instance.new("Weld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.Parent = part1
end


function ParticleManager.ScaleAllParticlesInCharcter(target: Model, value: number)
	local bodyParts: {BasePart} = target:GetChildren()
	
	for _, bodyPart: BasePart in bodyParts do
		if not bodyPart:IsA('BasePart') then continue end
		
		for _, emiter: ParticleEmitter in bodyPart:GetDescendants() do
			if not emiter:IsA('ParticleEmitter') then continue end
			IncrementParticleScale(emiter,value)
		end
		
	end
end

-- Enable all particle emitters within a model
function ParticleManager.EnableParticles(model: Model)
	task.defer(function()
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			end
		end
	end)
end

-- Disable all particle emitters within a model
function ParticleManager.DisableParticles(model: Model)
	task.defer(function()
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant.Enabled = false
			end
		end
	end)
end

-- Emit particles from all particle emitters within a model or part
function ParticleManager.EmitAllParticles(modelOrPart: Model | BasePart)
	for _, descendant in ipairs(modelOrPart:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			local emitCount = descendant:GetAttribute("EmitCount") or 10  -- Default to 10 if attribute not found
			descendant:Clear()
			task.wait()
			descendant:Emit(emitCount)
		end
	end
end

-- Emits particles from a cloned particle model at a specified position
function ParticleManager.EmitParticlesAtPosition(particleModel: Model, position: Vector3)
	task.spawn(function()
		local modelClone = particleModel:Clone()
		modelClone.Parent = workspace.Particles

		-- Position the clone at the specified location
		if modelClone.PrimaryPart then
			modelClone.PrimaryPart.Anchored = true
			modelClone:SetPrimaryPartCFrame(CFrame.new(position))
		else
			warn("EmitParticlesAtPosition: PrimaryPart not set in particle model.")
		end

		-- Emit particles and schedule removal
		ParticleManager.EmitAllParticles(modelClone)
		Debris:AddItem(modelClone, 10)  -- Adjust the lifetime as needed
	end)
end



-- Emit particles from a cloned model at a specified part's position
function ParticleManager.EmitParticlesAtPart(particleModel: Model, targetPart: BasePart)
	task.defer(function()
		local modelClone = particleModel:Clone()
		modelClone.Parent = workspace.Particles
		modelClone.PrimaryPart.Anchored = false
		modelClone:SetPrimaryPartCFrame(targetPart.CFrame)

		createWeld(targetPart, modelClone.PrimaryPart)
		ParticleManager.EmitAllParticles(modelClone)
		Debris:AddItem(modelClone, 10)
	end)
end

-- Attach a particle model to a character for a specified duration
function ParticleManager.AttachParticlesToCharacter(characterModel: Model, particleModel: Model, duration: number)
	task.defer(function()
		local modelClone = particleModel:Clone()
		modelClone.Parent = workspace.Particles

		local rootPart = characterModel:FindFirstChild("HumanoidRootPart") or characterModel.PrimaryPart
		if rootPart then
			createWeld(rootPart, modelClone.PrimaryPart)
		end

		Debris:AddItem(modelClone, duration)
	end)
end

-- Copy particles and BillboardGuis from a model to a character
function ParticleManager.CopyParticlesToCharacter(sourceModel: Model, targetCharacter: Model)
	if not sourceModel or not targetCharacter then return end

	for _, sourcePart in ipairs(sourceModel:GetChildren()) do
		if sourcePart:IsA("BasePart") and targetCharacter:FindFirstChild(sourcePart.Name) then
			local targetPart = targetCharacter[sourcePart.Name]
			for _, descendant in ipairs(sourcePart:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("BillboardGui") then
					local clonedDescendant = descendant:Clone()
					if targetPart:FindFirstChild(descendant.Name) then
						targetPart[descendant.Name]:Destroy()
					end
					clonedDescendant.Parent = targetPart
				end
			end
		end
	end
end

-- Change the color of all particle emitters within a model or part
function ParticleManager.SetParticleColor(modelOrPart: Model | BasePart, color: Color3)
	for _, descendant in ipairs(modelOrPart:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new(color)
		end
	end
end

-- Additional utility function: Toggle particle emitters on/off
function ParticleManager.ToggleParticles(model: Model, isEnabled: boolean)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = isEnabled
		end
	end
end

-- Additional utility function: Remove all particles from a model or part
function ParticleManager.ClearParticles(modelOrPart: Model | BasePart)
	for _, descendant in ipairs(modelOrPart:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant:Clear()
		end
	end
end

return ParticleManager
