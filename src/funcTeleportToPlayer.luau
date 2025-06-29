local Players = game:GetService("Players")

local Config = {
    Offset = Vector3.new(0, 3, 0)
}

local TeleportToPlayer = {}
TeleportToPlayer.__index = TeleportToPlayer

function TeleportToPlayer.new(tab)
    local self = setmetatable({}, TeleportToPlayer)
    self.tab = tab
    self.selectedPlayer = nil

    local section = self.tab:AddSection("Teleport To Player")

    local function getPlayerList()
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                table.insert(list, plr.Name .. " | " .. plr.DisplayName)
            end
        end
        return list
    end

    self.PlayerDropdown = section:AddDropdown("TeleportPlayerDropdown", {
        Title = "Select Player",
        Description = "Pick a player to teleport to.",
        Values = getPlayerList(),
        Default = nil,
        Multi = false
    })
    self.PlayerDropdown:OnChanged(function(value)
        if value then
            local name = value:match("^(.-) |")
            self.selectedPlayer = name
        else
            self.selectedPlayer = nil
        end
    end)

    local function updateDropdown()
        self.PlayerDropdown:SetValues(getPlayerList())
    end
    Players.PlayerAdded:Connect(updateDropdown)
    Players.PlayerRemoving:Connect(updateDropdown)

    section:AddButton({
        Title = "Teleport",
        Description = "Teleport to the selected player.",
        Callback = function()
            self:TeleportToSelectedPlayer()
        end
    })

    return self
end

function TeleportToPlayer:TeleportToSelectedPlayer()
    if not self.selectedPlayer then
        return
    end
    local target = Players:FindFirstChild(self.selectedPlayer)
    local character = Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Config.Offset
    end
end

return TeleportToPlayer
