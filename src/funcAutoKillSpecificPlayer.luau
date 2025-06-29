local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local AutoKillSpecificPlayer = {}
AutoKillSpecificPlayer.__index = AutoKillSpecificPlayer

local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

function AutoKillSpecificPlayer.new(tab)
    local self = setmetatable({}, AutoKillSpecificPlayer)
    local dropdownId = "AutoKillPlayerDropdown"
    local toggleId = "AutoKillToggle"
    self.SelectedPlayer = nil
    self.Enabled = false

    self.PlayerDropdown = tab:AddDropdown(dropdownId, {
        Title = "Select Player",
        Values = getPlayerNames(),
        Multi = false,
        Default = nil,
        Callback = function(value)
            self.SelectedPlayer = value
        end
    })

    self.Toggle = tab:AddToggle(toggleId, {
        Title = "Auto Kill Selected Player",
        Default = false,
        Callback = function(state)
            self.Enabled = state
            if state then
                print("Auto kill enabled for:", self.SelectedPlayer)
            else
                print("Auto kill disabled")
            end
        end
    })

    Players.PlayerAdded:Connect(function()
        self.PlayerDropdown:SetValues(getPlayerNames())
    end)
    Players.PlayerRemoving:Connect(function()
        self.PlayerDropdown:SetValues(getPlayerNames())
    end)

    return self
end

return AutoKillSpecificPlayer
