local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LOCK_CONFIG = {
    ToggleTitle = "Lock Client Position",
    ToggleDescription = "Locks your character's position in place until disabled."
}

local LockClientPosition = {}
LockClientPosition.__index = LockClientPosition

function LockClientPosition.new(tab)
    local self = setmetatable({}, LockClientPosition)
    self.LockConnection = nil
    self.LockedCFrame = nil
    self.Toggle = tab:AddToggle("LockClientPositionToggle", {
        Title = LOCK_CONFIG.ToggleTitle,
        Description = LOCK_CONFIG.ToggleDescription,
        Default = false,
        Callback = function(state)
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            if state then
                self.LockedCFrame = hrp.CFrame
                if self.LockConnection then
                    self.LockConnection:Disconnect()
                end
                self.LockConnection = RunService.Heartbeat:Connect(function()
                    local c = lp.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        c.HumanoidRootPart.CFrame = self.LockedCFrame
                    end
                end)
            else
                if self.LockConnection then
                    self.LockConnection:Disconnect()
                    self.LockConnection = nil
                end
            end
        end
    })

    return self
end

return LockClientPosition