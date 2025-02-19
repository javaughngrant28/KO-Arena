--[[

	               (          )                           )   (         )  
	   (     (     )\ )    ( /(        *   )  (  (     ( /(   )\ )   ( /(  
	 ( )\    )\   (()/(    )\()) (   ` )  /(  )\))(   ')\()) (()/(   )\()) 
	 )((_)((((_)(  /(_))  ((_)\  )\   ( )(_))((_)()\ )((_)\   /(_))|((_)\  
	((_)_  )\ _ )\(_))_    _((_)((_) (_(_()) _(())\_)() ((_) (_))  |_ ((_) 
	 | _ ) (_)_\(_)|   \  | \| || __||_   _| \ \((_)/ // _ \ | _ \ | |/ /  
	 | _ \  / _ \  | |) | | .` || _|   | |    \ \/\/ /| (_) ||   /   ' <   
	 |___/ /_/ \_\ |___/  |_|\_||___|  |_|     \_/\_/  \___/ |_|_\  _|\_\ 

    BadNetwork Module Documentation

BadNetwork: Simplifies client-server communication with RemoteEvents, supporting namespaces and automatic cleanup.

Usage:
  local BadNetwork = require(game.ReplicatedStorage.BadNetwork)

Server Methods:
  server:On(), server:Fire(), server:FireAll(), server:Disconnect(), server:Destroy()

Client Methods:
  client:On(), client:Fire(), client:Disconnect(), client:Destroy()

Notes:
  - Default "General" RemoteEvent if no namespace.
  - Always call .Destroy() to prevent memory leaks.
]]

export type Server = {
	On: (self: Server, eventName: string, callback: (player: Player, ...any) -> ()) -> (),
	Fire: (self: Server, player: Player, eventName: string, ...any) -> (),
	FireAll: (self: Server, eventName: string, ...any) -> (),
	FireList: (self: Server, playerList: {Player},eventName: string, ...any) -> (),
	Disconnect: (self: Server, eventName: string) -> (),
	Destroy: (self: Server) -> (),
}

export type Client = {
	On: (self: Client, eventName: string, callback: (...any) -> ()) -> (),
	Fire: (self: Client, eventName: string, ...any) -> (),
	Disconnect: (self: Client, eventName: string) -> (),
	Destroy: (self: Client) -> (),
}

export type BadNetwork = Server | Client


type ServerCallBack = (player: Player, ...any) -> ()
type ClientCallBack = (...any) -> ()

local RunService = game:GetService('RunService')

local DEFAULT_LOCATION = game.ReplicatedStorage
local FOLDER_LOCATION = DEFAULT_LOCATION.Shared

local FOLDER_NAME = 'BadNetworkEvents'
local REMOTE_NAME = 'General'

local function ErrorCheckForDuplicates(instanceName: string, location: Instance | {[string]: any})
	local existingInstance = typeof(location) == "Instance" and location:FindFirstChild(instanceName) or (typeof(location) == 'table' and location[instanceName])
	if existingInstance then
		error(`Found Duplicate Instance Named: "{instanceName}" under Parent Location: {location}`)
	end
end

local function CreateFolder(name: string, parent: Instance): Folder
	ErrorCheckForDuplicates(name, parent)

	local folder = Instance.new('Folder')
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function CreateRemote(name: string, parent: Instance): RemoteEvent
	ErrorCheckForDuplicates(name,parent)

	local RemoteEvent = Instance.new('RemoteEvent')
	RemoteEvent.Name = name
	RemoteEvent.Parent = parent
	return RemoteEvent
end

local function GetGeneralRemote() : RemoteEvent
	local folder = FOLDER_LOCATION:FindFirstChild(FOLDER_NAME)
	local generalRemote = folder:FindFirstChild(REMOTE_NAME):: RemoteEvent
	assert(generalRemote,'General Remote Not Found')
	return generalRemote
end

if RunService:IsServer() then
	if FOLDER_LOCATION == DEFAULT_LOCATION then
		warn('Change Folder Location')
	end

	local folder = CreateFolder(FOLDER_NAME,FOLDER_LOCATION)
	CreateRemote(REMOTE_NAME,folder)
end


local Client = {}
Client._NAMESPACE = nil
Client._REMOTE_CONNECTIONS = {}
Client._ON_ADDED_CONNECTIONS = {}

function Client.new(namespace: string?)
	local self = setmetatable({}, {__index = Client})
	self._NAMESPACE = namespace
	self._REMOTE_CONNECTIONS = {}
	self._ON_ADDED_CONNECTIONS = {} 
	return self
end


function Client:On(eventName: string, callback: ClientCallBack)
	ErrorCheckForDuplicates(eventName,self._ON_ADDED_CONNECTIONS)
	local remoteParentName = self._NAMESPACE or FOLDER_NAME
	
	local function AttemptToConnectToDescendant(descendant: Instance)
		if descendant:IsA('RemoteEvent') and descendant.Parent and descendant.Parent.Name == remoteParentName then
			if self._NAMESPACE and descendant.Name ~= eventName then return end
			
			if self._REMOTE_CONNECTIONS[eventName] then
				self._REMOTE_CONNECTIONS[eventName]:Disconnect()
			end
			
			if self._NAMESPACE then
				self._REMOTE_CONNECTIONS[eventName] = descendant.OnClientEvent:Connect(callback)
			else
				self._REMOTE_CONNECTIONS[eventName] = descendant.OnClientEvent:Connect(function(_eventName: string,...)
					if eventName == _eventName then
						callback(...)
					end
				end)
			end

			
		end
	end
	
	self._ON_ADDED_CONNECTIONS[eventName] = FOLDER_LOCATION.DescendantAdded:Connect(function(descendant)
		AttemptToConnectToDescendant(descendant)
	end)

	for _, descendant in FOLDER_LOCATION:GetDescendants() do
		AttemptToConnectToDescendant(descendant)
	end
end

function Client:Fire(eventName: string, ...)
	if self._NAMESPACE then
		local folder = FOLDER_LOCATION:FindFirstChild(FOLDER_NAME):FindFirstChild(self._NAMESPACE) :: Folder
		assert(folder and folder:IsA('Folder'), `Namespace folder not created {self._NAMESPACE}`)

		local remote = folder:FindFirstChild(eventName) :: RemoteEvent
		assert(remote and remote:IsA('RemoteEvent'), `RemoteEvent Not Found For Namespace:{self._NAMESPACE} Event: {eventName}`)

		remote:FireServer(...)
	else
		local generalRemote = GetGeneralRemote() :: RemoteEvent
		generalRemote:FireServer(eventName,...)
	end
end

function Client:Disconnect(eventName)
	local onAddedConnection = self._ON_ADDED_CONNECTIONS[eventName] :: RBXScriptConnection
	local remoteConnection = self._REMOTE_CONNECTIONS[eventName] :: RBXScriptConnection

	if onAddedConnection then
		onAddedConnection:Disconnect()
	end

	if remoteConnection then
		remoteConnection:Disconnect()
	end
end

function Client:Destroy()
	local onAddedConnections = self._ON_ADDED_CONNECTIONS 
	local remoteConnection = self._REMOTE_CONNECTIONS

	for _, connection: RBXScriptConnection in pairs(onAddedConnections) do
		connection:Disconnect()
	end

	for _, connection: RBXScriptConnection in pairs(remoteConnection) do
		connection:Disconnect()
	end

	for index, _ in pairs(self) do
        self[index] = nil
    end
end



local Server = {}
Server._NAMESPACE = nil
Server._Events = {}
Server._REMOTE_CONNECTIONS = {}

function Server.new(namespace: string?, methods: {string}?)
	local self = setmetatable({}, {__index = Server})
	self._NAMESPACE = namespace
	self._Events = {}
	self._REMOTE_CONNECTIONS = {}

	if namespace and methods then
		local folder = CreateFolder(namespace, FOLDER_LOCATION:FindFirstChild(FOLDER_NAME))
		for _, eventName in methods do
			self._Events[eventName] = CreateRemote(eventName, folder)
		end
	end

	return self
end


function Server:On(eventName: string, callback: ServerCallBack)
	if self._NAMESPACE then
		local remote = self:_GetNamespaceRemote(eventName)
		self._REMOTE_CONNECTIONS[eventName] = remote.OnServerEvent:Connect(function(player: Player,...)
			callback(player,...)
		end)
	else
		local generalRemote = GetGeneralRemote() :: RemoteEvent
		self._REMOTE_CONNECTIONS[eventName] = generalRemote.OnServerEvent:Connect(function(player: Player, _eventName: string,...)
			if eventName == _eventName then
				callback(player,...)
			end
		end)
	end
end

function Server:Fire(player: Player, eventName: string,...)
	if self._NAMESPACE then
		local remote = self:_GetNamespaceRemote(eventName) :: RemoteEvent
		remote:FireClient(player,...)
	else
		local generalRemote = GetGeneralRemote() :: RemoteEvent
		generalRemote:FireClient(player,eventName,...)
	end
end

function Server:FireAll(eventName: string,...)
	if self._NAMESPACE then
		local remote = self:_GetNamespaceRemote(eventName) :: RemoteEvent
		remote:FireAllClients(...)
	else
		local generalRemote = GetGeneralRemote() :: RemoteEvent
		generalRemote:FireAllClients(eventName,...)
	end
end

function Server:FireList(playerList: {Player}, eventName: string,...)
	if self._NAMESPACE then

		local remote = self:_GetNamespaceRemote(eventName) :: RemoteEvent
		for _, player: Player in playerList do
			remote:FireClient(player,...)
		end

	else

		local generalRemote = GetGeneralRemote() :: RemoteEvent
		for _, player: Player in playerList do
			generalRemote:FireClient(player,eventName,...)
		end
	end
end

function Server:Disconnect(eventName)
	local remoteConnection = self._REMOTE_CONNECTIONS[eventName] :: RBXScriptConnection
	if remoteConnection then
		remoteConnection:Disconnect()
	end
end

function Server:Destroy()
	for _, connection: RBXScriptConnection in pairs(self._REMOTE_CONNECTIONS) do
		connection:Disconnect()
	end

	if self._Events then
		for _, event: RemoteEvent in pairs(self._Events) do
			event:Destroy()
		end
	end

	if self._NAMESPACE then
		local folder = FOLDER_LOCATION:FindFirstChild(FOLDER_NAME):FindFirstChild(self._NAMESPACE)
		if folder then
			folder:Destroy()
		end
	end

	for index, _ in pairs(self) do
        self[index] = nil
    end
end


function Server:_GetNamespaceRemote(eventName: string) : RemoteEvent
	local remote = self._Events[eventName]
	assert(remote and remote:IsA("RemoteEvent"), `{eventName} RemoteEvent Not Found under namespace: {self._NAMESPACE}`)
	return remote
end


local BadNetwork = {}

function BadNetwork.new(namespace: string?, methods: {string}?)
	local self = setmetatable({}, {__index = BadNetwork})

	if namespace and RunService:IsServer() then
		assert(methods,`Event Method Name Table Must Begiven`)
		assert(typeof(methods) =="table", "MethodNames Property Must Be In A Table")
		assert(#methods > 0, "event MethodName Table Can Not Be Empty ")

		for index, value: string? in methods do
			assert(typeof(index) == 'number', 'No Key Names Allowed')
			assert(typeof(value) == 'string', `MethodName Must be String`)
		end
	end

	if RunService:IsServer() then
		self = Server.new(namespace, methods) :: Server
	else
		self = Client.new(namespace) :: Client
	end

	return self
end

return BadNetwork