local Player = game.Players.LocalPlayer
local DashAmount: NumberValue = Player:WaitForChild('DashAmount', 20)

local Client = script.Parent.Parent

local ContextAction = require(Client.Components.ContextAction)
local CharacterEvents = require(Client.Modules.CharacterEvents)

function AirDash()
    print('AirDash')
end

CharacterEvents.Spawn(function(character: Model)
    ContextAction.BindKeybind('Dash',1,AirDash)
end)