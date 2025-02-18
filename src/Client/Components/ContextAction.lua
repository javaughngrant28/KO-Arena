local ContextActionService = game:GetService('ContextActionService')
local player = game.Players.LocalPlayer

local keyMapper = require(game.ReplicatedStorage.Shared.Modules.KeyMapper)

type CallBack = (actionName: string, inputState: Enum.UserInputState) -> ()

export type ContextAction = {
	__CreateButton: boolean,
	__KeybindName: string,
	__PCValue: StringValue,
	__XBoxValue: StringValue,
	
	ButtonReffence: ImageButton?, 
	
	Create: (self: ContextAction,keybindName: string, createButton: boolean) -> (),
	BindToAction: (self: ContextAction, callBack: CallBack) -> (),
	UnbindAction: (self: ContextAction) -> ()
}

local function TransferButtonPropertiesAndChildren(sourceButton: ImageButton, targetButton: ImageButton)
	-- List of common properties you might want to transfer
	local properties = {
		"Size", "Position", "AnchorPoint", "BackgroundColor3", 
		"BackgroundTransparency", "Text", "TextColor3", "Font", 
		"TextSize", "Image", "ImageRectOffset", "ImageRectSize", 
		"Visible", "ZIndex", "BorderSizePixel"
	}

	-- Transfer properties
	for _, property in ipairs(properties) do
		if sourceButton:IsA("GuiObject") and targetButton:IsA("GuiObject") then
			local success, value = pcall(function() return sourceButton[property] end)
			if success then
				targetButton[property] = value
			end
		end
	end

	-- Transfer children
	for _, child in ipairs(sourceButton:GetChildren()) do
		local newChild = child:Clone()  -- Clone the child before adding it
		newChild.Parent = targetButton
	end
end


local ContextAction = {}

function ContextAction.new() : ContextAction
	local self = setmetatable({},{__index = ContextAction})
	return self
end

function ContextAction:Create(keybindName: string, createButton: boolean)
	assert(keybindName,'Keybind Name Invalid')
	assert(typeof(createButton) == "boolean",'Create Button Invalid')

	local keybinds = player:FindFirstChild('Keybinds') :: Folder
	assert(keybinds,"Keybind Folder Not Found")

	local keybind = keybinds:FindFirstChild(keybindName)
	assert(keybind,`Keybind Not Found: {keybindName}`)

	local PCValue = keybind:FindFirstChild('PC')
	local XboxValue = keybind:FindFirstChild('Xbox')

	assert(PCValue and XboxValue, `PC and Xbox Value Invalid: {PCValue} | {XboxValue}`)
	
	self.__CreateButton = createButton
	self.__KeybindName = keybindName
	self.__PCValue = PCValue
	self.__XBoxValue = XboxValue
end

function ContextAction:BindToAction(callBack: CallBack)
	local xbox = keyMapper.GetEnumFromString(self.__XBoxValue.Value) :: Enum.InputType
	local pc = keyMapper.GetEnumFromString(self.__PCValue.Value) :: Enum.InputType
	
	local function Activate(actionName: string, inputState: Enum.UserInputState)
		callBack(actionName, inputState)
	end
	
	ContextActionService:BindAction(self.__KeybindName,Activate,self.__CreateButton, xbox,pc)
	
	if not self.__CreateButton then return end
	
	
	local button: ImageButton = ContextActionService:GetButton(self.__KeybindName)
	if not button then return end
	
	local buttonReffence: ImageButton? = self.ButtonReffence
	assert(buttonReffence and buttonReffence:IsA('ImageButton'), self,`Invalid Button Reffence {buttonReffence}`)
	
	TransferButtonPropertiesAndChildren(buttonReffence,button)
	
	local updateImageValue = button:FindFirstChild('UpdateImage') :: StringValue

	local function UpdateImage()
		if updateImageValue then
			button.Image = updateImageValue.Value
		else
			button.Image = buttonReffence.Image
		end
	end

	-- Keep image
	button:GetPropertyChangedSignal('Image'):Connect(function()
		if button.Image == buttonReffence.Image then return end
		if updateImageValue and button.Image == updateImageValue.Value then return end
		UpdateImage()
	end)
	
end


function ContextAction:UnbindAction()
	ContextActionService:UnbindAction(self.__KeybindName)
end

return ContextAction