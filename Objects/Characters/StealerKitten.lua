local StealerKitten = {
	extends = "KinematicBody2D",
	type = "Enemy"
}
local Base = 8000
local Gravity = 10000
local Objects = require("Objects/Miscelaneous/objects")

function StealerKitten:SetMirrored(Body,value)
	Body:set_flip_h(value)
	Body:get_node("Head"):set_flip_h(value)
	Body:get_node("LeftUpperPaw"):set_flip_h(value)
	Body:get_node("RightUpperPaw"):set_flip_h(value)
	Body:get_node("LeftLowerPaw"):set_flip_h(value)
	Body:get_node("RightLowerPaw"):set_flip_h(value)
end

function StealerKitten:GetStarterPawsition()
	return self.StarterPosition
end

function StealerKitten:_ready()
	self.StarterPosition = self.__owner:get_position()
	self.Target = self:get_parent():get_node("Kitten")
	self.Movement = Vector2(0,0)
	self.Can = true
	self.Think = true
	self.Randomizer = RandomNumberGenerator:new()
	self.Raycast = self.__owner:get_node("RayCast2D")
	self.Particles = {}
	self.Tweens = {}
end

function StealerKitten:_RemoveTimer()
	if self.RemoveableTimer then
		self.RemoveableTimer:queue_free()
		self.RemoveableTimer = nil
	end
	self.Think = true
end

function StealerKitten:_RemoveTweens(a,b)
	for index,value in pairs(self.Tweens) do
		if value then
			value:queue_free()
			self.Tweens[index] = nil
		end
	end
end

function StealerKitten:_process(DT)
	for index,value in pairs(self.Particles) do
		if value and not (value:is_emitting()) then
			value:queue_free()
			self.Particles[index] = nil
		end
	end
	if self.Can then
		if (not self.Target) or (tostring(self.Target) == "Null") then
			self.Target = self:get_parent():get_node("Kitten")
		end
		if self.Target then
			local A = self.__owner:get_position()
			local B = self.Target:get_position()
			local Distance = ((A.x-B.x)^2+(A.y-B.y)^2)^0.5
			if self.Think and self.Randomizer then
				--print("I'm thinking of walking")
				self.Think = false
				self.Randomizer:randomize()
				local Wanted = self.Randomizer:randi_range(0,4)-2
				--print("I'll walk for " .. math.abs(Wanted) .. " seconds")
				self.Raycast:set_position(Vector2(100*Wanted,0))
				self.Raycast:set_enabled(true)
				if Distance > 200 then
					if not (tostring(self.Raycast:get_collider()) == "Null") then
						if Wanted > 0 then
							--print("That means i'll to to the right")
							self:SetMirrored(self:get_node("Body"),false)
							self.__owner:get_node("Body"):get_node("Animator"):set_current_animation("Walking")
							local other = Timer:new()
							other:set_one_shot(true)
							other:set_wait_time(math.abs(Wanted))
							self:add_child(other)
							self.Movement.x = Base
							other:start()
							GD.yield(other,"timeout")
							self.Movement.x = 0
							if self.Can then
								self.__owner:get_node("Body"):get_node("Animator"):set_current_animation("Idle")
							end
							other:queue_free()
						elseif Wanted < 0 then
							--print("That means i'll go to the left")
							self:SetMirrored(self:get_node("Body"),true)
							self.__owner:get_node("Body"):get_node("Animator"):set_current_animation("Walking")
							local other = Timer:new()
							other:set_one_shot(true)
							other:set_wait_time(math.abs(Wanted))
							self:add_child(other)
							self.Movement.x = -Base
							other:start()
							GD.yield(other,"timeout")
							self.Movement.x = 0
							if self.Can then
								self.__owner:get_node("Body"):get_node("Animator"):set_current_animation("Idle")
							end
							other:queue_free()
						else
						--print("That means i'll stay")
						end
					else
						--print("There's a void so i'll not go there, too dangerous")
					end
				else
					--Attack
					--print("I shall attack this intruder")
					self.__owner:get_node("Body"):get_node("Animator"):set_current_animation("Spell")
					local new = GD.load("res://Objects/Miscelaneous/Particles/AttackerParticles.tscn"):instance()
					new:set_position(self.Target:get_position())
					self:get_parent():add_child(new)
					new:set_emitting(true)
					self.Particles[#self.Particles+1] = new
					local GUI = self.Target:GetGUI()
					if GUI:get_node("Health") then
						local t = Tween:new()
						--thing,"something:other",start,end,3,3,2,0
						t:interpolate_property(GUI:get_node("Health"),"value",GUI:get_node("Health"):get_as_ratio()*100,(GUI:get_node("Health"):get_as_ratio()-0.1)*100,1,0,3,0)
						self:add_child(t)
						t:start()
						t:connect("tween_completed",self,"_RemoveTweens")
					end
				end
				self.Randomizer:randomize()
				local WaitTime = self.Randomizer:randi_range(1,2)
				--print("I'll wait for " .. WaitTime .. " seconds")
				local t = Timer:new()
				self:add_child(t)
				t:set_wait_time(WaitTime)
				t:set_one_shot(true)
				t:start()
				self.RemoveableTimer = t
				t:connect("timeout",self,"_RemoveTimer")
			end
		end
	end
end

function StealerKitten:_Destroy()
	Objects:Win(self.__owner)
	self.__owner:queue_free()
end

function StealerKitten:Kill()
	self.Movement.x = 0
	self.__owner:get_node("Body"):get_node("Animator"):set_current_animation("Defeat")
	GD.yield(self.__owner:get_node("Body"):get_node("Animator"),"animation_finished")
	local twe = Tween:new()
	twe:set_name("DeathTween")
	twe:interpolate_property(self.__owner,"modulate:a",1,0,1,3,2,0)
	self:add_child(twe)
	twe:start()
	twe:connect("tween_completed",self,"_Destroy")
end

function StealerKitten:_physics_process(DT)
	if not self:is_on_floor() then
		self.Movement.y = math.lerp(self.Movement.y,Gravity,0.2)
	else
		self.Movement.y = 0
	end
	self:move_and_slide((self.Movement-(Vector2.UP*Gravity))*DT,Vector2.UP)
end

function StealerKitten:_input_event(viewport,Event)
	if Event.pressed and Event.button_index == 1 then
		if self.Target then
			if self.Target:GetGUI() then
				local GUI = self.Target:GetGUI()
				if GUI:get_node("Magic"):get_as_ratio() >= 0.1 then
					if self.Can then
						self.Can = false
						self:Kill()
					end
				end
			end
		end
	end
end

return StealerKitten
