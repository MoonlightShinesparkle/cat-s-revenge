local DestroyerFox = {
	extends = "KinematicBody2D",
}

function DestroyerFox:_pick_crate(B,T)
	print("fired!")
	self:get_node("Body"):get_node("Animator"):set_current_animation("WalkingCrate")
	local tween = Tween:new()
	self:add_child(tween)
	tween:interpolate_property(self,"position",self:get_position(),B,T,0,2,0)
	tween:start()
	tween:connect(self,"tween_completed","queue_free")
end

function DestroyerFox:Init(A,B,T,W)
	print(A,B,T,W)
	self:get_node("Body"):get_node("Animator"):set_current_animation("Walking")
	local tween = Tween:new()
	self:add_child(tween)
	tween:interpolate_property(self,"position",self:get_position(),A,T,0,2,0)
	local timer = Timer:new()
	self:add_child(timer)
	timer:set_one_shot(true)
	timer:set_wait_time(T+W)
	timer:start() 
	tween:start() 
	GD.yield(timer,"timeout")
	tween:stop_all()
	tween:queue_free()
	self:_pick_crate(B,T)
end

return DestroyerFox
