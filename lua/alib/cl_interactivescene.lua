interactivescene = {}

INTERACTIVESCENE_CLASS_PROP = 0
INTERACTIVESCENE_CLASS_SPRITE = 1
INTERACTIVESCENE_CLASS_MAX = INTERACTIVESCENE_CLASS_SPRITE

local SceneObjectProp = {}
SceneObjectProp.__index = SceneObjectProp

function SceneObjectProp:New()
    self.Class = INTERACTIVESCENE_CLASS_PROP

    self.Model = ""
    self.Pos = Vector(0, 0, 0)
    self.Ang = Angle(0, 0, 0)
    self.Scale = Vector(1, 1, 1)
    self.LightOrigin = Vector(0, 0, 0)
    self.Entity = NULL

    // DEBUG
    self.PosOffset = Vector(0, 0, 0)
    self.AngOffset = Angle(0, 0, 0)
end

function SceneObjectProp:GetModel()
    return self.Model
end

function SceneObjectProp:SetModel(model)
    self.Model = model
    self:Generate()
end

function SceneObjectProp:GetEntity()
    return self.Entity
end

function SceneObjectProp:GetPos()
    return self.Pos
end

function SceneObjectProp:SetPos(pos)
    self.Pos = pos
end

function SceneObjectProp:GetAngles()
    return self.Ang
end

function SceneObjectProp:SetAngles(ang)
    self.Ang = ang
end

function SceneObjectProp:GetScale()
    return self.Scale
end

function SceneObjectProp:SetScale(scale)
    self.Scale = scale
end

function SceneObjectProp:GetLightOrigin()
    return self.LightOrigin
end

function SceneObjectProp:SetLightOrigin(pos)
    self.LightOrigin = pos
end

function SceneObjectProp:PreDraw(camera)
end

function SceneObjectProp:Draw(camera)
    local ent = self.Entity
    if not IsValid(ent) then return end

    render.SetLightingOrigin(self.LightOrigin)

    local modelMat = Matrix()
    modelMat:Translate(self.Pos + self.PosOffset)
    modelMat:Rotate(self.Ang + self.AngOffset)
    modelMat:Scale(self.Scale)

    ent:EnableMatrix("RenderMultiply", modelMat)
    ent:DrawModel()
end

function SceneObjectProp:PostDraw(camera)
end

function SceneObjectProp:Generate()
    if IsValid(self.Entity) then
        SafeRemoveEntity(self.Entity)
    end

    local ent = ClientsideModel(self.Model)
    if not IsValid(ent) then return end

    ent:SetNoDraw(true)
    ent:SetIK(false)

    self.Entity = ent
end



local SceneObjectSprite = {}
SceneObjectSprite.__index = SceneObjectSprite

function SceneObjectSprite:New()
    self.Class = INTERACTIVESCENE_CLASS_SPRITE

    self.Material = nil
    self.Additive = false
    self.Pos = Vector(0, 0, 0)
    self.Size = 16
    self.Color = Color(255, 255, 255)
end

function SceneObjectSprite:GetMaterial()
    return self.Material
end

function SceneObjectSprite:SetMaterial(path)
    self.Material = Material(path)
end

function SceneObjectSprite:GetAdditive()
    return self.Additive
end

function SceneObjectSprite:SetAdditive(additive)
    self.Additive = additive
end

function SceneObjectSprite:GetPos()
    return self.Pos
end

function SceneObjectSprite:SetPos(pos)
    self.Pos = pos
end

function SceneObjectSprite:GetColor()
    return self.Color
end

function SceneObjectSprite:SetColor(color)
    self.Color = color
end

function SceneObjectSprite:GetSize()
    return self.Size
end

function SceneObjectSprite:SetSize(size)
    self.Size = size
end

function SceneObjectSprite:PreDraw(camera)
end

function SceneObjectSprite:Draw(camera)
    if not self.Material or self.Material:IsError() then return end

    local pos = self.Pos
    local size = self.Size
    local color = self.Color
    local mat = self.Material

    local camPos = camera.Pos
    local camUp = camera.Ang:Up()
    local camRight = camera.Ang:Right()

    local halfSize = size / 2
    local topLeft = pos - camRight * halfSize + camUp * halfSize
    local topRight = pos + camRight * halfSize + camUp * halfSize
    local bottomLeft = pos - camRight * halfSize - camUp * halfSize
    local bottomRight = pos + camRight * halfSize - camUp * halfSize
    
    render.SetMaterial(mat)

    if self.Additive then
        render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD)
    end

    render.DrawQuad(topLeft, topRight, bottomRight, bottomLeft, color)

    if self.Additive then
        render.OverrideBlend(false)
    end
end

function SceneObjectSprite:PostDraw(camera)
end



local SceneObjectUI = {}
SceneObjectUI.__index = SceneObjectUI

function SceneObjectUI:New()
    self.Pos = Vector(0, 0, 0)
    self.Ang = Angle(0, 0, 0)
    self.Scale = 0.1
    self.Context = {}
end

function SceneObjectUI:GetPos()
    return self.Pos
end

function SceneObjectUI:SetPos(pos)
    self.Pos = pos 
end

function SceneObjectUI:GetAngles()
    return self.Ang
end

function SceneObjectUI:SetAngles(ang)
    self.Ang = ang
end

function SceneObjectUI:GetScale()
    return self.Scale
end

function SceneObjectUI:SetScale(scale)
    self.Scale = scale
end

function SceneObjectUI:DoGUI()
end

function SceneObjectUI:PreDraw(camera)
end

function SceneObjectUI:Draw(camera)
    local pos = self.Pos
    local ang = self.Ang
    local scale = self.Scale
    local ctx = self.Context

    local camPos = camera.Pos
    local camAng = camera.Ang + camera.ViewAngles // USES DEBUG CODE
    local camFOV = camera.FOV
    local camX = camera.ScreenX
    local camY = camera.ScreenY
    local camW = camera.ScreenW
    local camH = camera.ScreenH

    local panelW = 512
    local panelH = 512

    local cursorX, cursorY = input.GetCursorPos()
    local sceneDir = util.AimVector(camAng, camFOV, cursorX - camX, cursorY - camY, camW, camH)
    
    local planeIntersect = util.IntersectRayWithPlane(camPos, sceneDir, pos, ang:Up())
    local planeX = 0
    local planeY = 0

    if planeIntersect then
        local diff = (pos - planeIntersect)
        planeX = diff:Dot(-ang:Forward()) / scale
        planeY = diff:Dot(-ang:Right()) / scale

        planeX = math.floor(planeX)
        planeY = math.floor(planeY)
    end

    cam.Start3D2D(pos, ang, scale)
        imgui.Context3D2D(ctx, panelW, panelH)
        imgui.PushInputExternal(planeX, planeY, input.IsMouseDown(MOUSE_LEFT))
            self:DoGUI()
        imgui.ContextEnd()
    cam.End3D2D()
end

function SceneObjectUI:PostDraw(camera)
end



local SceneCamera = {}
SceneCamera.__index = SceneCamera

function SceneCamera:New(pos, ang, fov)
    self.Pos = pos or Vector(0, 0, 0)
    self.Ang = ang or Angle(0, 0, 0)
    self.FOV = fov or 90

    self.NearZ = 4
    self.FarZ = 16384

    self.Additive = false
    self.ColorMod = Color(255, 255, 255)
    self.AmbientLight = Color(75, 75, 75)

    self.ScreenX = 0
    self.ScreenY = 0
    self.ScreenW = 0
    self.ScreenH = 0

    // DEBUG
    self.ViewAngles = Angle(0, 0, 0)
end

function SceneCamera:GetPos()
    return self.Pos
end

function SceneCamera:SetPos(pos)
    self.Pos = pos
end

function SceneCamera:GetAngles()
    return self.Ang
end

function SceneCamera:SetAngles(ang)
    self.Ang = ang
end

function SceneCamera:GetFOV()
    return self.FOV
end

function SceneCamera:SetFOV(fov)
    self.FOV = fov
end

function SceneCamera:GetColorModulation()
    return self.ColorMod
end

function SceneCamera:SetColorModulation(color)
    self.ColorMod = color
end

function SceneCamera:GetAmbientLight()
    return self.AmbientLight
end

function SceneCamera:SetAmbientLight(color)
    self.AmbientLight = color
end

function SceneCamera:GetAdditive()
    return self.Additive
end

function SceneCamera:SetAdditive(additive)
    self.Additive = additive
end

function SceneCamera:LookAt(pos)
    local dir = (self.Pos - pos)
    dir:Normalize()

    self.Ang = dir:Angle()
end

function SceneCamera:WorldToScreen(worldPos)
    local camPos = self.Pos
    local camAng = self.Ang + self.ViewAngles // HAS DEBUG VARIABLE
    local camFOV = self.FOV

    local screenW = self.ScreenW or ScrW()
    local screenH = self.ScreenH or ScrH()

    local viewDir = worldPos - camPos
    local forward = camAng:Forward()
    local right = camAng:Right()
    local up = camAng:Up()

    local localX = viewDir:Dot(forward)
    local localY = viewDir:Dot(right)
    local localZ = viewDir:Dot(up)

    if localX <= 0 then
        return false, -1, -1
    end

    local fovRad = math.rad(camFOV / 2)
    local scale = screenW / (2 * math.tan(fovRad))

    local screenX = (localY / localX) * scale + (screenW / 2)
    local screenY = -(localZ / localX) * scale + (screenH / 2)

    return true, screenX, screenY
end

function SceneCamera:Begin(x, y, w, h)
    self.ScreenX = x
    self.ScreenY = y
    self.ScreenW = w
    self.ScreenH = h

    // DEBUG CODE
    local up = input.IsKeyDown(KEY_PAD_8) and -1 or 0
    local down = input.IsKeyDown(KEY_PAD_2) and 1 or 0

    local left = input.IsKeyDown(KEY_PAD_4) and 1 or 0
    local right = input.IsKeyDown(KEY_PAD_6) and -1 or 0

    self.ViewAngles.p = self.ViewAngles.p + (up + down)
    self.ViewAngles.y = self.ViewAngles.y + (left + right)
    // DEBUG CODE

    cam.Start3D(self.Pos, self.Ang + self.ViewAngles, self.FOV, self.ScreenX, self.ScreenY, self.ScreenW, self.ScreenH, self.NearZ, self.FarZ)

    render.Clear(0, 0, 0, 0, true, true)

    render.SuppressEngineLighting(true)
    render.ResetModelLighting(self.AmbientLight.r / 255, self.AmbientLight.g / 255, self.AmbientLight.b / 255)
    render.SetColorModulation(self.ColorMod.r / 255, self.ColorMod.g / 255, self.ColorMod.b / 255)
    render.SetBlend(1)
end

function SceneCamera:End()
    render.SuppressEngineLighting(false)
    cam.End3D()
end



local SceneSkybox = {}
SceneSkybox.__index = SceneSkybox

function SceneSkybox:New(path)
    self.Path = ""
end

function SceneSkybox:SetPath(path)
    self.Path = path
    self:Generate()
end

function SceneSkybox:Generate()
    self.MaterialFaces =
    {
        up = Material(self.Path .. "up"),
        down = Material(self.Path .. "dn"),
        left = Material(self.Path .. "lf"),
        right = Material(self.Path .. "rt"),
        front = Material(self.Path .. "ft"),
        back = Material(self.Path .. "bk")
    }
end

function SceneSkybox:Draw(camera)
    if not self.MaterialFaces then return end

    local pos = Vector(0, 0, 0)
    local size = camera.FarZ

    render.SetMaterial(self.MaterialFaces.up)
    render.DrawQuadEasy(pos + Vector(0, 0, size / 2), Vector(0, 0, -1), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.down)
    render.DrawQuadEasy(pos + Vector(0, 0, -size / 2), Vector(0, 0, 1), size, size, 0, 0)

    render.SetMaterial(self.MaterialFaces.right)
    render.DrawQuadEasy(pos + Vector(-size / 2, 0, 0), Vector(1, 0, 0), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.left)
    render.DrawQuadEasy(pos + Vector(size / 2, 0, 0), Vector(-1, 0, 0), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.front)
    render.DrawQuadEasy(pos + Vector(0, size / 2, 0), Vector(0, -1, 0), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.back)
    render.DrawQuadEasy(pos + Vector(0, -size / 2, 0), Vector(0, 1, 0), size, size, 0, 180)
end



local ScenePointLight = {}
ScenePointLight.__index = ScenePointLight

function ScenePointLight:New()
    self.type = MATERIAL_LIGHT_POINT
    self.color = Vector(0, 0, 0)
    self.pos = Vector(0, 0, 0)
    self.range = 0
    self.fiftyPercentDistance = 100
    self.zeroPercentDistance = 200
end

function ScenePointLight:SetPos(pos)
    self.pos = pos
end

function ScenePointLight:SetColor(color, intensity)
    self.color.x = color.r * intensity
    self.color.y = color.g * intensity
    self.color.z = color.b * intensity
end

function ScenePointLight:SetMinDistance(minDist)
    self.fiftyPercentDistance = minDist
end

function ScenePointLight:SetMaxDistance(maxDist)
    self.zeroPercentDistance = maxDist
end



local Scene = {}
Scene.__index = Scene

function Scene:New()
    self.Objects = {}
    self.Lights = {}
    self.Camera = nil
    self.Skybox = nil
end

function Scene:GetCamera()
    return self.Camera
end

function Scene:GetObjects()
    return self.Objects
end

function Scene:CreateCamera(pos, ang, fov)
    local camera = {}
    setmetatable(camera, SceneCamera)
    camera:New(pos, ang, fov)

    self.Camera = camera
    return camera
end

function Scene:SetSkybox(path)
    if not self.Skybox then
        local skybox = {}
        setmetatable(skybox, SceneSkybox)
        skybox:New()

        self.Skybox = skybox
    end

    self.Skybox:SetPath(path)
end

function Scene:AddObject(obj)
    table.insert(self.Objects, obj)
end

function Scene:AddLight(light)
    table.insert(self.Lights, light)
end

function Scene:PreDrawObjects()
end

function Scene:PostDrawObjects()
end

function Scene:PreDrawSkybox()
end

function Scene:PostDrawSkybox()
end

function Scene:Draw()
    local camera = self.Camera
    if not camera then return end

    if self.Skybox then
        self:PreDrawSkybox()
            self.Skybox:Draw(camera)
        self:PostDrawSkybox()
    end

    local hasLights = #self.Lights > 0

    self:PreDrawObjects()
        if hasLights then
            render.SetLocalModelLights(self.Lights)
        end

        for i = 1, #self.Objects do
            local obj = self.Objects[i]

            obj:PreDraw(camera)
            obj:Draw(camera)
            obj:PostDraw(camera)
        end

        if hasLights then
            render.SetLocalModelLights()
        end
    self:PostDrawObjects()
end

function Scene:DrawDirect(x, y, w, h)
    local camera = self.Camera
    if not camera then return end

    camera:Begin(x, y, w, h)
        self:Draw()
    camera:End()
end

function interactivescene.CreatePointLight()
    local instance = {}
    setmetatable(instance, ScenePointLight)
    instance:New()

    return instance
end

function interactivescene.CreateProp()
    local instance = {}
    setmetatable(instance, SceneObjectProp)
    instance:New()

    return instance
end

function interactivescene.CreateSprite()
    local instance = {}
    setmetatable(instance, SceneObjectSprite)
    instance:New()

    return instance
end

function interactivescene.CreateUI()
    local instance = {}
    setmetatable(instance, SceneObjectUI)
    instance:New()

    return instance
end

function interactivescene.CreateScene()
    local instance = {}
    setmetatable(instance, Scene)
    instance:New()

    return instance
end

function interactivescene.DrawRT(scene, rt)
    local x = 0
    local y = 0
    local w = rt:Width()
    local h = rt:Height()

    render.PushRenderTarget(rt)
    render.PushFilterMag(TEXFILTER.POINT)
    render.OverrideAlphaWriteEnable(true, true)
        render.ClearDepth()
        render.Clear(0, 0, 0, 0)

        render.SetWriteDepthToDestAlpha(false)
        scene:DrawDirect(x, y, w, h)
        render.SetWriteDepthToDestAlpha(true)
    render.OverrideAlphaWriteEnable(false)
    render.PopFilterMag()
    render.PopRenderTarget()
end

if not imgui then return end
function imgui.SceneViewer(scene, w, h)
    local parentW, parentH = imgui.GetLayout()
    local x, y = imgui.GetCursor()

    if w == IMGUI_SIZE_CONTENT then
        w = parentW
    end

    if h == IMGUI_SIZE_CONTENT then
        h = parentH
    end

    local isHovering = imgui.MouseInRect(x, y, w, h)
    local hasClicked = imgui.HasClicked()

    imgui.Draw(function()
        scene:DrawDirect(x, y, w, h)
    end)

    imgui.ContentAdd(w, h)
end