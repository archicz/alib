local PhysMeta = FindMetaTable("PhysObj")

// https://github.com/wiremod/wire/blob/master/lua/entities/gmod_wire_expression2/core/compat.lua#L44
function PhysMeta:ApplyAngForce(angForce)
	local ent = self:GetEntity()
    if not IsValid(ent) then return end

	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()

	if angForce.p ~= 0 then
		local pitch = up * (angForce.p * 0.5)
		self:ApplyForceOffset(forward, pitch)
		self:ApplyForceOffset(forward * -1, pitch * -1)
	end

	if angForce.y ~= 0 then
		local yaw = forward * (angForce.y * 0.5)
		self:ApplyForceOffset(left, yaw)
		self:ApplyForceOffset(left * -1, yaw * -1)
	end

	if angForce.r ~= 0 then
		local roll = left * (angForce.r * 0.5)
		self:ApplyForceOffset(up, roll)
		self:ApplyForceOffset(up * -1, roll * -1)
	end
end