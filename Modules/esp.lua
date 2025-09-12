local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local TEAMMATE_OUTLINE = Color3.fromRGB(30, 214, 134)
local TEAMMATE_FILL = Color3.fromRGB(15, 107, 67)
local ENEMY_OUTLINE = Color3.fromRGB(255, 41, 121)
local ENEMY_FILL = Color3.fromRGB(127, 20, 60)

local localPlayer = Players.LocalPlayer
local teammates = {}
local enemies = {}
local drawTracers = {}

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

local function createEnemyBillboard(humanoidRootPart)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyBillboard"
	billboard.Adornee = humanoidRootPart
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(1, 0, 1, 0)
	billboard.Parent = humanoidRootPart
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = ENEMY_OUTLINE
	frame.BorderSizePixel = 0
	frame.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame
end

local function updateCache()
	teammates = {}
	enemies = {}
	for _, player in pairs(Players:GetPlayers()) do
		if player and player ~= localPlayer and player.Team and player.Character and player.Character.Parent == Workspace then
			if player.Team == localPlayer.Team then
				table.insert(teammates, player)
			else
				table.insert(enemies, player)
			end
		end
	end
end

if localPlayer.Character then
	updateCache()
end

local Connections = {}
Connections[0] = localPlayer.CharacterAdded:Connect(updateCache)
Connections[1] = RunService.Heartbeat:Connect(function()
	if not localPlayer:GetAttribute("Match") then
		clearTracers()
		return
	end
	if not getgenv().espEnabled then
		clearTracers()
		return
	end
	if getgenv().espTeamMates then
		for _, player in ipairs(teammates) do
			local character = player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if character and hrp then
				local highlight = character:FindFirstChild("ESPHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "ESPHighlight"
					highlight.Parent = character
				end
				highlight.Enabled = true
				highlight.OutlineColor = TEAMMATE_OUTLINE
				highlight.FillColor = TEAMMATE_FILL
				highlight.FillTransparency = 0.7
				local eb = hrp:FindFirstChild("EnemyBillboard")
				if eb then eb:Destroy() end
				if getgenv().espTracers then
					local pos,onScreen = Camera:WorldToViewportPoint(hrp.Position)
					if onScreen then
						local tracer = getTracer(player, Color3.fromRGB(0,0,255))
						tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
						tracer.To = Vector2.new(pos.X,pos.Y)
						tracer.Visible = true
					end
				else
					if drawTracers[player] then drawTracers[player].Visible = false end
				end
			end
		end
	end
	if getgenv().espEnemies then
		for _, player in ipairs(enemies) do
			local character = player.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if character and hrp then
				local highlight = character:FindFirstChild("ESPHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "ESPHighlight"
					highlight.Parent = character
				end
				highlight.Enabled = true
				highlight.OutlineColor = ENEMY_OUTLINE
				highlight.FillColor = ENEMY_FILL
				highlight.FillTransparency = 0.7
				local eb = hrp:FindFirstChild("EnemyBillboard")
				if not eb then createEnemyBillboard(hrp) end
				if getgenv().espTracers then
					local pos,onScreen = Camera:WorldToViewportPoint(hrp.Position)
					if onScreen then
						local tracer = getTracer(player, Color3.fromRGB(255,255,255))
						tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
						tracer.To = Vector2.new(pos.X,pos.Y)
						tracer.Visible = true
					end
				else
					if drawTracers[player] then drawTracers[player].Visible = false end
				end
			end
		end
	end
end)

local function cleanup()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("ESPHighlight")
            if h then h:Destroy() end
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local eb = hrp:FindFirstChild("EnemyBillboard")
                if eb then eb:Destroy() end
            end
        end
    end
    for _, line in pairs(drawTracers) do
        line.Visible = false
    end
end

Connections.cleanup = cleanup
return Connections

return Connections
