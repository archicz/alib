local EntMeta = FindMetaTable("Entity")

function EntMeta:GetRealOwner()
    local owner = self:GetOwner()
    local isWeapon = self:IsWeapon()
    
    if CPPI and not isWeapon then
        owner = self:CPPIGetOwner()
    end

    return owner
end

if CLIENT then return end

function EntMeta:SetRealOwner(owner)
    local isWeapon = self:IsWeapon()
    
    if CPPI and not isWeapon then
        self:CPPISetOwner(owner)
    else
        self:SetOwner(owner)
    end
end