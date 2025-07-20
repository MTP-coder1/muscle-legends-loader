local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local AutoRep = {}
AutoRep.__index = AutoRep

local REP_DELAY = 0.0001

function AutoRep.new(tab)
    local self = setmetatable({}, AutoRep)
    self.Running = false

    self.Toggle = tab:AddToggle("AutoRepToggle", {
        Title = "Auto Rep",
        Default = false,
        Callback = function(state)
            if state then
                self:Start()
            else
                self:Stop()
            end
        end
    })

    return self
end

function AutoRep:Start()
    if self.Running then return end
    self.Running = true
    task.spawn(function()
        while self.Running do
            local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
            if muscleEvent then
                muscleEvent:FireServer("rep")
            end
            task.wait(REP_DELAY)
        end
        self.Running = false
    end)
end

function AutoRep:Stop()
    self.Running = false
end

function AutoRep:IsRunning()
    return self.Running
end

return AutoRep
