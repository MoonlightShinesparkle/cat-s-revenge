local RespawnMain = {
	extends = "Area2D",
}

function RespawnMain:_process()
	for index,value in pairs(self:get_overlapping_bodies()) do
		if value.type then
			if value.type == "Enemy" then
				if value:GetStarterPawsition() then
					value:set_position(value:GetStarterPawsition())
					if not tostring(value:get_node_or_null("TeleportParticles")) == "Null" then
						value:get_node("TeleportParticles"):set_emitting(true)
					end
				else
					value:Kill()
				end
			elseif value.type == "Player" then
				if not value.Teleporting then
					value:TeleportBack()
				end
			end
		end
	end
end

return RespawnMain
