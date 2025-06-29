local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TOOL_NAME = "Punch"
local PUNCH_DELAY = 0.025

local firetouchinterest = rawget(_G, "firetouchinterest") or getgenv().firetouchinterest

local AutoPunch = {}
AutoPunch.__index = AutoPunch

function AutoPunch.new(tab)
    local self = setmetatable({}, AutoPunch)
    self.Running = false
    self.Toggle = tab:AddToggle("AutoPunchToggle", {
        Title = "Auto Punch",
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

function AutoPunch:Start()
    if self.Running then return end
    self.Running = true
    task.spawn(function()
        while self.Running do
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
            if backpack and character and muscleEvent then
                if not character:FindFirstChild(TOOL_NAME) then
                    local tool = backpack:FindFirstChild(TOOL_NAME)
                    if tool and character:FindFirstChild("Humanoid") then
                        character.Humanoid:EquipTool(tool)
                    end
                end

                muscleEvent:FireServer("punch", "rightHand")
                muscleEvent:FireServer("punch", "leftHand")

                if firetouchinterest then
                    local myRoot = character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        firetouchinterest(myRoot, myRoot, 0)
                        firetouchinterest(myRoot, myRoot, 1)
                    end
                end
            end
            task.wait(PUNCH_DELAY)
        end
        self.Running = false
    end)
end

function AutoPunch:Stop()
    self.Running = false
end

function AutoPunch:IsRunning()
    return self.Running
end

return AutoPunch