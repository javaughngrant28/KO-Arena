local soundService = game:GetService('SoundService')
local self = {}

function self.PLayFromPlayer(player: Player, sound: Sound)
	if player == nil or sound == nil or sound.ClassName ~= 'Sound' then return end

	local character: Model = player.Character
	if character == nil then return end

	local hrp: Part = character:FindFirstChild('HumanoidRootPart')
	if hrp == nil then return end

	local newSound = sound:Clone()
	newSound.PlayOnRemove = true
	newSound.Parent = hrp

	newSound:Destroy()
end

function self.PlaySoundInElement(soundReffrence: Sound, element: GuiObject)
    if not soundReffrence then
        warn('Sound Not Found')
        return
    end

    local sound = soundReffrence:Clone()
    sound.PlayOnRemove = true
    sound.Parent = element
    sound:Destroy()
end

function self.PlayInPart(sound: Sound, part: Part)
	if sound == nil or part == nil then return end
	if sound.ClassName ~= 'Sound' then return end

	local newSound = sound:Clone()
	newSound.PlayOnRemove = true
	newSound.Parent = part

	newSound:Destroy()
end

function self.CreateSoundFromIdAndPlayInPart(soundId: string, part: Part)
	if soundId == nil or part == nil then return end

	local newSound = Instance.new('Sound')
	newSound.SoundId = soundId
	newSound.PlayOnRemove = true
	newSound.Parent = part

	newSound:Destroy()
end

function self.PlayOnClient(sound: Sound)
	if sound == nil then return end
	if not sound:IsA('Sound') then return end

	local newSound = sound:Clone()
	newSound.PlayOnRemove = true
	newSound.Parent = soundService
	
	newSound:Destroy()
end

return self
