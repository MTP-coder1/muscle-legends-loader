local Players = game:GetService("Players")

local Config = {
    ShowSelf = true
}

local StatsViewer = {}
StatsViewer.__index = StatsViewer

function StatsViewer.new(tab)
    local self = setmetatable({}, StatsViewer)
    self.tab = tab
    self.selectedPlayer = Players.LocalPlayer

    local section = self.tab:AddSection("Stats Viewer")

    local function getPlayerList()
        local list = {}
        if Config.ShowSelf then
            table.insert(list, Players.LocalPlayer.Name .. " | " .. Players.LocalPlayer.DisplayName)
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                table.insert(list, plr.Name .. " | " .. plr.DisplayName)
            end
        end
        return list
    end

    self.PlayerDropdown = section:AddDropdown("StatsViewerPlayerDropdown", {
        Title = "Select Player",
        Description = "View stats for selected player.",
        Values = getPlayerList(),
        Default = Players.LocalPlayer.Name .. " | " .. Players.LocalPlayer.DisplayName,
        Multi = false
    })
    self.PlayerDropdown:OnChanged(function(value)
        if value then
            local name = value:match("^(.-) |")
            self.selectedPlayer = Players:FindFirstChild(name) or Players.LocalPlayer
            self:UpdateStats()
        end
    end)

    local function updateDropdown()
        self.PlayerDropdown:SetValues(getPlayerList())
    end
    Players.PlayerAdded:Connect(updateDropdown)
    Players.PlayerRemoving:Connect(updateDropdown)

    local TimerParagraph, StatsParagraph, GainedParagraph
    local initialStats = {}
    local gainedStats = {}
    local startTime = workspace.DistributedGameTime

    function self:UpdateStats()
        local player = self.selectedPlayer or Players.LocalPlayer
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            return
        end

        local function waitForStat(statParent, statName)
            local stat = statParent:FindFirstChild(statName)
            while not stat do
                stat = statParent:FindFirstChild(statName)
                task.wait()
            end
            return stat
        end

        local StrengthStat = waitForStat(leaderstats, "Strength")
        local DurabilityStat = waitForStat(player, "Durability")
        local AgilityStat = waitForStat(player, "Agility")
        local RebirthsStat = waitForStat(leaderstats, "Rebirths")
        local BrawlsStat = waitForStat(leaderstats, "Brawls")

        local function formatNumber(n)
            return tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        end

        if not initialStats[player] then
            initialStats[player] = {
                Strength = StrengthStat.Value,
                Durability = DurabilityStat.Value,
                Agility = AgilityStat.Value,
                Rebirths = RebirthsStat.Value,
                Brawls = BrawlsStat.Value
            }
        end

        gainedStats[player] = {
            Strength = math.max(0, StrengthStat.Value - initialStats[player].Strength),
            Durability = math.max(0, DurabilityStat.Value - initialStats[player].Durability),
            Agility = math.max(0, AgilityStat.Value - initialStats[player].Agility),
            Rebirths = math.max(0, RebirthsStat.Value - initialStats[player].Rebirths),
            Brawls = math.max(0, BrawlsStat.Value - initialStats[player].Brawls)
        }

        local statsContent = "> Strength: " .. formatNumber(StrengthStat.Value) .. "\n" .. "> Durability: " ..
                                 formatNumber(DurabilityStat.Value) .. "\n" .. "> Agility: " ..
                                 formatNumber(AgilityStat.Value) .. "\n" .. "> Rebirths: " ..
                                 formatNumber(RebirthsStat.Value) .. "\n" .. "> Brawls: " ..
                                 formatNumber(BrawlsStat.Value)

        local gainedContent = "> Gained Strength: " .. formatNumber(gainedStats[player].Strength) .. "\n" ..
                                  "> Gained Durability: " .. formatNumber(gainedStats[player].Durability) .. "\n" ..
                                  "> Gained Agility: " .. formatNumber(gainedStats[player].Agility) .. "\n" ..
                                  "> Gained Rebirths: " .. formatNumber(gainedStats[player].Rebirths) .. "\n" ..
                                  "> Gained Brawls: " .. formatNumber(gainedStats[player].Brawls)

        if StatsParagraph then
            StatsParagraph:SetDesc(statsContent)
        else
            StatsParagraph = section:AddParagraph({
                Title = "Stats",
                Content = statsContent
            })
        end

        if GainedParagraph then
            GainedParagraph:SetDesc(gainedContent)
        else
            GainedParagraph = section:AddParagraph({
                Title = "Earned Stats",
                Content = gainedContent
            })
        end
    end

    local function updateTimer()
        while true do
            local elapsedTime = math.floor(workspace.DistributedGameTime - startTime)
            local hours = math.floor(elapsedTime / 3600)
            local minutes = math.floor((elapsedTime % 3600) / 60)
            local seconds = elapsedTime % 60
            local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)

            if TimerParagraph then
                TimerParagraph:SetDesc("> Time: " .. formattedTime)
            else
                TimerParagraph = section:AddParagraph({
                    Title = "Elapsed Time",
                    Content = "> Time: " .. formattedTime
                })
            end

            task.wait(1)
        end
    end

    self:UpdateStats()
    task.spawn(updateTimer)

    local function connectStats()
        local player = self.selectedPlayer or Players.LocalPlayer
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            return
        end

        local function safeConnect(stat)
            if stat then
                stat.Changed:Connect(function()
                    self:UpdateStats()
                end)
            end
        end

        safeConnect(leaderstats:FindFirstChild("Strength"))
        safeConnect(player:FindFirstChild("Durability"))
        safeConnect(player:FindFirstChild("Agility"))
        safeConnect(leaderstats:FindFirstChild("Rebirths"))
        safeConnect(leaderstats:FindFirstChild("Brawls"))
    end

    connectStats()

    self.PlayerDropdown:OnChanged(function()
        self:UpdateStats()
        connectStats()
    end)

    return self
end

return StatsViewer
