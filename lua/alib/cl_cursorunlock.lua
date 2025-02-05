if not input then return end

local UnlockRequested = false
local UnlockPanel = false
local MouseWheel = 0

local function ResetState()
    UnlockRequested = false
end

local function CheckState()
    if not UnlockRequested and ispanel(UnlockPanel) then
        UnlockPanel:Remove()
        UnlockPanel = false
    end

    MouseWheel = 0
end

function input.UnlockCursor()
    UnlockRequested = true
    if ispanel(UnlockPanel) then return end

    UnlockPanel = vgui.Create("DFrame")
    UnlockPanel:SetSize(ScrW(), ScrH())
    UnlockPanel:SetPos(0, 0)
    UnlockPanel:SetPaintedManually(true)
    UnlockPanel:SetDraggable(false)
    UnlockPanel:SetSizable(false)
    UnlockPanel:MakePopup()

    function UnlockPanel:OnMouseWheeled(delta)
        MouseWheel = delta
    end
end

function input.SetCursorType(cursorType)
    if UnlockRequested and ispanel(UnlockPanel) then
        UnlockPanel:SetCursor(cursorType) 
    end
end

function input.GetMouseWheel()
    return MouseWheel
end

hook.Add("PreRender", "CursorUnlockReset", ResetState)
hook.Add("PostRender", "CursorUnlockCheck", CheckState)