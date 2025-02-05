if not net then return end

function net.WritePreciseVector(vec)
    net.WriteFloat(vec.x)
    net.WriteFloat(vec.y)
    net.WriteFloat(vec.z)
end

function net.ReadPreciseVector()
    local x = net.ReadFloat()
    local y = net.ReadFloat()
    local z = net.ReadFloat()

    return Vector(x, y, z)
end