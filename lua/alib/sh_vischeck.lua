vischeck = {}

function vischeck.IsInFOV(startPos, lookDir, fov, endPos)
    local fovCos = math.cos(math.rad(fov))
    local posDir = (endPos - startPos)
    local angCos = lookDir:Dot(posDir) / posDir:Length()

    return (angCos >= fovCos)
end

function vischeck.GetClosestEntityInFOV(startPos, lookDir, fov, entList)
    local closestEntity = nil
    local minAng = nil
    local fovCos = math.cos(math.rad(fov))

    for i = 1, #entList do
        local ent = entList[i]
        local posDir = (ent:GetPos() - self:GetPos())
        local angCos = lookDir:Dot(posDir) / posDir:Length()

        if angCos >= fovCos then
            if not minAng or angCos > minAng then
                minAng = angCos
                closestEntity = ent
            end
        end
    end

    return closestEntity
end

function vischeck.IsVisible(startPos, endPos)
    local traceConfig =
    {
        start = startPos,
        endpos = endPos,
        mask = MASK_SOLID_BRUSHONLY
    }

    local tr = util.TraceLine(traceConfig)
    return tr.HitNonWorld
end