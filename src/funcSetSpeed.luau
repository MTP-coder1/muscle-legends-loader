local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = {
    DefaultSpeed = 14, -- [ Default: 14 ] -- Default speed value to set
    ChangeInterval = 0.5 -- [ Default: 0.5 ] -- Interval to change speed (in seconds)
}

local SetSpeed = {}
SetSpeed.__index = SetSpeed

function SetSpeed.new(tab)
    local self = setmetatable({}, SetSpeed)
    self.tab = tab
    self.running = false
    self.thread = nil
    self.targetSpeed = Config.DefaultSpeed

    local section = self.tab:AddSection("Set Speed")

    self.Input = section:AddInput("SetSpeedInput", {
        Title = "Set Speed",
        Default = tostring(Config.DefaultSpeed),
        Placeholder = "Enter speed value",
        Numeric = true,
        Finished = true,
        Callback = function(value)
            local num = tonumber(value)
            if num then
                self.targetSpeed = num
            end
        end
    })

    self.Toggle = section:AddToggle("SetSpeedToggle", {
        Title = "Auto Speed Set",
        Description = "Sets Speed value automatically",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        self:ToggleSetSpeed(state)
    end)

    return self
end

function SetSpeed:ToggleSetSpeed(state)
    if state then
        self.running = true
        self.thread = game:GetService("RunService").Heartbeat:Connect(function()
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = self.targetSpeed
            end
        end)
    else
        self.running = false
        if self.thread then
            self.thread:Disconnect()
            self.thread = nil
        end
    end
end

function SetSpeed:Destroy()
    self:ToggleSetSpeed(false)
    setmetatable(self, nil)
end

return SetSpeed
