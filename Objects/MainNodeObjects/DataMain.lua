local DataMain = {
	extends = "Node2D",
}

local SavePath = "res://catrevenge/save.meow"
local Config = ConfigFile:new()
local LoadResponse = Config:load(SavePath)
local Objects = require("Objects/Miscelaneous/objects")
local section = "Collected"

function DataMain:Save()
	local Saveable = Objects:GetCollected()
	print(":::::::::save:::::::::")
	for index,value in pairs(Saveable) do
		Config:set_value(section,value,Config:get_value(section,value,0)+1)
		print(value..": "..Config:get_value(section,value))
	end
	Config:save(SavePath)
	Objects:Forget()
	print("::::::::::::::::::")
end

function DataMain:GetAll()
	local Returnable = {}
	pcall(function()
		for index,value in pairs(Config:get_section_keys(section)) do
			Returnable[value] = Config:get_value(section,value)
		end
	end)
	return Returnable
end

return DataMain
