local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    BrawlCheckInterval = 0.1,
    BrawlJoinDelay = 1,
    TinyIslandCheckInterval = 1,
    TinyIslandYOffset = 3
}

local GodMode = {}
GodMode.__index = GodMode

function GodMode.new(tab)
    local self = setmetatable({}, GodMode)
    self.tab = tab
    self.connections = {}
    self.running = {
        Brawl = false,
        TinyIsland = false
    }
    self.threads = {}
    self._originalCFrame = nil
    self:AddUI()
    return self
end

function GodMode:AddUI()
    self.BrawlToggle = self.tab:AddToggle("GodModeBrawlToggle", {
        Title = "GodMode (Brawl Method)",
        Description = "Enables GodMode using Brawl join/leave logic.",
        Default = false
    })
    self.BrawlToggle:OnChanged(function(state)
        self:ToggleBrawl(state)
    end)

    self.TinyIslandToggle = self.tab:AddToggle("GodModeTinyIslandToggle", {
        Title = "GodMode (Tiny Island Gym)",
        Description = "Enables GodMode using Tiny Island Gym teleport/spoof.",
        Default = false
    })
    self.TinyIslandToggle:OnChanged(function(state)
        self:ToggleTinyIsland(state)
    end)
end

function GodMode:ToggleBrawl(state)
    if state then
        self.running.Brawl = true
        self.threads.Brawl = task.spawn(function()
            local brawlEvent = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("brawlEvent")
            local brawlTimer = ReplicatedStorage:FindFirstChild("brawlTimer")
            local joinedBrawl = false
            while self.running.Brawl do
                if brawlTimer and brawlTimer.Value == 0 and not joinedBrawl then
                    task.wait(Config.BrawlJoinDelay)
                    if brawlTimer.Value == 0 then
                        brawlEvent:FireServer("joinBrawl")
                        joinedBrawl = true
                    end
                elseif brawlTimer and brawlTimer.Value > 0 then
                    joinedBrawl = false
                end
                task.wait(Config.BrawlCheckInterval)
            end
        end)
    else
        self.running.Brawl = false
        if self.threads.Brawl then
            task.cancel(self.threads.Brawl)
            self.threads.Brawl = nil
        end
    end
end

function GodMode:ToggleTinyIsland(state)
    if state then
        self.running.TinyIsland = true
        self._originalCFrame = nil
        self.threads.TinyIsland = task.spawn(function()
            local hasTeleported = false
            local function getRemote()
                return ReplicatedStorage:FindFirstChild("rEvents") and
                           ReplicatedStorage.rEvents:FindFirstChild("areaTravelRemote")
            end
            local function getAreaCircle()
                return Workspace:FindFirstChild("areaCircles") and Workspace.areaCircles:FindFirstChild("areaCircle")
            end
            local function destroyBarrier()
                local barrier = Workspace:FindFirstChild("legendsBeachBarrierPart")
                if barrier then
                    barrier:Destroy()
                end
            end
            local function teleportToBeach()
                local beachPart = Workspace:FindFirstChild("legendsBeachGradientPart")
                if beachPart then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if not self._originalCFrame then
                            self._originalCFrame = hrp.CFrame
                        end
                        hrp.CFrame = beachPart.CFrame + Vector3.new(0, Config.TinyIslandYOffset, 0)
                    end
                    beachPart:Destroy()
                end
            end
            local function spoofPosition()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local areaCircle = getAreaCircle()
                    if areaCircle then
                        hrp.CFrame = areaCircle.CFrame
                    end
                end
            end

            destroyBarrier()
            teleportToBeach()
            hasTeleported = true

            while self.running.TinyIsland do
                local remote = getRemote()
                if remote and not hasTeleported then
                    remote:FireServer("legendsBeach")
                    task.wait()
                    spoofPosition()
                end
                task.wait(Config.TinyIslandCheckInterval)
            end
        end)
    else
        self.running.TinyIsland = false
        if self.threads.TinyIsland then
            task.cancel(self.threads.TinyIsland)
            self.threads.TinyIsland = nil
        end
        local char = LocalPlayer.Character
        if self._originalCFrame and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = self._originalCFrame
            self._originalCFrame = nil
        end
    end
end

return GodMode
