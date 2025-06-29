local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer


local CONFIG = {
    ButtonTitle = "Enable Anti Kick",
    ButtonDescription = "Patches multiple kick methods.",
    PrintPrefix = "[ANTI KICK]"
}

local HookKick = {}
HookKick.__index = HookKick

local function patchKick()
    -- METHOD 1: HOOK LOCALPLAYER.KICK
    local oldKick
    oldKick = hookfunction(LocalPlayer.Kick, function(self, ...)
        print(CONFIG.PrintPrefix, "Blocked Kick (method 1)")
        return
    end)

    -- METHOD 2: HOOK __NAMECALL
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod and getnamecallmethod() or ""
        if tostring(self) == "Players" and method == "Kick" then
            print(CONFIG.PrintPrefix, "Blocked Kick (method 2)")
            return
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)

    -- METHOD 3: HOOK __INDEX
    local oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = function(self, key)
        if key == "Kick" then
            print(CONFIG.PrintPrefix, "Blocked Kick (method 3)")
            return function() end
        end
        return oldIndex(self, key)
    end
    setreadonly(mt, true)
end

function HookKick.new(tab)
    local self = setmetatable({}, HookKick)
    self.Button = tab:AddButton({
        Title = CONFIG.ButtonTitle,
        Description = CONFIG.ButtonDescription,
        Callback = function()
            patchKick()
        end
    })
    return self
end

return HookKick