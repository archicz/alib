universaltimeout = {}

function universaltimeout.Attach(object, name, delay)
    object.UniversalTimeouts = object.UniversalTimeouts or {}
    object.UniversalTimeouts[name] = CurTime() + delay
end

function universaltimeout.Check(object, name)
    if not object.UniversalTimeouts then return true end
    if not object.UniversalTimeouts[name] then return true end

    return CurTime() > object.UniversalTimeouts[name]
end