local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local Config = {
    DefaultFOV = 100,
    MinFOV = 40,
    MaxFOV = 200,
    FOVStep = 10
}

local SpectatePlayer = {}
SpectatePlayer.__index = SpectatePlayer

function SpectatePlayer.new(tab)
    local self = setmetatable({}, SpectatePlayer)
    self.tab = tab
    self.spectating = false
    self.targetPlayer = nil
    self.defaultFOV = Config.DefaultFOV
    self.spectateThread = nil

    local section = self.tab:AddSection("Spectate Player")

    local function getPlayerList()
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                table.insert(list, plr.Name .. " | " .. plr.DisplayName)
            end
        end
        return list
    end

    self.PlayerDropdown = section:AddDropdown("SpectatePlayerDropdown", {
        Title = "Select Player",
        Description = "Pick a player to spectate.",
        Values = getPlayerList(),
        Default = nil,
        Multi = false
    })
    self.PlayerDropdown:OnChanged(function(value)
        if value then
            local name = value:match("^(.-) |")
            self.targetPlayer = name
        else
            self.targetPlayer = nil
        end
    end)

    local function updateDropdown()
        self.PlayerDropdown:SetValues(getPlayerList())
    end
    Players.PlayerAdded:Connect(updateDropdown)
    Players.PlayerRemoving:Connect(updateDropdown)

    self.FOVSlider = section:AddSlider("SpectateFOVSlider", {
        Title = "Camera FOV",
        Description = "Adjust the camera field of view.",
        Min = Config.MinFOV,
        Max = Config.MaxFOV,
        Default = Config.DefaultFOV,
        Increment = Config.FOVStep,
        Rounding = 0
    })
    self.FOVSlider:OnChanged(function(value)
        Camera.FieldOfView = value
        self.defaultFOV = value
    end)

    self.Toggle = section:AddToggle("SpectatePlayerToggle", {
        Title = "Spectate Player",
        Description = "Spectate the selected player.",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        self:ToggleSpectate(state)
    end)

    return self
end

function SpectatePlayer:ToggleSpectate(state)
    if state then
        self.spectating = true
        self.spectateThread = task.spawn(function()
            local lastFOV = Camera.FieldOfView
            while self.spectating do
                local player = self.targetPlayer and Players:FindFirstChild(self.targetPlayer)
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    Camera.CameraSubject = player.Character.HumanoidRootPart
                end
                task.wait(0.1)
            end
            Camera.CameraSubject = Players.LocalPlayer.Character and
                                       Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            Camera.FieldOfView = self.defaultFOV
        end)
    else
        self.spectating = false
        if self.spectateThread then
            task.cancel(self.spectateThread)
            self.spectateThread = nil
        end
        Camera.CameraSubject = Players.LocalPlayer.Character and
                                   Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        Camera.FieldOfView = self.defaultFOV
    end
end

return SpectatePlayer
