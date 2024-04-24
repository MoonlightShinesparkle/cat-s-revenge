local HealthBarParticles = {
	extends = "ProgressBar",
}

function HealthBarParticles:_process(DT)
	if self:get_as_ratio() <= 0.25 then
		self:get_node("Particle"):get_node("DangerParticle"):set_emitting(true)
	else
		self:get_node("Particle"):get_node("DangerParticle"):set_emitting(false)
	end
end

return HealthBarParticles
