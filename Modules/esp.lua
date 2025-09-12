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

Run.Heartbeat:Connect(function()
    -- если master выключен = выключаем всё
    if not getgenv().espEnabled then
        clearTracers()
        return
    end

    -- если tracers отключены, то тоже убираем
    if not getgenv().espTracers then
        clearTracers()
    end

    -- тут твой код ESP
    if getgenv().espEnemies then
        for _, player in ipairs(enemies) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- highlight ESP для врагов
                local hl = char:FindFirstChild("ESPHighlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "ESPHighlight"
                    hl.Parent = char
                end
                hl.Enabled = true
                hl.FillColor = Color3.fromRGB(255, 41, 121)
                hl.OutlineColor = Color3.fromRGB(127, 20, 60)

                -- tracers
                if getgenv().espTracers then
                    local cam = Workspace.CurrentCamera
                    local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local tracer = getTracer(player, Color3.fromRGB(255, 255, 255))
                        tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                    end
                end
            else
                if drawTracers[player] then
                    drawTracers[player].Visible = false
                end
            end
        end
    end
end)
