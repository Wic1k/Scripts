local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local drawTracers = {}
local teammates = {}
local enemies = {}

local function updateCache()
    teammates = {}
    enemies = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Team and p.Character and p.Character.Parent == Workspace then
            if p.Team == localPlayer.Team then
                table.insert(teammates, p)
            else
                table.insert(enemies, p)
            end
        end
    end
end

local function getTracer(player, color)
    if not drawTracers[player] then
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Transparency = 1
        line.Color = color
        drawTracers[player] = line
    end
    return drawTracers[player]
end

local function clearTracers()
    for _, line in pairs(drawTracers) do
        line.Visible = false
    end
end

Players.PlayerAdded:Connect(updateCache)
Players.PlayerRemoving:Connect(updateCache)
if localPlayer.Character then updateCache() end
localPlayer.CharacterAdded:Connect(updateCache)

RunService.Heartbeat:Connect(function()
    if not getgenv().espEnabled or not localPlayer:GetAttribute("Match") then
        clearTracers()
        return
    end

    if not getgenv().espTracers then
        clearTracers()
    end

    if getgenv().espTeamMates then
        for _, player in ipairs(teammates) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hl = char:FindFirstChild("ESPHighlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "ESPHighlight"
                    hl.Parent = char
                end
                hl.Enabled = true
                hl.FillColor = Color3.fromRGB(30,214,134)
                hl.OutlineColor = Color3.fromRGB(15,107,67)
                if getgenv().espTracers then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local tracer = getTracer(player, Color3.fromRGB(0,0,255))
                        tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                    end
                end
            else
                if drawTracers[player] then drawTracers[player].Visible = false end
            end
        end
    end

    if getgenv().espEnemies then
        for _, player in ipairs(enemies) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hl = char:FindFirstChild("ESPHighlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "ESPHighlight"
                    hl.Parent = char
                end
                hl.Enabled = true
                hl.FillColor = Color3.fromRGB(127,20,60)
                hl.OutlineColor = Color3.fromRGB(255,41,121)
                if getgenv().espTracers then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local tracer = getTracer(player, Color3.fromRGB(255,255,255))
                        tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                    end
                end
            else
                if drawTracers[player] then drawTracers[player].Visible = false end
            end
        end
    end
end)
