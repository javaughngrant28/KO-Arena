-- DeviceTypeModule.lua
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local DeviceType = {}

function DeviceType.GetDeviceType()
    if UserInputService.TouchEnabled then
        -- Device supports touch input, could be mobile or tablet
        return "Mobile"
    elseif UserInputService.GamepadEnabled then
        -- Gamepad is enabled, most likely Xbox
        return "Xbox"
    else
        -- If neither touch nor gamepad, it's likely a PC
        return "PC"
    end
end

return DeviceType
