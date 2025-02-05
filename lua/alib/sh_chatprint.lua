local NetworkString = "alib.ChatPrint"

if SERVER then
    util.AddNetworkString(NetworkString)
    if not chat then chat = {} end

    function chat.AddText(ply, ...)
        net.Start(NetworkString)
        net.WriteTable({...})
        
        if not ply then
            net.Broadcast()
        else
            net.Send(ply)
        end
    end
end

if CLIENT then
    local function Chatprint()
        local tbl = net.ReadTable()
        chat.AddText(unpack(tbl))
    end

    net.Receive(NetworkString, Chatprint)
end