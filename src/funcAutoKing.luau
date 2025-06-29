local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TELEPORT_DELAY = 0.1
local KING_OFFSET = Vector3.new(0, 14, 0)

local AutoKing = {}
AutoKing.__index = AutoKing

function AutoKing.new()
    local self = setmetatable({}, AutoKing)
    self.Running = false
    return self
end

function AutoKing:Start()
    if self.Running then return end
    self.Running = true
    task.spawn(function()
        while self.Running do
            local kingParts = workspace:FindFirstChild("muscleKingParts")
            local kingPart = kingParts and kingParts:FindFirstChild("muscleKingPart")
            local character = LocalPlayer.Character
            if kingPart and character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = kingPart.CFrame + KING_OFFSET
            end
            task.wait(TELEPORT_DELAY)
        end
        self.Running = false
    end)
end

function AutoKing:Stop()
    self.Running = false
end

function AutoKing:Toggle()
    if self.Running then
        self:Stop()
    else
        self:Start()
    end
end

function AutoKing:IsRunning()
    return self.Running
end

return AutoKing