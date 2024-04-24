local objects = {
	Initiated = false,
	Randomizer = nil
}
local function FromRGBA(R,G,B,A)
	return Color(R/255,G/255,B/255,A)
end
local list = {
	Magic = {
		Name = "Magic",
		Prefix = "res://Textures/Powerups/Magic/",
		PColor = FromRGBA(29,197,255,1),
		Objects = {}
	},
	Health = {
		Name = "Health",
		Prefix = "res://Textures/Powerups/Health/",
		PColor = FromRGBA(255,29,82,1),
		Objects = {}
	},
	Collectables = {
		Name = "Collectables",
		Prefix = "res://Textures/Collectables/",
		PColor = FromRGBA(255,255,29,1),
		Objects = {}
	}
}
local indexes = {}
local collected = {}

function objects:Init()
	for index,value in pairs(list) do
		indexes[#indexes+1] = index
	end
	local Dir = Directory:new()
	print("Magic\n-·-·-·-·-·-·-·-·-·-·-")
	Dir:open("res://Textures/Powerups/Magic")
	Dir:list_dir_begin(true,true)
	local Next = Dir:get_next()
	while Next ~= "" do
		if not Dir:current_is_dir() then
			if not string.find(tostring(Next),".import") then
				print(Next)
				list.Magic.Objects[#list.Magic.Objects+1] = Next
			end
		end
		Next = Dir:get_next()
	end
	Next = nil
	print("-·-·-·-·-·-·-·-·-·-·-")
	
	print("Health\n-·-·-·-·-·-·-·-·-·-·-")
	Dir:open("res://Textures/Powerups/Health")
	Dir:list_dir_begin(true,true)
	local Next = Dir:get_next()
	while Next ~= "" do
		if not Dir:current_is_dir() then
			if not string.find(tostring(Next),".import") then
				print(Next)
				list.Health.Objects[#list.Health.Objects+1] = Next
			end
		end
		Next = Dir:get_next()
	end
	Next = nil
	print("-·-·-·-·-·-·-·-·-·-·-")
	print("Collectables\n-·-·-·-·-·-·-·-·-·-·-")
	
	Dir:open("res://Textures/Collectables")
	Dir:list_dir_begin(true,true)
	local Next = Dir:get_next()
	while Next ~= "" do
		if not Dir:current_is_dir() then
			if not string.find(tostring(Next),".import") then
				print(Next)
				list.Collectables.Objects[#list.Collectables.Objects+1] = Next
			end
		end
		Next = Dir:get_next()
	end
	Next = nil
	print("-·-·-·-·-·-·-·-·-·-·-")
	self.Initiated = true
end

function Random(min,max)
	if not objects.Randomizer then
		objects.Randomizer = RandomNumberGenerator:new()
	end
	objects.Randomizer:randomize()
	return objects.Randomizer:randi_range(min,max)
end

function objects:Forget()
	collected = {}
end

function objects:GetCollected()
	return collected
end

function objects:PickCollectable(Meta)
	print("Collectible metadata --------------")
	print(Meta)
	print("----------------------------")
	if Meta then
		print("Collected " .. Meta)
	end
	collected[#collected+1] = Meta
end

function objects:New(Base,Parent)
	if Random(1,100) < 40 then
		--Object
		local new = GD.load("res://Objects/Miscelaneous/PickupBase.tscn"):instance()
		local Chosen = list[indexes[Random(1,#indexes)]]
		new:get_node("Particles"):set_color(Chosen.PColor)
		new:set_position(Base:get_position())
		print("Objectdata")
		print("-~-~-~-~-~-~-~-~-~-~-")
		print(Chosen.Prefix)
		print(Chosen.Objects," ["..#Chosen.Objects.."]")
		local Textur = Chosen.Objects[Random(1,#Chosen.Objects)]
		print(Textur)
		print("-~-~-~-~-~-~-~-~-~-~-")
		new:get_node("Sprite"):set_texture(GD.load(Chosen.Prefix..Textur))
		new:set_type(Chosen.Name,Textur:gsub(".png",""))
		new:set_meta(Textur:gsub(".png",""))
		print(Parent)
		if (not Parent) or (tostring(Parent) == "Null") then
			Base:get_parent():add_child(new)
		else
			Parent:add_child(new)
		end
		return new
	end
end

function objects:NewPawCoin(Base,Parent)
	local new = GD.load("res://Objects/Miscelaneous/PickupBase.tscn"):instance()
	local chosen = list.Collectables
	new:get_node("Particles"):set_color(chosen.pcolor)
	new:set_position(Base:get_position())
	new:get_node("Sprite"):set_texture(GD.load(chosen.Prefix.."PawCoin.png"))
	new:set_type(chosen.Name,"PawCoin")
	if (not Parent) or (tostring(Parent) == "Null") then
		Base:get_parent():add_child(new)
	else
		Parent:add_child(new)
	end
end

function objects:Win(Base)
	print("-.-.-.-.-.-.-.-.-.-Basedata-.-.-.-.-.-.-.-.-.-")
	print(Base:get_name())
	print("-.-.-.-.-.-.-.-.-.-Tabledata-.-.-.-.-.-.-.-.-.-")
	local Game
	local Kind
	local t = {}
	if Base:get_parent():get_name():lower() == "destroyables" then
		Game = Base:get_parent():get_parent()
		Kind = "destroyables"
	elseif Base:get_parent():get_name():lower() == "pickables" then
		Game = Base:get_parent():get_parent()
		Kind = "pickables"
	else
		Game = Base:get_parent()
		Kind = "other"
	end
	print("Game:",Game)
	local Pickables,Destroyables = Game:get_node("Pickables"),Game:get_node("Destroyables")
	for index,value in pairs(Pickables:get_children()) do
		if Kind == "pickables" then
			if value == Base then
				print(value:get_name() .. " ignore <--------")
				goto continue
			end
		end
		print(value)
		t[#t+1] = value
		::continue::
	end
	for index,value in pairs(Destroyables:get_children()) do
		if Kind == "destroyables" then
			if value == Base then
				print(value:get_name() .. " ignore <--------")
				goto continue2
			end
		end
		print(value:get_name())
		t[#t+1] = value
		::continue2::
	end
	print("["..tostring(#t).." in total]")
	if #t <= 0 then
		print("game winable!")
		if Game:get_node("Kitten") then
			Game:get_node("Kitten"):_win(collected)
		end
	end
	print("-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-")
end

return objects
