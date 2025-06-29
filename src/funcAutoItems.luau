local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ITEM_FIRE_DELAY = 0.05
local LOOP_DELAY = 0.05

local items = {
    ["TOUGH Bar"] = "toughBar",
    ["ULTRA Shake"] = "ultrashake",
    ["Protein Shake"] = "proteinShake",
    ["Energy Shake"] = "energyShake",
    ["Protein Bar"] = "proteinBar",
    ["Energy Bar"] = "energyBar"
}

local AutoItems = {}
AutoItems.__index = AutoItems

function AutoItems.new(tab)
    local self = setmetatable({}, AutoItems)
    self.Running = false
    self.Toggle = tab:AddToggle("AutoItemsToggle", {
        Title = "Auto Use Items",
        Default = false,
        Callback = function(state)
            if state then
                self:Start()
            else
                self:Stop()
            end
        end
    })

    return self
end

function AutoItems:Start()
    if self.Running then return end
    self.Running = true
    task.spawn(function()
        while self.Running do
            local backpack = player:FindFirstChild("Backpack")
            local muscleEvent = player:FindFirstChild("muscleEvent")
            if backpack and muscleEvent then
                for itemName, eventName in pairs(items) do
                    local count = 0
                    for _, v in ipairs(backpack:GetChildren()) do
                        if v.Name == itemName then
                            count = count + 1
                        end
                    end
                    for _ = 1, count do
                        local item = backpack:FindFirstChild(itemName)
                        if item and eventName then
                            muscleEvent:FireServer(eventName, item)
                        end
                        task.wait(ITEM_FIRE_DELAY)
                    end
                end
            end
            task.wait(LOOP_DELAY)
        end
        self.Running = false
    end)
end

function AutoItems:Stop()
    self.Running = false
end

function AutoItems:IsRunning()
    return self.Running
end

return AutoItems