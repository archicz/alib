cursor3d2d = {}

function cursor3d2d.PlaneIntersect(pos, ang, scale)
    local eyePos = LocalPlayer():EyePos()
    local eyeNormal = gui.ScreenToVector(ScrW() / 2, ScrH() / 2)
    local planeNormal = ang:Up()

    local planeIntersect = util.IntersectRayWithPlane(eyePos, eyeNormal, pos, planeNormal)
    local planeX = 0
    local planeY = 0

    if planeIntersect then
        local diff = (pos - planeIntersect)
        planeX = diff:Dot(-ang:Forward()) / scale
        planeY = diff:Dot(-ang:Right()) / scale

        planeX = math.floor(planeX)
        planeY = math.floor(planeY)
    end

    return planeX, planeY
end

function cursor3d2d.GetInteractingSpecial()
    local usingVGUI = vgui.CursorVisible()
    local interactBind = input.LookupBinding("+use")
    local interactKey = input.GetKeyCode(interactBind)

    local speedBing = input.LookupBinding("+speed")
    local speedKey = input.GetKeyCode(speedBing)

    return not usingVGUI and input.IsKeyDown(interactKey) and input.IsKeyDown(speedKey)
end

function cursor3d2d.GetInteracting()
    local usingVGUI = vgui.CursorVisible()

    local interactBind = input.LookupBinding("+use")
    local interactKey = input.GetKeyCode(interactBind)

    local speedBing = input.LookupBinding("+speed")
    local speedKey = input.GetKeyCode(speedBing)

    return not usingVGUI and input.IsKeyDown(interactKey) and not input.IsKeyDown(speedKey)
end

function cursor3d2d.CursorTrace(origin, ang, mins, maxs, maxDist)
    local startPos = LocalPlayer():EyePos()
    local dir = gui.ScreenToVector(ScrW() / 2, ScrH() / 2)

    local traceConfig =
    {
        start = startPos,
        endpos = startPos + dir * maxDist,
        filter = LocalPlayer()
    }

    local trace = util.TraceLine(traceConfig)
    if not trace.Hit then return false end

    local boxPos = util.IntersectRayWithOBB(trace.HitPos, dir, origin, ang, mins, maxs)
    if not boxPos then return false end

    return true
end