local PercentMapper = {}
PercentMapper.__index = PercentMapper

function PercentMapper:New(strength)
    self.Strength = strength or 0.1
    self.NextProgress = 0
    self.InputValue = 0
    self.OutputValue = 0
end

function PercentMapper:Input(inValue)
    if inValue ~= nil then
        self.InputValue = math.Clamp(inValue, -1, 1)
    end
end

function PercentMapper:Output()
    local delta = self.InputValue - self.OutputValue
    local deltaDir = (delta > 0) and 1 or -1
    local strength = FrameTime() * self.Strength
    local remaining = math.abs(delta) < strength
    
    local outputValue = remaining and self.InputValue or (self.OutputValue + (strength * deltaDir))
    local clamped = math.Clamp(outputValue, -1, 1)
    local rounded = math.Round(clamped, 2)

    self.OutputValue = clamped
    return rounded
end

function AnalogMapper(...)
    local instance = {}
    setmetatable(instance, PercentMapper)

    instance:New(...)

    return instance
end