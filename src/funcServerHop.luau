local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Config = {
    AutoServerHop = false, -- [ Default: false ] -- Enable/disable auto server hopping
    MinPlayers = 10, -- [ Default: 10 ] -- Minimum players to trigger server hop
    CheckInterval = 10,
    PlayerBuffer = 1 -- [ Default: 1 ] -- Buffer for player count to avoid hopping to full servers
}

local ServerHop = {}
ServerHop.__index = ServerHop

function ServerHop.new(tab)
    local self = setmetatable({}, ServerHop)
    self.tab = tab
    self.running = false
    self.thread = nil

    self.Toggle = self.tab:AddToggle("ServerHopToggle", {
        Title = "Auto Server Hop",
        Description = "Automatically hops to a new server if player count is low.",
        Default = Config.AutoServerHop
    })
    self.Toggle:OnChanged(function(state)
        self:ToggleServerHop(state)
    end)

    -- Auto-enable if config says so
    if Config.AutoServerHop then
        self:ToggleServerHop(true)
        self.Toggle:SetState(true)
    end

    return self
end

local function GetServerList(placeId, cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(placeId)
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    return success and result or nil
end

local function FindServer(placeId, playerBuffer)
    local cursor = nil
    repeat
        local serverData = GetServerList(placeId, cursor)
        if serverData then
            for _, server in ipairs(serverData.data) do
                if server.id ~= game.JobId and server.playing <= (server.maxPlayers - playerBuffer) then
                    return server.id
                end
            end
            cursor = serverData.nextPageCursor
        else
            break
        end
    until not cursor
    return nil
end

function ServerHop:ToggleServerHop(state)
    self.running = state
    if state then
        self.thread = task.spawn(function()
            while self.running do
                task.wait(Config.CheckInterval)
                if #Players:GetPlayers() < Config.MinPlayers then
                    local targetServer = FindServer(game.PlaceId, Config.PlayerBuffer)
                    if targetServer then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, Players.LocalPlayer)
                        break
                    end
                end
            end
        end)
    else
        if self.thread then
            task.cancel(self.thread)
            self.thread = nil
        end
    end
end

return
