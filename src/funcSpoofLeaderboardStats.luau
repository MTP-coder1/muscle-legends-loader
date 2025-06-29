local Workspace = game:GetService("Workspace")

local Config = {
    TargetUsername = "",
    ReplaceUsername = "",
    ReplaceAmount = "",
    ReplaceRank = "",
    Enabled = false
}

local SpoofLeaderboardStats = {}
SpoofLeaderboardStats.__index = SpoofLeaderboardStats

local _originals = {}

local function parseAmount(str)
    if not str or str == "" then
        return nil
    end
    local s = str:gsub(",", ""):upper()
    local mult = 1
    if s:find("K") then
        mult = 1e3
        s = s:gsub("K", "")
    elseif s:find("M") then
        mult = 1e6
        s = s:gsub("M", "")
    elseif s:find("B") then
        mult = 1e9
        s = s:gsub("B", "")
    end
    local num = tonumber(s)
    if num then
        return tostring(math.floor(num * mult))
    end
    return str
end

function SpoofLeaderboardStats.new(tab)
    local self = setmetatable({}, SpoofLeaderboardStats)
    self.tab = tab
    self.running = false

    local section = self.tab:AddSection("Spoof Leaderboard Stats")

    self.TargetInput = section:AddInput("TargetUsernameInput", {
        Title = "Target Username",
        Placeholder = "Enter username to spoof",
        Default = "",
        Callback = function(value)
            Config.TargetUsername = value
        end
    })

    self.ReplaceUserInput = section:AddInput("ReplaceUsernameInput", {
        Title = "Replace Username",
        Placeholder = "Enter new username",
        Default = "",
        Callback = function(value)
            Config.ReplaceUsername = value
        end
    })

    self.ReplaceAmountInput = section:AddInput("ReplaceAmountInput", {
        Title = "Replace Rebirths",
        Placeholder = "e.g. 1M",
        Default = "",
        Callback = function(value)
            Config.ReplaceAmount = parseAmount(value)
        end
    })

    self.ReplaceRankInput = section:AddInput("ReplaceRankInput", {
        Title = "Replace Rank",
        Placeholder = "e.g. 1",
        Default = "",
        Callback = function(value)
            Config.ReplaceRank = value
        end
    })

    self.Toggle = section:AddToggle("EnableSpoofLeaderboardToggle", {
        Title = "Enable Leaderboard Spoof",
        Description = "Spoof leaderboard for the selected player.",
        Default = false
    })
    self.Toggle:OnChanged(function(state)
        Config.Enabled = state
        self:ToggleSpoof(state)
    end)

    self.Button = section:AddButton({
        Title = "Apply Spoof Now",
        Description = "Manually apply spoofing once.",
        Callback = function()
            self:UpdateLeaderboard()
        end
    })

    self.RevertButton = section:AddButton({
        Title = "Revert Spoof",
        Description = "Restore original leaderboard values.",
        Callback = function()
            self:RevertLeaderboard()
        end
    })

    return self
end

function SpoofLeaderboardStats:UpdateLeaderboard()
    if not Config.Enabled then
        return
    end
    local leaderboard = Workspace:FindFirstChild("rebirthsLeaderboard")
    if not leaderboard then
        return
    end
    local boardPart = leaderboard:FindFirstChild("leaderboardPart")
    if not boardPart then
        return
    end
    local gui = boardPart:FindFirstChild("leaderboardGui")
    if not gui then
        return
    end
    local playerList = gui:FindFirstChild("playerList")
    if not playerList then
        return
    end
    local innerFrame = playerList:FindFirstChild("innerFrame")
    if not innerFrame then
        return
    end

    for _, entry in pairs(innerFrame:GetChildren()) do
        if entry:IsA("Frame") and entry.Name == "playerEntry" then
            local nameLabel = entry:FindFirstChild("nameLabel")
            local amountLabel = entry:FindFirstChild("amountLabel")
            local rankLabel = entry:FindFirstChild("rankLabel")
            if nameLabel and nameLabel:IsA("TextLabel") and nameLabel.Text == Config.TargetUsername and
                Config.TargetUsername ~= "" then

                -- Save originals for revert
                if not _originals[entry] then
                    _originals[entry] = {
                        name = nameLabel.Text,
                        amount = amountLabel and amountLabel.Text or nil,
                        rank = rankLabel and rankLabel.Text or nil
                    }
                end

                if Config.ReplaceUsername and Config.ReplaceUsername ~= "" then
                    nameLabel.Text = Config.ReplaceUsername
                end
                if amountLabel and amountLabel:IsA("TextLabel") and amountLabel.Text ~= "0" and Config.ReplaceAmount and
                    Config.ReplaceAmount ~= "" then
                    amountLabel.Text = Config.ReplaceAmount
                end
                if rankLabel and rankLabel:IsA("TextLabel") and Config.ReplaceRank and Config.ReplaceRank ~= "" then
                    rankLabel.Text = tostring(Config.ReplaceRank)
                end
            end
        end
    end
end

function SpoofLeaderboardStats:RevertLeaderboard()
    local leaderboard = Workspace:FindFirstChild("rebirthsLeaderboard")
    if not leaderboard then
        return
    end
    local boardPart = leaderboard:FindFirstChild("leaderboardPart")
    if not boardPart then
        return
    end
    local gui = boardPart:FindFirstChild("leaderboardGui")
    if not gui then
        return
    end
    local playerList = gui:FindFirstChild("playerList")
    if not playerList then
        return
    end
    local innerFrame = playerList:FindFirstChild("innerFrame")
    if not innerFrame then
        return
    end

    for entry, original in pairs(_originals) do
        if entry and entry.Parent == innerFrame then
            local nameLabel = entry:FindFirstChild("nameLabel")
            local amountLabel = entry:FindFirstChild("amountLabel")
            local rankLabel = entry:FindFirstChild("rankLabel")
            if nameLabel and original.name then
                nameLabel.Text = original.name
            end
            if amountLabel and original.amount then
                amountLabel.Text = original.amount
            end
            if rankLabel and original.rank then
                rankLabel.Text = original.rank
            end
        end
    end
    _originals = {}
end

function SpoofLeaderboardStats:ToggleSpoof(state)
    self.running = state
    if state then
        if not self.loop then
            self.loop = task.spawn(function()
                while self.running do
                    pcall(function()
                        self:UpdateLeaderboard()
                    end)
                    task.wait(0.5)
                end
            end)
        end
    else
        if self.loop then
            task.cancel(self.loop)
            self.loop = nil
        end
        self:RevertLeaderboard()
    end
end

return SpoofLeaderboardStats
