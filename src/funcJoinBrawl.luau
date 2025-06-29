local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JoinBrawlConfig = {
    CheckInterval = 0.25,
    JoinDelay = 1
}

local JoinBrawl = {}
JoinBrawl.__index = JoinBrawl

function JoinBrawl.new(tab)
    local self = setmetatable({}, JoinBrawl)
    self.tab = tab
    self.running = false
    self.thread = nil
    self:AddUI()
    return self
end

function JoinBrawl:AddUI()
    self.Toggle = self.tab:AddToggle("JoinBrawlToggle", {
        Title = "Join Brawl",
        Description = "Automatically joins Brawls.",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        self:ToggleJoin(state)
    end)
end

function JoinBrawl:ToggleJoin(state)
    if state then
        self.running = true
        self.thread = task.spawn(function()
            local brawlEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("brawlEvent")
            local brawlTimer = ReplicatedStorage:FindFirstChild("brawlTimer")
            local joinedBrawl = false
            while self.running do
                if brawlTimer and brawlTimer.Value == 0 and not joinedBrawl then
                    task.wait(JoinBrawlConfig.JoinDelay)
                    if brawlTimer.Value == 0 then
                        brawlEvent:FireServer("joinBrawl")
                        joinedBrawl = true
                    end
                elseif brawlTimer and brawlTimer.Value > 0 then
                    joinedBrawl = false
                end
                task.wait(JoinBrawlConfig.CheckInterval)
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
