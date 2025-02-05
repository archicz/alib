local function ClientsideScript(path)
    local absPath = "alib/" .. path

    if CLIENT then 
		include(absPath) 
	end
    
	if SERVER then 
		AddCSLuaFile(absPath)
	end
end

local function SharedScript(path)
    local absPath = "alib/" .. path

    if CLIENT then 
		include(absPath) 
	end
    
	if SERVER then 
		AddCSLuaFile(absPath)
		include(absPath)
	end
end

local function ServersideScript(path)
    local absPath = "alib/" .. path

    if SERVER then 
		include(absPath)
	end
end

SharedScript("sh_entlist.lua")
SharedScript("sh_vischeck.lua")
SharedScript("sh_analogmapper.lua")
SharedScript("sh_json.lua")
SharedScript("sh_precisenet.lua")
SharedScript("sh_ownerwrapper.lua")
SharedScript("sh_universaltimeout.lua")
SharedScript("sh_chatprint.lua")

ServersideScript("sv_discord.lua")
ServersideScript("sv_angforce.lua")

ClientsideScript("cl_stencilscissor.lua")
ClientsideScript("cl_cursorunlock.lua")
ClientsideScript("cl_dpiaware.lua")
ClientsideScript("cl_cursor3d2d.lua")
ClientsideScript("cl_imgui.lua")
ClientsideScript("cl_interactivescene.lua")