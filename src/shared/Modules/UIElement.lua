
local GuiManager = require(game.ReplicatedStorage.Shared.Modules.GuiManager)
local Folder: Folder = game.ReplicatedStorage.Assets.UIElements

local function GetParentElement(screenGui: ScreenGui, elementName: string?): GuiObject?
    if not screenGui or not elementName then return end
    local child = screenGui:FindFirstChild(elementName)
    local descendant = screenGui:FindFirstChild(elementName, true)
    return child or descendant
end

local UIElement = {}

local function CreateGuiObjectClone( uiElement: string | GuiObject): GuiObject
    local uiElementClone: GuiObject
    if typeof(uiElement) == "string" then
        local guiObject = UIElement.Get(uiElement)
        uiElementClone = guiObject:Clone()

        else
            assert(
                typeof(uiElement) =="Instance" and uiElement:IsA('GuiObject'), 
                'uiElement Property Must Be String Or GuiObject'
            )
            uiElementClone = uiElement:Clone()
    end
    return uiElementClone
end

function UIElement.Get(uiElementName: string): GuiObject
    local uiElement = Folder:FindFirstChild(uiElementName) :: GuiObject
    assert(uiElement and uiElement:IsA('GuiObject'),`GuiObject Not Found Named: {uiElement}`)
    return uiElement
end

function UIElement.AddToScreen(player: Player, uiElement: string | GuiObject, screenName: string ,parentElementName: string?): GuiObject
    local screenGui = GuiManager.Find(player,screenName)
    assert(screenGui,`{player}: {screenName} Not Found To Add {uiElement} To`)

    local parentElement: Instance = GetParentElement(screenGui,parentElementName) or screenGui
    local uiElementClone: GuiObject = CreateGuiObjectClone(uiElement)
    uiElementClone.Parent = parentElement
    
    return uiElementClone
    
end

return UIElement