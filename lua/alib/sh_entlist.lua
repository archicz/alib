local EntList = {}
EntList.__index = EntList

function EntList:New(...)
    local args = {...}

    for i = 1, #args do
        local arg = args[i]

        if istable(arg) then
            self:AddEntities(arg)
        elseif isentity(arg) then
            self:AddEntity(arg)
        end
    end
end

function EntList:HasEntity(ent)
    if not isentity(ent) then return false end
    if not IsValid(ent) then return false end

    for i = 1, #self do
        local curEnt = self[i]
        if curEnt == ent then return i end
    end

    return false
end

function EntList:AddEntity(ent)
    if self:HasEntity(ent) then return end
    
    table.insert(self, ent)
end

function EntList:AddEntities(entTbl)
    for i = 1, #entTbl do
        local ent = entTbl[i]
        self:AddEntity(ent)
    end
end

function EntList:RemoveEntity(ent)
    local foundIndex = self:HasEntity(ent)
    if not foundIndex then return end

    table.remove(self, foundIndex)
end

function EntList:RemoveEntities(entTbl)
    for i = 1, #entTbl do
        local ent = entTbl[i]
        self:RemoveEntity(ent)
    end
end

function EntList:AllEntities()
    self:AddEntities(ents.GetAll())
end

function EntList:AllPlayers()
    self:AddEntities(player.GetAll())
end

function EntList:AllClass(...)
    self:AddEntities(ents.FindByClass(...))
end

function EntList:AllSphere(...)
    self:AddEntities(ents.FindInSphere(...))
end

function EntList:AllBox(...)
    self:AddEntities(ents.FindInBox(...))
end

function EntList:Filter(check)
    local toRemove = {}

    for i = 1, #self do
        local curEnt = self[i]

        if check(curEnt) then
            table.insert(toRemove, curEnt)
        end
    end

    self:RemoveEntities(toRemove)
end

function EntList:ExcludeClass(class)
    self:Filter(function(ent) return (ent:GetClass() == class) end)
end

function EntList:IncludeClass(class)
    self:Filter(function(ent) return (ent:GetClass() != class) end)
end

function EntList:IncludeDistance(origin, dist)
    local distSqr = dist * dist
    self:Filter(function(ent) return (ent:GetPos():DistToSqr(origin) > distSqr) end)
end

function EntList:ExcludeDistance(origin, dist)
    local distSqr = dist * dist
    self:Filter(function(ent) return (ent:GetPos():DistToSqr(origin) < distSqr) end)
end

function EntList:Sort(cmp)
    table.sort(self, cmp)
end

function EntList:SortByDistance(origin)
    self:Sort(function(a, b) return (a:GetPos():DistToSqr(origin) < b:GetPos():DistToSqr(origin)) end)
end

function EntityList(...)
    local instance = {}
    setmetatable(instance, EntList)

    instance:New(...)

    return instance
end

if not net then return end

function net.WriteEntityList(entList)
    net.WriteUInt(#entList, 32)

    for i, ent in pairs(entList) do
        if not ent then continue end
        if not IsValid(ent) then continue end

        net.WriteUInt(ent:EntIndex(), 32)
    end
end

function net.ReadEntityList()
    local num = net.ReadUInt(32)
    local entList = EntityList()

    for i = 1, num do
        local entIndex = net.ReadUInt(32)
        local ent = Entity(entIndex)

        if not ent then continue end
        if not IsValid(ent) then continue end

        entList:AddEntity(ent)
    end

    return entList
end