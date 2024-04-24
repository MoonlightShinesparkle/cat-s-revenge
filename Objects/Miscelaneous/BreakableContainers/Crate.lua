local Crate = {
	extends = "Area2D",
}
local Objects = require("Objects/Miscelaneous/objects")

function Crate:_ready()
	self.Kitten = self.__owner:get_parent():get_parent():get_node("Kitten")
	self.Can = true
end

function Crate:_process(DT)
	if (tostring(self.Kitten) == "Null") or (not self.Kitten) then
		self.Kitten = self:get_tree():get_current_scene():find_node("Kitten",true,true)
	end
end

function Crate:Destroy()
	if not Objects.Initiated then
		Objects:Init()
	end
	Objects:New(self,self:get_parent():get_parent():get_node("Pickables"))
	self.__owner:get_node("Destroying"):set_emitting(true)
	local tw = Tween:new()
	tw:set_name("TransparencyTween")
	tw:interpolate_property(self.__owner:get_node("Sprite"),"modulate:a",1,0,1,3,2,0)
	self.__owner:add_child(tw)
	tw:start()
	GD.yield(tw,"tween_completed")
	self.__owner:get_node("Destroying"):set_emitting(false)
	Objects:Win(self.__owner)
	tw:queue_free()
	self.__owner:queue_free()
end

function Crate:_input_event(viewport,Event)
	if Event.pressed and Event.button_index == 1 then
		if self.Kitten then
			if self.Kitten:GetGUI() then
				local GUI = self.Kitten:GetGUI()
				if GUI:get_node("Magic"):get_as_ratio() >= 0.1 then
					if self.Can then
						self:Destroy()
						self.Can = false
					end
				end
			end
		end
	end
end

return Crate
