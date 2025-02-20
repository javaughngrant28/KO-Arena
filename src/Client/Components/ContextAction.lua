local ContextActionService = game:GetService("ContextActionService")
local player = game.Players.LocalPlayer
local keyMapper = require(game.ReplicatedStorage.Shared.Modules.KeyMapper)

type CallBack = (actionName: string, inputState: Enum.UserInputState) -> ()

local Actions: { [string]: { { Priority: number, Callback: CallBack } } } = {}

local function HandleAction(actionName: string, inputState: Enum.UserInputState)
    local actionList = Actions[actionName]
    if not actionList or #actionList == 0 then return end

    table.sort(actionList, function(a, b)
        return a.Priority > b.Priority
    end)

    for i, action in ipairs(actionList) do
        local result = action.Callback(actionName, inputState)
        if result == Enum.ContextActionResult.Sink then
            return
        elseif result ~= Enum.ContextActionResult.Pass then
            break
        end
    end
end


local function BindKeybind(keybindName: string, priority: number, callback: CallBack)
    assert(type(keybindName) == "string", "Invalid keybind name")
    assert(type(callback) == "function", "Callback must be a function")

    local keybinds = player:FindFirstChild("Keybinds")
    assert(keybinds, "Keybind Folder Not Found")

    local keybind = keybinds:FindFirstChild(keybindName)
    assert(keybind, `Keybind Not Found: {keybindName}`)

    local pcValue = keybind:FindFirstChild("PC")
    local xboxValue = keybind:FindFirstChild("Xbox")
    assert(pcValue and xboxValue, "Invalid keybind values")

    local xbox = keyMapper.GetEnumFromString(xboxValue.Value) :: Enum.KeyCode
    local pc = keyMapper.GetEnumFromString(pcValue.Value) :: Enum.KeyCode

    Actions[keybindName] = Actions[keybindName] or {}
    table.insert(Actions[keybindName], { Priority = priority or 0, Callback = callback })

    if #Actions[keybindName] == 1 then
        ContextActionService:BindActionAtPriority(keybindName, HandleAction, false, priority or 0, xbox, pc)
    end
end

local function UnbindKeybind(keybindName: string, callback: CallBack?)
    if not Actions[keybindName] then return end

    if callback then
        for i, action in ipairs(Actions[keybindName]) do
            if action.Callback == callback then
                table.remove(Actions[keybindName], i)
                break
            end
        end
    else
        Actions[keybindName] = nil
    end

    if not Actions[keybindName] or #Actions[keybindName] == 0 then
        ContextActionService:UnbindAction(keybindName)
    end
end

return {
    BindKeybind = BindKeybind,
    UnbindKeybind = UnbindKeybind,
}
