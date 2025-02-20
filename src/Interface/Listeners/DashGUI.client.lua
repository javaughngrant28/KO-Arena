
local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local maid: MaidModule.Maid = MaidModule.new()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local DashAmount = player:WaitForChild('DashAmount',30) :: NumberValue
assert(DashAmount,`{player} Dash Amount Insatnce Nil`)

local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)

local DashGui: BillboardGui = game.ReplicatedStorage.Assets.GUI.BillboardGui.DashGui

local function GetPercentage(): number
	if DashConfig.MAX_DASH_AMOUNT > 0 then
		return (DashAmount.Value / DashConfig.MAX_DASH_AMOUNT) * 100
	else
		return 0
	end
end


local function UpdateGui(gui: BillboardGui)
    local leftCircle = gui.Frame.Left.Circle
    local rightCircle = gui.Frame.Right.Circle

	local rotation = math.floor(math.clamp(GetPercentage() * 3.6, 0, 360))

	rightCircle.UIGradient.Rotation = math.clamp(rotation,0,180)
	leftCircle.UIGradient.Rotation = math.clamp(rotation,180,360)

	local visblity = DashAmount.Value > 0
	rightCircle.Visible = visblity
	leftCircle.Visible = visblity
end

local function AddDashGuiToCharacter(character: Model)
    if not character then return end
    local troso = character:WaitForChild('Torso',30)

    local guiClone = DashGui:Clone()
    guiClone.Parent = troso

    guiClone.Enabled = true
    guiClone.AlwaysOnTop = true

    UpdateGui(guiClone)

    maid['Dash Changed'] = DashAmount.Changed:Connect(function()
        UpdateGui(guiClone)
    end)
end


if player.Character then
    AddDashGuiToCharacter(player.Character)
end

player.CharacterAdded:Connect(AddDashGuiToCharacter)