local selector = {}

function Random(min,max)
	if not selector.Randomizer then
		selector.Randomizer = RandomNumberGenerator:new()
	end
	selector.Randomizer:randomize()
	return selector.Randomizer:randi_range(min,max)
end

function selector:get_random_scene()
	local Scene
	local Prefix = "res://Objects/Scenes/"
	local Dir = Directory:new()
	Dir:open(Prefix)
	Dir:list_dir_begin(true,true)
	local Next = Dir:get_next()
	local Pawsible = {}
	print("=-=-=-=-=-Scenes-=-=-=-=-=-=")
	while Next ~= "" do
		if not Dir:current_is_dir() then
			if not string.find(tostring(Next),".import") then
				if string.find(tostring(Next),".tscn") then
					print(tostring(Next))
					Pawsible[#Pawsible+1] = Prefix..tostring(Next)
				end
			end
		end
		Next = Dir:get_next()
	end
	print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
	local chosen = Pawsible[Random(1,#Pawsible)]
	Scene = GD.load(chosen):instance()
	if not Scene then
		chosen = "Debug"
		Scene = GD.load("res://Objects/Debug.tscn"):instance()
	end
	print("Chosen instance: ",Scene, Scene:get_name())
	print("["..tostring(chosen).."]")
	print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
	return Scene
end

return selector
