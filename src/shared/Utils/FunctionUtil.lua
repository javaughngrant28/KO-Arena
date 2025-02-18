local tweenService = game:GetService('TweenService')

local FunctionUtil = {}

function FunctionUtil.SetCollisionGroup(object: Instance, collisionGroupName: string)
    if not object or not collisionGroupName then
        warn("Invalid parameters passed to SetCollisionGroup")
        return
    end

    -- Use GetDescendants to retrieve all descendants of the object
    for _, descendant in ipairs(object:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CollisionGroup = collisionGroupName
        end
    end

    -- Check the root object itself
    if object:IsA("BasePart") then
        object.CollisionGroup = collisionGroupName
    end
end

function FunctionUtil.GetDistanceBetweenParts(part1: BasePart, part2: BasePart): number
    if not part1 or not part2 then
        error("Both part1 and part2 must be valid BasePart instances.")
    end

	if not part1:IsA('BasePart') or not part2:IsA('BasePart') then
		error('Part1 And Part2 must be a Base Part')
	end
    
    return (part1.Position - part2.Position).Magnitude
end


--- Changes properties of all instances of a given type inside a container.
-- @param target Instance
-- @param instanceType string
-- @param properties table
function FunctionUtil.AdjustPropertiesByType(target: Instance, instanceType: string, properties: { [string]: any }): nil
    assert(typeof(target) == "Instance", "First argument must be an Instance")
    assert(typeof(instanceType) == "string", "Second argument must be a string specifying the instance type")
    assert(typeof(properties) == "table", "Third argument must be a table")

    local function applyProperties(instance)
        for propName, propValue in pairs(properties) do
            if pcall(function() return instance[propName] end) then
				if propName == 'Transparency' and instance.Name == "HumanoidRootPart" then
					return true
				end
                instance[propName] = propValue
            else
                warn(`Property '{propName}' does not exist on {instance:GetFullName()}`)
            end
        end
    end

    if target:IsA(instanceType) then
        applyProperties(target)
    end

    for _, descendant in target:GetDescendants() do
        if descendant:IsA(instanceType) then
            applyProperties(descendant)
        end
    end
end

function FunctionUtil.Color3ToRGBFormat(color3: Color3)
    local R = (color3.R * 255)
    local G = (color3.G * 255)
    local B = (color3.B * 255)

    return string.format("rgb(%d, %d, %d)", R, G, B)
end

function FunctionUtil.SetAttributes(instance: Instance, list: { [string]: any })
    if not instance or not list then
        warn("Invalid instance or list provided.")
        return
    end
	
    for key, value in pairs(list) do
        local success, errorMessage = pcall(function()
            instance:SetAttribute(key, value)
        end)

        if not success then
            warn("Failed to set attribute '" .. key .. "': " .. errorMessage)
        end
    end
end

function FunctionUtil.TweenCreate(timer: number, instance: Instance, value: {}, EasingStyle: Enum.EasingStyle, EasingDirection: Enum.EasingDirection, doesDestroy: boolean, callback: any): Tween
	-- Set default values for optional parameters
	EasingStyle = EasingStyle or Enum.EasingStyle.Linear
	EasingDirection = EasingDirection or Enum.EasingDirection.Out
	doesDestroy = (doesDestroy == nil) and true or doesDestroy  -- default to true if not provided

	if instance == nil then 
		warn("caught tween Instance nil") 
		return 
	end

	local tweenInfo = TweenInfo.new(
		timer,
		EasingStyle,
		EasingDirection
	)

	local tween = tweenService:Create(instance, tweenInfo, value)

	-- Handle tween completion with callback and optional tween destruction
	if tween ~= nil and (callback or doesDestroy) then
		tween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed then
				if callback then callback() end
				if doesDestroy then
					tween:Destroy()
				end
			end
		end)
	end

	return tween
end

function FunctionUtil.LoadAnimationTracks(animations: {Animation}, humanoid: Humanoid): {[string]: AnimationTrack}
	
	local animator: Animator = humanoid:FindFirstChild('Animator')
	local animationTracks:{[string]: AnimationTrack} = {}
	
	local function Load(value: Animation)
		if not value:IsA('Animation') then return end
		if value.AnimationId == nil or value.AnimationId == 'rbxassetid://' then
			warn(`Nil AnimationId For Animation: {value.Name}`)
			return
		end
		animationTracks[value.Name] = animator:LoadAnimation(value)
	end

	for _, value in animations do
		if value:IsA('Folder') then
			animationTracks[value.Name] = {}
			for _, animation: Animation in value:GetChildren() do
				Load(animation)
			end
			continue
		end

		Load(value)
	end
	
	return animationTracks
end

function FunctionUtil.PlayAnimationForDuration(animationTrack: AnimationTrack, duration: number)
	if animationTrack == nil then warn('animationTrack is nil:', animationTrack) return end
	local speed = animationTrack.Length / duration
	animationTrack:Play()
	animationTrack:AdjustSpeed(speed)
end

function FunctionUtil.DisconnectAllConnections(connectionsTable: table)
    for key, value in pairs(connectionsTable) do
        if typeof(value) == "RBXScriptConnection" then
            value:Disconnect()
            connectionsTable[key] = nil
        elseif typeof(value) == "table" then
            FunctionUtil.DisconnectAllConnections(value)
        end
    end
end


-- Function to clone sounds from a table to a target folder
function FunctionUtil.CloneSounds(sounds: {}, targetFolder: Folder)
	local function cloneSound(sound, name, parentFolder)
		local newSound = sound:Clone()
		newSound.Name = name
		newSound.Parent = parentFolder
	end

	local function cloneSoundsFromTable(soundTable, parentFolder)
		for i, sound in ipairs(soundTable) do
			local soundName = "Sound" .. i
			cloneSound(sound, soundName, parentFolder)
		end
	end

	for key, value in pairs(sounds) do
		if typeof(value) == "Instance" and value:IsA("Sound") then
			cloneSound(value, key, targetFolder)
		elseif typeof(value) == "table" then
			local newFolder = Instance.new("Folder")
			newFolder.Name = key
			newFolder.Parent = targetFolder
			cloneSoundsFromTable(value, newFolder)
		end
	end
end

return FunctionUtil