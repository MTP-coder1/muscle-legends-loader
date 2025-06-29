local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = {
    PunchInterval = 0.025
}

local NoPunchAnimation = {}
NoPunchAnimation.__index = NoPunchAnimation

function NoPunchAnimation.new(tab)
    local self = setmetatable({}, NoPunchAnimation)
    self.tab = tab
    self.running = false
    self.thread = nil

    self.Toggle = self.tab:AddToggle("NoPunchAnimationToggle", {
        Title = "No Animation",
        Description = "Disables the punch animation.",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        self:ToggleNoAnim(state)
    end)
    return self
end

function NoPunchAnimation:ToggleNoAnim(state)
    if state then
        self.running = true
        self.thread = task.spawn(function()
            local player = LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local backpack = player:WaitForChild("Backpack")
            local punchTool = character:FindFirstChild("Punch") or backpack:FindFirstChild("Punch")
            local punchScript = punchTool and punchTool:FindFirstChild("punchScript")
            if punchScript then
                punchScript.Enabled = false
            end
            while self.running do
                if character:FindFirstChild("Punch") then
                    player.muscleEvent:FireServer("punch", "rightHand")
                    player.muscleEvent:FireServer("punch", "leftHand")
                end
                task.wait(Config.PunchInterval)
            end
            if punchScript then
                punchScript.Enabled = true
            end
        end)
    else
        self.running = false
        if self.thread then
            task.cancel(self.thread)
            self.thread = nil
        end
        local player = LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local backpack = player:WaitForChild("Backpack")
        local punchTool = character:FindFirstChild("Punch") or backpack:FindFirstChild("Punch")
        local punchScript = punchTool and punchTool:FindFirstChild("punchScript")
        if punchScript then
            punchScript.Enabled = true
        end
    end
end

return NoPunchAnimation
