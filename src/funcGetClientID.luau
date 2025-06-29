local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GET_CLIENT_ID_CONFIG = {
    ClipboardFunc = setclipboard or toclipboard
}

local GetClientID = {}
GetClientID.__index = GetClientID

function GetClientID.new(tab)
    local self = setmetatable({}, GetClientID)
    self.Button = tab:AddButton({
        Title = "Copy Client HWID",
        Description = "Copies your Roblox Client ID (HWID) to clipboard.",
        Callback = function()
            local clientId = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
            if GET_CLIENT_ID_CONFIG.ClipboardFunc then
                GET_CLIENT_ID_CONFIG.ClipboardFunc(clientId)
                print("Copied Client ID:", clientId)
            else
                print("Clipboard function not available. Client ID:", clientId)
            end
        end
    })

    return self
end

return GetClientID