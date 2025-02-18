
local function CreateInstanceFromValue(index, data: any): Instance | nil
	-- Guard clause for unsupported data types
	if typeof(data) ~= "number" and typeof(data) ~= "string" and typeof(data) ~= "boolean" then
		warn("Unsupported data type for: ", index)
		return nil
	end

	local instance: ValueBase

	if typeof(data) == "number" then
		instance = Instance.new('NumberValue')
	elseif typeof(data) == "string" then
		instance = Instance.new('StringValue')
	elseif typeof(data) == "boolean" then
		instance = Instance.new('BoolValue')
	end

	instance.Name = index
	instance.Value = data

	return instance
end

local function CreateFolderFromTable(folderName: string, dataTable: {}, parent: Instance)
	-- Guard clause for invalid data types
	if typeof(dataTable) ~= "table" then
		warn(folderName, "is not a valid table")
		return
	end

	local folder = Instance.new('Folder')
	folder.Name = folderName
	folder.Parent = parent

	for index: string, value: any in pairs(dataTable) do
		if typeof(value) == 'table' then
			-- Recursive call for nested tables
			CreateFolderFromTable(index, value, folder)
		else
			-- Create value instance for non-table values
			local valueInstance = CreateInstanceFromValue(index, value)
			if valueInstance then
				valueInstance.Parent = folder
			end
		end
	end
end



local DataToInstance = {}

function DataToInstance.Fire(ParentInstance: Instance, tableWithValues: {string: any})

	for index: string, value: any in pairs(tableWithValues) do
		if typeof(value) == 'table' then
			-- Recursive call for nested tables
			CreateFolderFromTable(index, value, ParentInstance)
		else
			-- Create value instance for non-table values
			local valueInstance = CreateInstanceFromValue(index, value)
			if valueInstance then
				valueInstance.Parent = ParentInstance
			end
		end
	end
end

return DataToInstance