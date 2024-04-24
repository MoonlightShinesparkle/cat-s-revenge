local light = {
	extends = "Light2D",
	time = 0
}

function light:_ready()
	self.colorinit = self:get_color()
end

function light:_process(DT)
	if not self.colorinit then return end
	self.time = self.time + DT
	self:set_color(Color(self.colorinit.r,self.colorinit.g,self.colorinit.b,1-(math.sin(self.time*2)*0.2)))
end

return light
