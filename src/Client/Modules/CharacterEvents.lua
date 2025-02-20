local Players = game:GetService("Players")

local CharacterEvents = {}

type Callback = (character: Model) -> ()
type CallbackTable = {Callback}

local registeredCallbacks = {
	Spawn = {} :: CallbackTable,
	Loaded = {} :: CallbackTable,
	Died = {} :: CallbackTable,
	Removing = {} :: CallbackTable, -- Added Removing event
}

local function FireCallbacks(eventType: string, character: Model)
	for _, callback in registeredCallbacks[eventType] do
		callback(character)
	end
end

local function OnCharacterAdded(character: Model)
	FireCallbacks("Spawn", character)

	if character:IsDescendantOf(workspace) then
		character:WaitForChild("Humanoid")
		FireCallbacks("Loaded", character)
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Once(function()
			FireCallbacks("Died", character)
		end)
	end

	-- Detect when the character is being removed
	character.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			FireCallbacks("Removing", character)
		end
	end)
end

local function RegisterCallback(eventType: string, callback: Callback)
	assert(type(callback) == "function", `Invalid callback for {eventType}. Expected function.`)
	table.insert(registeredCallbacks[eventType], callback)

	local character = Players.LocalPlayer.Character
	if character and eventType == "Loaded" and character.Parent then
		callback(character)
	end
end

function CharacterEvents.Spawn(callback: Callback)
	RegisterCallback("Spawn", callback)
end

function CharacterEvents.Loaded(callback: Callback)
	RegisterCallback("Loaded", callback)
end

function CharacterEvents.Died(callback: Callback)
	RegisterCallback("Died", callback)
end

function CharacterEvents.Removing(callback: Callback) -- Added Removing function
	RegisterCallback("Removing", callback)
end

if Players.LocalPlayer.Character then
	task.spawn(function()
		task.wait(0.2)
		OnCharacterAdded(Players.LocalPlayer.Character)
	end)
end
Players.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

return CharacterEvents
