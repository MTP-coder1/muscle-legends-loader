local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = {
    DefaultSize = 1, -- [ Default: 1 ] -- Default size value to set
    ChangeInterval = 0.5 -- [ Default: 0.5 ] -- Interval to change size (in seconds)
}

local SetSize = {}
SetSize.__index = SetSize

function SetSize.new(tab)
    local self = setmetatable({}, SetSize)
    self.tab = tab
    self.running = false
    self.thread = nil
    self.targetSize = Config.DefaultSize

    local section = self.tab:AddSection("Set Size")

    self.Input = section:AddInput("SetSizeInput", {
        Title = "Set Size",
        Default = tostring(Config.DefaultSize),
        Placeholder = "Enter size value",
        Numeric = true,
        Finished = true,
        Callback = function(value)
            local num = tonumber(value)
            if num then
                self.targetSize = num
            end
        end
    })

    self.Toggle = section:AddToggle("SetSizeToggle", {
        Title = "Auto Size",
        Description = "Sets the Size value automatically",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        self:ToggleSetSize(state)
    end)

    return self
end

function SetSize:ToggleSetSize(state)
    if state then
        self.running = true
        self.thread = task.spawn(function()
            while self.running do
                local size = self.targetSize or Config.DefaultSize
                ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", size)
                ReplicatedStorage.rEvents.savePlayerSizeEvent:FireServer("savePlayerSizeOption")
                task.wait(Config.ChangeInterval)
            end
        end)
    else
        self.running = false
        if self.thread then
            task.cancel(self.thread)
            self.thread = nil
        end
    end
end

return SetSize
