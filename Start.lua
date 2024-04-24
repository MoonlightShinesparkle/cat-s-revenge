local Start = {
	extends = "Node2D",
}
local objects = require("Objects/Miscelaneous/objects")
function Start:_LoadGame()
	local MPlayer = self.__owner:get_node("MainPlayer")
	MPlayer:disconnect("finished",self,"_LoadGame")
	if self.StealingScene then
		self.StealingScene:queue_free()
		self.StealingScene = nil
	end
	local Song = GD.load("res://Music/Songs/RevengefulCatPaws.wav")
	MPlayer:stop()
	MPlayer:set_stream(Song)
	MPlayer:play()
	local n = require("Objects/Scenes/selector"):get_random_scene()
	self.Level = n
	self:add_child(n)
end

function Start:_Play()
	if self.CurrentGui then
		self.CurrentGui:queue_free()
		self.CurrentGui = nil
	end
	local MPlayer = self.__owner:get_node("MainPlayer")
	MPlayer:stop()
	local Song = GD.load("res://Music/Songs/Stealing.wav")
	MPlayer:set_stream(Song)
	MPlayer:play()
	local Scene = self.StealingScene
	local House = Scene:get_node("AnimatedSprite")
	local Fox = GD.load("res://Objects/MainNodeObjects/DestroyerFox.tscn"):instance()
	Fox:set_position(Vector2(320,482))
	Fox:set_z_index(-3)
	Scene:add_child(Fox)
	Fox:Init(Vector2(511.5,482),Vector2(700,482),2,0)
	local Waiter = Timer:new()
	Waiter:set_name("WaiterTimer")
	self:add_child(Waiter)
	Waiter:set_one_shot(true)
	Waiter:set_wait_time(6)
	Waiter:start()
	GD.yield(Waiter,"timeout")
	House:set_animation("Break")
	MPlayer:connect("finished",self,"_LoadGame")
end

function Start:_HideStats()
	if not self.CurrentGui then
		return
	end
	local GUI = self.CurrentGui:get_node("ObtainedItems")
	GUI:set_modulate(Color(1,1,1,0))
	GUI:set_mouse_filter(2)
	GUI:get_node("Topbar"):set_mouse_filter(2)
	GUI:get_node("Topbar"):get_node("TextLabel"):set_mouse_filter(2)
	GUI:get_node("Topbar"):get_node("CloseButton"):set_mouse_filter(2)
	GUI:get_node("ScrollContainer"):set_mouse_filter(2)
	GUI:get_node("ScrollContainer"):get_node("GridContainer"):set_mouse_filter(2)
	for index,value in pairs(GUI:get_node("ScrollContainer"):get_node("GridContainer"):get_children()) do
		value:queue_free()
	end
end

function Start:_ShowStats()
	if not self.CurrentGui then
		return
	end
	local GUI = self.CurrentGui:get_node("ObtainedItems")
	GUI:set_modulate(Color(1,1,1,1))
	GUI:set_mouse_filter(0)
	GUI:get_node("Topbar"):set_mouse_filter(0)
	GUI:get_node("Topbar"):get_node("TextLabel"):set_mouse_filter(0)
	GUI:get_node("Topbar"):get_node("CloseButton"):set_mouse_filter(0)
	GUI:get_node("ScrollContainer"):set_mouse_filter(0)
	GUI:get_node("ScrollContainer"):get_node("GridContainer"):set_mouse_filter(0)
	local Prefix = "res://Textures/Collectables/"
	local Posfix = ".png"
	for index,value in pairs(self:get_node("/root/DataMain"):GetAll()) do
		local Unit = GD.load("res://Objects/MainNodeObjects/ScrollUnit.tscn"):instance()
		local success, err = pcall(function()
			Unit:get_node("Background"):get_node("Image"):set_texture(GD.load(Prefix .. index .. Posfix))
		end)
		Unit:get_node("Background"):get_node("TextLabel"):set_text(tostring(value))
		GUI:get_node("ScrollContainer"):get_node("GridContainer"):add_child(Unit)
	end
end

function Start:_ready()
	print("[Collected]")
	for index,value in pairs(self:get_node("/root/DataMain"):GetAll()) do
		print(index.." = "..value)
	end
	--Tween
	local tween = Tween:new()
	tween:set_name("GUITween")
	self:add_child(tween)
	
	--Timer
	local timer = Timer:new()
	timer:set_name("GUITimer")
	self:add_child(timer)
	
	local GUI = GD.load("res://StartScreen.res"):instance()
	self:add_child(GUI)
	self.CurrentGui = GUI
	
	local Black = GUI:get_node("Background")
	local Txt = GUI:get_node("StartScreen")
	local Title = GUI:get_node("Title")
	
	print(GUI,Black,Txt)
	print("Start")
	
	tween:interpolate_property(Txt,"modulate:a",0,255,3,3,2,0)
	tween:start()
	
	timer:set_one_shot(true)
	timer:set_wait_time(3)
	timer:start()
	GD.yield(timer,"timeout")
	timer:queue_free()
	
	tween:interpolate_property(Txt,"modulate:a",255,0,3,3,2,0)
	tween:start()
	
	local timer = Timer:new()
	timer:set_name("GUITimer")
	self:add_child(timer)
	timer:set_one_shot(true)
	timer:set_wait_time(3)
	timer:start()
	GD.yield(timer,"timeout")
	timer:queue_free()
	
	tween:interpolate_property(Title:get_node("Label"),"percent_visible",0,1,2,3,2,0)
	tween:start()
	
	local timer = Timer:new()
	timer:set_name("GUITimer")
	self:add_child(timer)
	timer:set_one_shot(true)
	timer:set_wait_time(2)
	timer:start()
	GD.yield(timer,"timeout")
	timer:queue_free()
	
	tween:interpolate_property(Title,"rect_position:y",200,0,1,0,0,0)
	local tweenb = Tween:new()
	tweenb:set_name("GUITween2")
	self:add_child(tweenb)
	local BackgroundScene = GD.load("res://Objects/MainNodeObjects/MainPlace.tscn"):instance()
	self:add_child(BackgroundScene)
	self.StealingScene = BackgroundScene
	BackgroundScene:get_node("Camera2D"):_set_current(true)
	tweenb:interpolate_property(Black,"modulate:a",1,0,1,0,0,0)
	tween:start()
	tweenb:start()
	
	local MPlayer = self.__owner:get_node("MainPlayer")
	local Song = GD.load("res://Music/Songs/CalmNight.wav")
	MPlayer:set_stream(Song)
	MPlayer:play()
	
	local timer = Timer:new()
	timer:set_name("GUITimer")
	self:add_child(timer)
	timer:set_one_shot(true)
	timer:set_wait_time(1)
	timer:start()
	GD.yield(timer,"timeout")
	timer:queue_free()
	tweenb:queue_free()
	
	GUI:get_node("Background"):queue_free()
	GUI:get_node("StartScreen"):queue_free()
	local Start,AdqObj = GUI:get_node("Buttons"):get_node("Play"),GUI:get_node("Buttons"):get_node("RecoveredObjects")
	Start:connect("pressed",self,"_Play")
	AdqObj:connect("pressed",self,"_ShowStats")
	GUI:get_node("ObtainedItems"):get_node("Topbar"):get_node("CloseButton"):connect("pressed",self,"_HideStats")
end

function Start:Continue()
	local GUI = GD.load("res://StartScreen.res"):instance()
	self:add_child(GUI)
	self.CurrentGui = GUI
	if self.Level then
		self.Level:queue_free()
		self.Level = nil
	end
	local Black = GUI:get_node("Background")
	local Txt = GUI:get_node("StartScreen")
	local Title = GUI:get_node("Title")
	
	local timer = Timer:new()
	self:add_child(timer)
	timer:set_one_shot(true)
	timer:set_wait_time(3)
	timer:start()
	GD.yield(timer,"timeout")
	timer:queue_free()
	local t = Tween:new()
	self:add_child(t)
	t:interpolate_property(Title:get_node("Label"),"percent_visible",0,1,2,3,2,0)
	t:start()
	GD.yield(t,"tween_completed")
	t:queue_free()
	t = Tween:new()
	self:add_child(t)
	t:interpolate_property(Title,"rect_position:y",200,0,1,0,0,0)
	local BackgroundScene = GD.load("res://Objects/MainNodeObjects/MainPlace.tscn"):instance()
	self:add_child(BackgroundScene)
	self.StealingScene = BackgroundScene
	BackgroundScene:get_node("Camera2D"):_set_current(true)
	t:interpolate_property(Black,"modulate:a",1,0,1,0,0,0)
	t:start()
	
	local MPlayer = self.__owner:get_node("MainPlayer")
	local Song = GD.load("res://Music/Songs/CalmNight.wav")
	MPlayer:set_stream(Song)
	MPlayer:play()
	
	GUI:get_node("Background"):queue_free()
	GUI:get_node("StartScreen"):queue_free()
	local Start,AdqObj = GUI:get_node("Buttons"):get_node("Play"),GUI:get_node("Buttons"):get_node("RecoveredObjects")
	Start:connect("pressed",self,"_Play")
	AdqObj:connect("pressed",self,"_ShowStats")
	GUI:get_node("ObtainedItems"):get_node("Topbar"):get_node("CloseButton"):connect("pressed",self,"_HideStats")
end

return Start
