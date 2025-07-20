local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TOOL_NAME = "Punch"
local PUNCH_DELAY = 0.000001

local firetouchinterest = rawget(_G, "firetouchinterest") or getgenv().firetouchinterest

local AutoKillerEveryone = {}
AutoKillerEveryone.__index = AutoKillerEveryone

function AutoKillerEveryone.new(tab)
    local self = setmetatable({}, AutoKillerEveryone)
    self.Running = false
    self.Toggle = tab:AddToggle("AutoKillerEveryoneToggle", {
        Title = "Auto Kill Everyone",
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

function AutoKillerEveryone:Start()
    if self.Running then
        return
    end
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
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            local targetRoot = plr.Character.HumanoidRootPart
                            firetouchinterest(myRoot, targetRoot, 0)
                            firetouchinterest(myRoot, targetRoot, 1)
                        end
                    end
                end
            end
            task.wait(PUNCH_DELAY)
        end
        self.Running = false
    end)
end

function AutoKillerEveryone:Stop()
    self.Running = false
end

function AutoKillerEveryone:IsRunning()
    return self.Running
end

return AutoKillerEveryone
