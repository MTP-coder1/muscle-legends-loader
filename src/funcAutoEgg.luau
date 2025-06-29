local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    Name = "Protein Egg",
    BoostFolder = "boostTimersFolder",
    EventName = "muscleEvent",
    Delay = 1800
}

local AutoEgg = {}
AutoEgg.__index = AutoEgg

function AutoEgg.new(tab)
    local self = setmetatable({}, AutoEgg)
    self.Running = false
    self.Toggle = tab:AddToggle("AutoEggToggle", {
        Title = "Auto Protein Egg",
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

function AutoEgg:Start()
    if self.Running then
        return
    end
    self.Running = true
    task.spawn(function()
        while self.Running do
            local timers = LocalPlayer:FindFirstChild(CONFIG.BoostFolder)
            local proteinEgg = timers and timers:FindFirstChild(CONFIG.Name)
            if proteinEgg and proteinEgg.Value > 0 then
                repeat
                    task.wait(1)
                until not self.Running or proteinEgg.Value == 0
            end
            if not self.Running then
                break
            end
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            if backpack and character and not character:FindFirstChild(CONFIG.Name) then
                local tool = backpack:FindFirstChild(CONFIG.Name)
                if tool and character:FindFirstChild("Humanoid") then
                    character.Humanoid:EquipTool(tool)
                end
            end
            local equipped = character and character:FindFirstChild(CONFIG.Name)
            if equipped then
                LocalPlayer[CONFIG.EventName]:FireServer("proteinEgg", equipped)
                task.wait(CONFIG.Delay)
            else
                task.wait(1)
            end
        end
        self.Running = false
    end)
end

function AutoEgg:Stop()
    self.Running = false
end

function AutoEgg:IsRunning()
    return self.Running
end

return AutoEgg
