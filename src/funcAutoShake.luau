local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Name = "Tropical Shake",
    BoostFolder = "boostTimersFolder",
    EventName = "muscleEvent",
    Delay = 1800
}

local AutoShake = {}
AutoShake.__index = AutoShake

function AutoShake.new(tab)
    local self = setmetatable({}, AutoShake)
    self.Running = false
    self.Toggle = tab:AddToggle("AutoShakeToggle", {
        Title = "Auto Tropical Shake",
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

function AutoShake:Start()
    if self.Running then return end
    self.Running = true
    task.spawn(function()
        while self.Running do
            local timers = LocalPlayer:FindFirstChild(CONFIG.BoostFolder)
            local shakeTimer = timers and timers:FindFirstChild(CONFIG.Name)
            if shakeTimer and shakeTimer.Value > 0 then
                repeat task.wait(1) until not self.Running or shakeTimer.Value == 0
            end
            if not self.Running then break end
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            if backpack and character and not character:FindFirstChild(CONFIG.Name) then
                local tool = backpack:FindFirstChild(CONFIG.Name)
                if tool and character:FindFirstChild("Humanoid") then
                    character.Humanoid:EquipTool(tool)
                end
            end
            local muscleEvent = LocalPlayer:FindFirstChild(CONFIG.EventName)
            local shakeObj = character and character:FindFirstChild(CONFIG.Name)
            if muscleEvent and shakeObj then
                muscleEvent:FireServer("tropicalShake", shakeObj)
                task.wait(CONFIG.Delay)
            else
                task.wait(1)
            end
        end
        self.Running = false
    end)
end

function AutoShake:Stop()
    self.Running = false
end

function AutoShake:IsRunning()
    return self.Running
end

return AutoShake