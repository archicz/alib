if not surface then return end

local BaseWidth = 1920
local BaseHeight = 1080

local WidthDPI = ScrW() / BaseWidth
local HeightDPI = ScrH() / BaseHeight
local BothDPI = math.min(WidthDPI, HeightDPI)

function surface.CreateFontDPI(name, fontData)
    fontData["size"] = fontData["size"] * BothDPI

    surface.CreateFont(name, fontData)
end

function surface.ScaleWidthDPI(w)
    return w * WidthDPI
end

function surface.ScaleHeightDPI(h)
    return h * HeightDPI
end

function surface.ScaleDPI(n)
    return n * BothDPI
end