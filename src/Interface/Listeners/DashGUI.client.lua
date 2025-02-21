local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local MaidModule = require(game.ReplicatedStorage.Shared.Modules.Maid)
local maid: MaidModule.Maid = MaidModule.new()

local DashAmount = player:WaitForChild('DashAmount', 30) :: NumberValue
assert(DashAmount, `{player} Dash Amount Instance Nil`)

local DashConfig = require(game.ReplicatedStorage.Shared.Configs.DashConfig)
local DashGui: BillboardGui = game.ReplicatedStorage.Assets.GUI.BillboardGui.DashGui

local function GetPercentage(): number
	if DashConfig.MAX_DASH_AMOUNT > 0 then
		return (DashAmount.Value / DashConfig.MAX_DASH_AMOUNT) * 100
	else
		return 0
	end
end


local function TweenRotation(gradient: UIGradient, targetRotation: number)
	if maid[gradient] then
		maid[gradient]:Cancel()
	end

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(gradient, tweenInfo, { Rotation = targetRotation })

	maid[gradient] = tween
	tween:Play()
end

local function UpdateGui(gui: BillboardGui)
	local leftCircle = gui.Frame.Left.Circle
	local rightCircle = gui.Frame.Right.Circle

	local rotation = math.floor(math.clamp(GetPercentage() * 3.6, 0, 360))

	TweenRotation(rightCircle.UIGradient, math.clamp(rotation, 0, 180))
	TweenRotation(leftCircle.UIGradient, math.clamp(rotation, 180, 360))

	local visibility = DashAmount.Value > 0
	rightCircle.Visible = visibility
	leftCircle.Visible = visibility
end

local function AddDashGuiToCharacter(character: Model)
	if not character then return end
	local torso = character:WaitForChild('Torso', 30)

	local guiClone = DashGui:Clone()
	guiClone.Parent = torso
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
