local Kitten = {
	extends = "KinematicBody2D",
	type = "Player",
	endata = "",
	cansave = true,
	winning = false
}
local Base = 9000
local Gravity = 10000
local Jump = 180000
local Min = 30
local BUTTON_LEFT = 1
local BUTTON_RIGHT = 2

function Kitten:SetMirrored(Body,value)
	Body:set_flip_h(value)
	Body:get_node("Head"):set_flip_h(value)
	Body:get_node("LeftUpperPaw"):set_flip_h(value)
	Body:get_node("RightUpperPaw"):set_flip_h(value)
	Body:get_node("LeftLowerPaw"):set_flip_h(value)
	Body:get_node("RightLowerPaw"):set_flip_h(value)
end

function Kitten:_LoadGui()
	if self.winning then
		return
	end
	print("Loading")
	local stats = GD.load("res://Objects/Stats.tscn"):instance()
	stats:set_name("MagicGui")
	self.__owner:get_parent():add_child(stats)
	self.StatsGui = stats
end

function Kitten:GetGUI()
	return self.StatsGui
end

function Kitten:_DestroyParticle()
	for index,value in pairs(self.Particles or {}) do
		if value and value:get_frame() == 8 then
			value:queue_free()
			self.Particles[index] = nil
			if value == self.Latest then
				self.Attacking = false
			end
		end
	end
end

function Kitten:_ready()
	self.Alive = true
	self.Movement = Vector2(0,0)
	self.Attacking = false
	self.StarterPosition = self:get_position()
	self.Body = self:get_node("Body")
	self.Animator = self.Body:get_node("Animator")
	self.Regenerating = false
	self.Particles = {}
	self.Tweens = {}
	self.Teleporting = false
	self:call_deferred("_LoadGui")
	--self:_LoadGui()
end

function Kitten:SetStarterPosition(Pawsition)
	self.StarterPosition = Pawsition
end

function Kitten:_ClearTweens()
	for index,value in pairs(self.Tweens) do
		if value then
			value:queue_free()
			self.Tweens[index] = nil
		end
	end
end

function Kitten:_TeleportToStart()
	self:set_position(self.StarterPosition)
	self.Teleporting = false
end

function Kitten:TeleportBack()
	if self.winning then
		return
	end
	self.Teleporting = true
	local t = Tween:new()
	self.Tweens[#self.Tweens+1] = t
	t:interpolate_property(self.StatsGui:get_node("TopPanel"),"rect_size:y",0,300,1,3,2,0)
	t:interpolate_property(self.StatsGui:get_node("BottomPanel"),"rect_size:y",0,300,1,3,2,0)
	self:add_child(t)
	t:start()
	t:connect("tween_completed",self,"_TeleportToStart")
	local o = Tween:new()
	self.Tweens[#self.Tweens+1] = o
	o:interpolate_property(self.StatsGui:get_node("TopPanel"),"rect_size:y",300,0,1,3,2,0)
	o:interpolate_property(self.StatsGui:get_node("BottomPanel"),"rect_size:y",300,0,1,3,2,0)
	self:add_child(o)
	o:start()
	o:connect("tween_completed",self,"_ClearTweens")
end

function Kitten:_menu()
	local main = self:get_node("/root/Main")
	main:Continue()
end

function Kitten:_die()
	if self.winning then
		return
	end
	local player = self:get_node("/root/Main"):get_node("MainPlayer")
	player:stop()
	local Song = GD.load("res://Music/Songs/Fail.wav")
	player:set_stream(Song)
	player:play()
	local t = Tween:new()
	self.Tweens[#self.Tweens+1] = t
	t:interpolate_property(self.StatsGui:get_node("TopPanel"),"rect_size:y",0,300,1,3,2,0)
	t:interpolate_property(self.StatsGui:get_node("BottomPanel"),"rect_size:y",0,300,1,3,2,0)
	t:interpolate_property(self.StatsGui:get_node("GameOverTxt"),"modulate:a",0,1,0,3,2,0)
	self:add_child(t)
	t:start()
	local n = Timer:new()
	self:add_child(n)
	n:set_wait_time(4)
	n:start()
	n:set_one_shot(true)
	n:connect("timeout",self,"_menu")
end

function Kitten:_stats()
	if self.cansave then
		self.cansave = false
		local stats = self.endata
		self.StatsGui:get_node("GameOverTxt"):set_text("Ended up with:\n"..stats)
		self:get_node("/root/DataMain"):Save()
		local n = Timer:new()
		self:add_child(n)
		n:set_wait_time(4)
		n:start()
		n:set_one_shot(true)
		n:connect("timeout",self,"_menu")
	end
end

function Kitten:_win()
	if self.winning then
		return
	end
	self.winning = true
	local player = self:get_node("/root/Main"):get_node("MainPlayer")
	player:stop()
	local Song = GD.load("res://Music/Songs/Win.wav")
	player:set_stream(Song)
	self.StatsGui:get_node("GameOverTxt"):set_text("You recovered your items!")
	local endstats = ""
	endstats = endstats .. "Health: " .. tostring(self.StatsGui:get_node("Health"):get_as_ratio()*100)
	local stats = require("Objects/Miscelaneous/objects"):GetCollected()
	if stats and type(stats) == "table" then
		if #stats > 0 then
			endstats = endstats .. "\n"
		end
		for index,value in pairs(stats) do
			endstats = endstats .. tostring(value) .. "\n"
		end
	end
	self.endata = endstats
	player:play()
	local t = Tween:new()
	self.Tweens[#self.Tweens+1] = t
	t:interpolate_property(self.StatsGui:get_node("TopPanel"),"rect_size:y",0,300,1,3,2,0)
	t:interpolate_property(self.StatsGui:get_node("BottomPanel"),"rect_size:y",0,300,1,3,2,0)
	t:interpolate_property(self.StatsGui:get_node("GameOverTxt"),"modulate:a",0,1,0,3,2,0)
	self:add_child(t)
	t:start()
	local n = Timer:new()
	self:add_child(n)
	n:set_wait_time(4)
	n:start()
	n:set_one_shot(true)
	n:connect("timeout",self,"_stats")
end

function Kitten:_process(DT)
	if self.winning then
		return
	end
	if self.Alive then
		if not self.Body then
			self.Body = self.__owner:get_node("Body")
		end
		if not self.Attacking then
			if self.Movement.x > Min then
				if self.Body:is_flipped_h() == true then
					Kitten:SetMirrored(self.Body,false)
				end
				if self.Animator:get_current_animation() ~= "Walking" then
					self.Animator:set_current_animation("Walking")
				end
			elseif self.Movement.x < -Min then
				if self.Body:is_flipped_h() == false then
					Kitten:SetMirrored(self.Body,true)
				end
				if self.Animator:get_current_animation() ~= "BackWalking" then
					self.Animator:set_current_animation("BackWalking")
				end
			else
				if self.Animator:get_current_animation() ~= "Idle" then
					self.Animator:set_current_animation("Idle")
				end
			end
		end
		if self.StatsGui then
			if self.StatsGui:get_node("Health"):get_as_ratio() <= 0 then
				self.Alive = false
			end
		end
	else
		if (self.Animator:get_current_animation() ~= "Defeat") then
			if not self.Dead then
				self.Animator:set_current_animation("Defeat")
				self.Dead = true
				self.Animator:connect("animation_finished",self,"_die")
			end
		end
	end
end

function Kitten:_physics_process(DT)
	if self.winning then
		return
	end
	if not self.Attacking then
		self.Movement.x = math.lerp(self.Movement.x,0,0.2)
	end
	if not self:is_on_floor() then
		self.Movement.y = math.lerp(self.Movement.y,Gravity,0.2)
	else
		self.Movement.y = 0
	end
	if self.Alive then
		if (not self.Attacking) and (not self.Regenerating) then
			if Input:is_action_pressed("Left") then
				self.Movement.x = Base*-1
			end
			if Input:is_action_pressed("Right") then
				self.Movement.x = Base
			end
			if Input:is_action_pressed("Jump") and self:is_on_floor() then
				self.Movement.y = -Jump
			end
		end
	else
		self.Movement.x = 0
	end
	self:move_and_slide((self.Movement-(Vector2.UP*Gravity))*DT,Vector2.UP)
end

function Kitten:_unhandled_input(Event)
	if self.winning then
		return
	end
	if tostring(Event):find("InputEventMouseButton") and self.Alive then
		if Event.button_index == BUTTON_LEFT and Event.pressed then
			if self.StatsGui:get_node("Magic"):get_as_ratio() >= 0.1 and (not self.Regenerating) and not self.Attacking then
				self.Attacking = true
				if self.Animator:get_current_animation() == "Walking" then
					if self.Body:is_flipped_h() then
						self.Animator:set_current_animation("BackWalkingSpell")
					else
						self.Animator:set_current_animation("WalkingSpell")
					end
				else
					if self.Body:is_flipped_h() then
						self.Animator:set_current_animation("BackSpell")
					else
						self.Animator:set_current_animation("Spell")
					end
				end
				local Pawsition = self:get_global_mouse_position()
				local tw = Tween:new()
				local ti = Timer:new()
				tw:set_name("De-magicTween")
				ti:set_name("De-magicTimer")
				self:add_child(tw)
				self:add_child(ti)
				tw:interpolate_property(self.StatsGui:get_node("Magic"),"value",self.StatsGui:get_node("Magic"):get_as_ratio()*100,(self.StatsGui:get_node("Magic"):get_as_ratio()-0.1)*100,0.1,3,2,0)
				--tween:interpolate_property(self.StatsGui:get_node("Magic"),"value",0,10,2,3,2,0)
				--self.StatsGui:get_node("Magic"):set_as_ratio(self.StatsGui:get_node("Magic"):get_as_ratio()-0.1)
				ti:set_one_shot(true)
				ti:set_wait_time(0.1)
				local MagicParticle = GD.load("res://Objects/Magic.tscn"):instance()
				MagicParticle:set_position(Pawsition)
				self.__owner:get_parent():add_child(MagicParticle)
				self.Particles[#self.Particles+1] = MagicParticle
				self.Latest = MagicParticle
				MagicParticle:connect("animation_finished",self,"_DestroyParticle")
				MagicParticle:play("default")
				tw:start()
				ti:start()
				GD.yield(ti,"timeout")
				tw:queue_free()
				ti:queue_free()
			end
		elseif Event.button_index == BUTTON_RIGHT and Event.pressed then
			if (self.StatsGui:get_node("Magic"):get_as_ratio() < .1) and not self.Regenerating then
				self.Regenerating = true
				local tween = Tween:new()
				local timer = Timer:new()
				tween:set_name("MagicTween")
				timer:set_name("MagicTimer")
				self:add_child(tween)
				self:add_child(timer)
				tween:interpolate_property(self.StatsGui:get_node("Magic"),"value",0,10,2,3,2,0)
				tween:start()
				timer:set_one_shot(true)
				self.StatsGui:get_node("Magic"):get_node("Particle"):get_node("ChargeParticle"):set_emitting(true)
				timer:set_wait_time(2)
				timer:start()
				GD.yield(timer,"timeout")
				timer:queue_free()
				tween:queue_free()
				self.Regenerating = false
			end
		end
	end
end
return Kitten
