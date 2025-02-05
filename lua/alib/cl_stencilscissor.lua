if not render then return end

function render.SetStencilScissorRect(x1, y1, x2, y2, enable)
    if enable then
        render.ClearStencil()
        render.SetStencilEnable(true)
        
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)
        render.SetStencilFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

        render.OverrideColorWriteEnable(true, false)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawRect(x1, y1, x2 - x1, y2 - y1)
        render.OverrideColorWriteEnable(false)

        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    else
        render.SetStencilEnable(false)
    end
end