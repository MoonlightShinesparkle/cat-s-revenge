local Pickable = {
	extends = "Area2D",
	Meta = "Coffee",
	Type = "Magic"
}
local Objects = require("Objects/Miscelaneous/objects")

function Pickable:set_type(Type,Meta)
	print("-^-^-^-^-set type-^-^-^-^-")
	if Type == "Magic" then
		self.Type = "Magic"
	elseif Type == "Health" then
		self.Type = "Health"
	elseif Type == "Collectables" then
		self.Type = "Collectables"
	else
		self.Type = nil
		print("Got unexpected Type \"" .. Type .. "\"" )
	end
	self.Meta = Meta
	pcall(function()
		print("Set meta to: ".. Meta)
	end)
end

function Pickable:set_meta(Meta)
	print("-^-^-^-^-set meta-^-^-^-^-")
	pcall(function()
		print("Set meta to: " .. Meta)
	end)
	self.Meta = Meta
end

function Pickable:_ready()
	self.Can = true
	pcall(function()
		self.Kitten = self:get_parent():get_node_or_null("Kitten")
	end)
	if tostring(self.Kitten) == "Null" then
		self.Kitten = self:get_parent():get_parent():get_node("Kitten")
	end
end

function Pickable:_Destroy()
	if self.Type == "" then
		
	end
	Objects:Win(self.__owner)
	print(self,self:get_parent())
	self:queue_free()
end

function Pickable:_process(DT)
	if (not self.Kitten) or (tostring(self.Kitten) == "Null") then
		pcall(function()
			self.Kitten = self:get_parent():get_node_or_null("Kitten")
		end)
		if tostring(self.Kitten) == "Null" then
			self.Kitten = self:get_parent():get_parent():get_node("Kitten")
		end
	end
	if self.Can then
		for index,value in pairs(self:get_overlapping_bodies()) do
			if value.type then
				if value.type == "Player" then
					if self.Type == "Magic" then
						self.Can = false
						local GUI = self.Kitten:GetGUI()
						if GUI:get_node("Magic") then
							local t = Tween:new()
							t:interpolate_property(GUI:get_node("Magic"),"value",GUI:get_node("Magic"):get_as_ratio()*100,(GUI:get_node("Magic"):get_as_ratio()+0.5)*100,1,0,3,0)
							t:interpolate_property(self:get_node("Sprite"),"modulate:a",1,0,1,0,3,0)
							self:add_child(t)
							t:start()
							t:connect("tween_completed",self,"_Destroy")
						end
					elseif self.Type == "Health" then
						self.Can = false
						local GUI = self.Kitten:GetGUI()
						if GUI:get_node("Health") then
							local t = Tween:new()
							t:interpolate_property(GUI:get_node("Health"),"value",GUI:get_node("Health"):get_as_ratio()*100,(GUI:get_node("Health"):get_as_ratio()+0.5)*100,1,0,3,0)
							t:interpolate_property(self:get_node("Sprite"),"modulate:a",1,0,1,0,3,0)
							self:add_child(t)
							t:start()
							t:connect("tween_completed",self,"_Destroy")
						end
					elseif self.Type == "Collectables" then
						self.Can = false
						print("About to pick collectable -.-.-.-.-.-.-.-.-.-")
						Objects:PickCollectable(self.Meta)
						self:_Destroy()
					end
				end
			end
		end
	end
end

return Pickable
