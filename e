local esplibrary = {
    enabled = false,
    maxdistance = 3000,
    --
    textfont = 2,
    textsize = 12,
    --
    tweenhealth = false,
    --
    friendcheck = false,
    visiblecheck = false,
    --
    distance_format = 0.4,
    distance_measurement = "m",
    -- BOX/ETC
    boxes = {["enabled"] = false, ["color"] = Color3.fromRGB(255, 255, 255), ["type"] = "Bounding"},
    healthbars = {["enabled"] = false},
    healthtext = {["enabled"] = false},
    -- TEXT
    names = {["enabled"] = false, ["displaynames"] = false, ["color"] = Color3.fromRGB(255, 255, 255)},
    distance = {["enabled"] = false, ["color"] = Color3.fromRGB(255, 255, 255)},
    weapon = {["enabled"] = false, ["color"] = Color3.fromRGB(255, 255, 255)},
    --
    chams = {["enabled"] = false, ["color"] = Color3.fromRGB(255, 255, 255), ["transparency"] = 0},
    glow = {["enabled"] = false, ["color"] = Color3.fromRGB(0, 0, 0), ["transparency"] = 0}
}
local utility = {}
local connections = {}
local drawings = {}
local signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/razorwarecc/core-drawing/main/signal3"))()
local new, uis, runservice, players, localplayer, wtvp, camera, headoff, legoff = Drawing.new, game:GetService("UserInputService"), game:GetService("RunService"),  game:GetService("Players"), game:GetService("Players").LocalPlayer, workspace.CurrentCamera.WorldToViewportPoint, workspace.CurrentCamera,  Vector3.new(0, 0.3, 0), Vector3.new(0, 6, 0)
esplibrary.unload = signal.new()
function utility:draw(name, props)
    local drawing = new(name)
    for a, b in pairs(props) do
        drawing[a] = b
    end
    return drawing
end
function utility:instance(name, props)
    local instance = Instance.new(name)
    for a, b in pairs(props) do
        instance[a] = b
    end
    return instance
end
function utility:distance(part1, part2)
    if part1 and part2 then
        local distance = (part1.Position - part2.Position).Magnitude
        return distance * esplibrary.distance_format
    end
    return 0
end
function utility:connection(signal, func)
    local created = signal:Connect(func)
    table.insert(connections, created)
    return created
end
function utility:friendcheck(userid)
    return localplayer:IsFriendsWith(userid) 
end
function utility:cham(character)
    return utility:instance("Highlight", {Parent = character, FillTransparency = 1, OutlineTransparency = 1})
end
function utility:checkchar(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
        return true
    end
    return false
end
function utility:gettool(character)
    if character:FindFirstChildOfClass("Tool") then
        return character:FindFirstChildOfClass("Tool").Name
    end
    return "None"
end
function utility:gethrp(character)
    return character:FindFirstChild("HumanoidRootPart")
end
function utility:gethead(character)
    return character:FindFirstChild("Head")
end
function utility:remove(player)
    for a, b in pairs(drawings) do
        if b.player == player then
            for c, d in pairs(b) do
                if typeof(d) == "DrawingObject" or typeof(d) == "table" then
                    d:Remove()
                elseif typeof(d) == "Instance" and d:IsA("Highlight") then
                    d:Remove()
                end
            end
            table.remove(drawings, a)
            break
        end
    end
end
function utility:espexists(player)
    for a, b in pairs(drawings) do
        if b.player == player then
            return true
        end
    end
    return false
end
function utility:create(player)
    --
    if not utility:checkchar(player) then
        return
    end
    --
    if utility:espexists(player) then
        return
    end
    --
    local tbl = {}
    ----- DRAWINGS
    -- text first since easiest
    tbl.player = player
    --
    tbl.names = utility:draw("Text", {Color = esplibrary.names.color, Center = true, Visible = false, Size = esplibrary.textsize, Font = esplibrary.textfont, Outline = true, ZIndex = 2})
    tbl.distance = utility:draw("Text", {Color = esplibrary.distance.color, Center = true, Visible = false, Size = esplibrary.textsize, Font = esplibrary.textfont, Outline = true, ZIndex = 2})
    tbl.weapon = utility:draw("Text", {Color = esplibrary.weapon.color, Center = true, Visible = false, Size = esplibrary.textsize, Font = esplibrary.textfont, Outline = true, ZIndex = 2})
    --------
    tbl.box = utility:draw("Square", {Color = esplibrary.boxes.color, Visible = false, ZIndex = 2})
    tbl.boxoutline = utility:draw("Square", {Color = Color3.fromRGB(0, 0, 0), Visible = false, Thickness = 2})
    for i = 1, 12 do 
        local drawingname = "3dbox_"..i
        tbl[drawingname] = utility:draw("Line", {Visible = false, Color = Color3.fromRGB(255, 255, 255)})
    end
    --------
    tbl.healthbar = utility:draw("Line", {Color = Color3.fromRGB(0, 255, 0), Visible = false, ZIndex = 2})
    tbl.healthbaroutline = utility:draw("Line", {Color = Color3.fromRGB(0, 0, 0), Visible = false, Thickness = 4, ZIndex = 1})
    tbl.healthtext = utility:draw("Text", {Color = Color3.fromRGB(0, 255, 0), Center = true, Visible = false, Size = esplibrary.textsize, Font = esplibrary.textfont, Outline = true})
    --------
    tbl.highlight = utility:cham(tbl.player.Character)
    --------
    table.insert(drawings, tbl)
end
local mainconnection = utility:connection(runservice.RenderStepped, function()
    for index, drawing in pairs(drawings) do
        local player = drawing.player
        if utility:checkchar(player) and utility:checkchar(localplayer) then
            local isvalid = true
            local character = player.Character
            local head, hrp = utility:gethead(character), utility:gethrp(character)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            --
            if esplibrary.friendcheck and utility:friendcheck(player.UserId) then
                utility:remove(player)
            end
            if utility:distance(hrp, utility:gethrp(localplayer.Character)) > esplibrary.maxdistance then
                isvalid = false
            end
            
            local wts, onscreen = wtvp(camera, hrp.Position)
            local boxheadwts, _ = wtvp(camera, head.Position + Vector3.new(0, 0.5, 0))
            local boxlegwts, _ = wtvp(camera, head.Position - Vector3.new(0, 5.1, 0))
            local threedboxtopcenter
            local threedboxbottomcenter
            local threedmiddleleft
            -- BOXES
            if esplibrary.boxes.type == "Bounding" then
                for i = 1, 12 do
                    local name = "3dbox_"..i
                    setrenderproperty(drawing[name], "Visible", false)
                end

                setrenderproperty(drawing.box, "Visible", (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid))
                setrenderproperty(drawing.box, "Position", Vector2.new(math.floor(wts.X) - math.floor(drawing.box.Size.X) / 2, math.floor(wts.Y) - math.floor(drawing.box.Size.Y) / 1.6))
                setrenderproperty(drawing.box, "Size", Vector2.new(2222 / math.floor(wts.Z), math.floor(boxheadwts.Y) - math.floor(boxlegwts.Y))) 
                setrenderproperty(drawing.box, "Color", esplibrary.boxes.color)
                --
                setrenderproperty(drawing.boxoutline, "Visible", drawing.box.Visible)
                setrenderproperty(drawing.boxoutline, "Size", Vector2.new(drawing.box.Size.X + 2, drawing.box.Size.Y + 2))
                setrenderproperty(drawing.boxoutline, "Position", Vector2.new(drawing.box.Position.X - 1, drawing.box.Position.Y - 1))
            elseif esplibrary.boxes.type == "3D" then
                setrenderproperty(drawing.box, "Visible", false)
                setrenderproperty(drawing.boxoutline, "Visible", false)
                local headwts1, _ = wtvp(camera, Vector3.new(hrp.Position.X + headoff.X - 2, hrp.Position.Y + headoff.Y, hrp.Position.Z + headoff.Z + 2))
                local legwts1, _ = wtvp(camera, Vector3.new(hrp.Position.X - legoff.X - 2, hrp.Position.Y - legoff.Y, hrp.Position.Z - legoff.Z + 2))
        
                local headwts2, _ = wtvp(camera, Vector3.new(hrp.Position.X + headoff.X - 2, hrp.Position.Y + headoff.Y, hrp.Position.Z + headoff.Z - 2))
                local legwts2, _ = wtvp(camera, Vector3.new(hrp.Position.X - legoff.X - 2, hrp.Position.Y - legoff.Y, hrp.Position.Z - legoff.Z - 2))
        
                local headwts3, _ = wtvp(camera, Vector3.new(hrp.Position.X + headoff.X + 2, hrp.Position.Y + headoff.Y, hrp.Position.Z - headoff.Z - 2))
                local legwts3, _ = wtvp(camera, Vector3.new(hrp.Position.X - legoff.X + 2, hrp.Position.Y - legoff.Y, hrp.Position.Z - legoff.Z - 2))
        
                local headwts4, _ = wtvp(camera, Vector3.new(hrp.Position.X + headoff.X + 2, hrp.Position.Y + headoff.Y, hrp.Position.Z - headoff.Z + 2))
                local legwts4, _ = wtvp(camera, Vector3.new(hrp.Position.X - legoff.X + 2, hrp.Position.Y - legoff.Y, hrp.Position.Z - legoff.Z + 2))
        
                threedboxtopcenter = Vector2.new(
                    (headwts1.X + headwts2.X + headwts3.X + headwts4.X) / 4,
                    (headwts1.Y + headwts2.Y + headwts3.Y + headwts4.Y) / 4
                )
                threedboxbottomcenter = Vector2.new(
                    (legwts1.X + legwts2.X + legwts3.X + legwts4.X) / 4,
                    (legwts1.Y + legwts2.Y + legwts3.Y + legwts4.Y) / 4
                )
                threedmiddleleft = Vector2.new(
                    (headwts1.X + headwts4.X + legwts1.X + legwts4.X) / 4,
                    (headwts1.Y + headwts4.Y + legwts1.Y + legwts4.Y) / 4
                )

                drawing["3dbox_1"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_1"].Color = esplibrary.boxes.color
                drawing["3dbox_1"].From = Vector2.new(headwts1.X, headwts1.Y)
                drawing["3dbox_1"].To = Vector2.new(legwts1.X, legwts1.Y)
                
                drawing["3dbox_2"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_2"].Color = esplibrary.boxes.color
                drawing["3dbox_2"].From = Vector2.new(headwts2.X, headwts2.Y)
                drawing["3dbox_2"].To = Vector2.new(legwts2.X, legwts2.Y)
        
                drawing["3dbox_3"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_3"].Color = esplibrary.boxes.color
                drawing["3dbox_3"].From = Vector2.new(headwts3.X, headwts3.Y)
                drawing["3dbox_3"].To = Vector2.new(legwts3.X, legwts3.Y)
        
                drawing["3dbox_4"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_4"].Color = esplibrary.boxes.color
                drawing["3dbox_4"].From = Vector2.new(headwts4.X, headwts4.Y)
                drawing["3dbox_4"].To = Vector2.new(legwts4.X, legwts4.Y)
                
                drawing["3dbox_5"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_5"].Color = esplibrary.boxes.color
                drawing["3dbox_5"].From = Vector2.new(headwts1.X, headwts1.Y)
                drawing["3dbox_5"].To = Vector2.new(headwts2.X, headwts2.Y)
        
                drawing["3dbox_6"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_6"].Color = esplibrary.boxes.color
                drawing["3dbox_6"].From = Vector2.new(headwts2.X, headwts2.Y)
                drawing["3dbox_6"].To = Vector2.new(headwts3.X, headwts3.Y)
        
                drawing["3dbox_7"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_7"].Color = esplibrary.boxes.color
                drawing["3dbox_7"].From = Vector2.new(headwts3.X, headwts3.Y)
                drawing["3dbox_7"].To = Vector2.new(headwts4.X, headwts4.Y)
        
                drawing["3dbox_8"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_8"].Color = esplibrary.boxes.color
                drawing["3dbox_8"].From = Vector2.new(headwts1.X, headwts1.Y)
                drawing["3dbox_8"].To = Vector2.new(headwts4.X, headwts4.Y)
        
                drawing["3dbox_9"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_9"].Color = esplibrary.boxes.color
                drawing["3dbox_9"].From = Vector2.new(legwts1.X, legwts1.Y)
                drawing["3dbox_9"].To = Vector2.new(legwts2.X, legwts2.Y)
        
                drawing["3dbox_10"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_10"].Color = esplibrary.boxes.color
                drawing["3dbox_10"].From = Vector2.new(legwts2.X, legwts2.Y)
                drawing["3dbox_10"].To = Vector2.new(legwts3.X, legwts3.Y)
        
                drawing["3dbox_11"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_11"].Color = esplibrary.boxes.color
                drawing["3dbox_11"].From = Vector2.new(legwts3.X, legwts3.Y)
                drawing["3dbox_11"].To = Vector2.new(legwts4.X, legwts4.Y)
        
                drawing["3dbox_12"].Visible = (onscreen and esplibrary.enabled and esplibrary.boxes.enabled and isvalid)
                drawing["3dbox_12"].Color = esplibrary.boxes.color
                drawing["3dbox_12"].From = Vector2.new(legwts1.X, legwts1.Y)
                drawing["3dbox_12"].To = Vector2.new(legwts4.X, legwts4.Y)
            end
            --------------------------------------------------------------------------------------------------------------
            -- NAMES
            setrenderproperty(drawing.names, "Visible", (onscreen and esplibrary.enabled and esplibrary.names.enabled and isvalid))
            setrenderproperty(drawing.names, "Color", esplibrary.names.color)
            if drawing.names.Visible then
                if drawing["3dbox_1"].Visible then
                        
                    setrenderproperty(drawing.names, "Position", Vector2.new(threedboxtopcenter.X, threedboxtopcenter.Y - 12))
                else
                    setrenderproperty(drawing.names, "Position", Vector2.new(drawing.box.Position.X + drawing.box.Size.X / 2, drawing.box.Position.Y + drawing.box.Size.Y / 1 - 14))
                end
                if esplibrary.names.displaynames then
                    setrenderproperty(drawing.names, "Text", player.DisplayName)
                else
                    setrenderproperty(drawing.names, "Text", player.Name)
                end
            end
            --------------------------------------------------------------------------------------------------------------
            setrenderproperty(drawing.distance, "Visible", (onscreen and esplibrary.enabled and esplibrary.distance.enabled and isvalid))
            setrenderproperty(drawing.distance, "Color", esplibrary.distance.color)
            if drawing.distance.Visible then
                if drawing["3dbox_1"].Visible then
                    setrenderproperty(drawing.distance, "Position", Vector2.new(threedboxbottomcenter.X, threedboxbottomcenter.Y + 3))
                
                else
                    setrenderproperty(drawing.distance, "Position", Vector2.new(drawing.box.Position.X + drawing.box.Size.X / 2, drawing.box.Position.Y + 3))
                end
                if utility:checkchar(localplayer) and utility:checkchar(player) then
                    drawing.distance.Text = tostring(math.round(utility:distance(hrp, utility:gethrp(localplayer.Character))))..esplibrary.distance_measurement
                end
            end
            --------------------------------------------------------------------------------------------------------------
            setrenderproperty(drawing.weapon, "Visible", (onscreen and esplibrary.enabled and esplibrary.weapon.enabled and isvalid))
            setrenderproperty(drawing.weapon, "Color", esplibrary.weapon.color)
            
            if drawing.weapon.Visible then
                drawing.weapon.Text = utility:gettool(character)
                if drawing.distance.Visible then
                    setrenderproperty(drawing.weapon, "Position", Vector2.new(drawing.distance.Position.X, drawing.distance.Position.Y + 13))
                else
                    if drawing["3dbox_1"].Visible then
                        setrenderproperty(drawing.weapon, "Position", Vector2.new(threedboxbottomcenter.X, threedboxbottomcenter.Y + 3))
                    else
                        setrenderproperty(drawing.weapon, "Position", Vector2.new(drawing.box.Position.X + drawing.box.Size.X / 2, drawing.box.Position.Y + 3))
                    end
                end
            end
            --------------------------------------------------------------------------------------------------------------

            setrenderproperty(drawing.healthbar, "Visible", (onscreen and esplibrary.enabled and esplibrary.healthbars.enabled and isvalid and esplibrary.boxes.type == "Bounding"))
            setrenderproperty(drawing.healthbaroutline, "Visible", drawing.healthbar.Visible)
            do
                if esplibrary.boxes.type == "Bounding" then
                    -- Bounding Box Health Bar
                    setrenderproperty(drawing.healthbar, "Visible", (onscreen and esplibrary.enabled and esplibrary.healthbars.enabled and isvalid))
                    setrenderproperty(drawing.healthbaroutline, "Visible", drawing.healthbar.Visible)
                    if drawing.healthbar.Visible then
                        if humanoid then
                            local health, maxhealth = humanoid.Health, humanoid.MaxHealth
                            local from = Vector2.new(drawing.box.Position.X - 5, drawing.box.Position.Y)
                            local to = Vector2.new(from.X, from.Y + drawing.box.Size.Y * (health / maxhealth))
                
                            setrenderproperty(drawing.healthbar, "From", from)
                            setrenderproperty(drawing.healthbar, "To", to)
                
                            setrenderproperty(drawing.healthbaroutline, "From", Vector2.new(from.X - 1, drawing.box.Position.Y - 1))
                            setrenderproperty(drawing.healthbaroutline, "To", Vector2.new(from.X + 1, drawing.box.Position.Y + drawing.box.Size.Y + 1))
                        end
                    end
                end
            end
            --------------------------------------------------------------------------------------------------------------
            setrenderproperty(drawing.healthtext, "Visible", (onscreen and esplibrary.enabled and esplibrary.healthtext.enabled and isvalid))
            if drawing.healthtext.Visible then
                if drawing.healthbar.Visible then
                    setrenderproperty(drawing.healthtext, "Position", Vector2.new(drawing.healthbar.To.X - 12, drawing.healthbar.To.Y))
                else
                    local from = Vector2.new(drawing.box.Position.X - 5, drawing.box.Position.Y)
                    setrenderproperty(drawing.healthtext, "Position", Vector2.new(from.X, from.Y + drawing.box.Size.Y))
                end
                if humanoid then
                    setrenderproperty(drawing.healthtext, "Text", math.round(humanoid.Health))
                end
            end
            --------------------------------------------------------------------------------------------------------------
            drawing.highlight.Enabled = esplibrary.enabled and isvalid
            if drawing.highlight.Enabled then
                if esplibrary.chams.enabled then
                    drawing.highlight.FillTransparency = esplibrary.chams.transparency
                    drawing.highlight.FillColor = esplibrary.chams.color
                else
                    drawing.highlight.FillTransparency = 1
                end
                if esplibrary.glow.enabled then
                    drawing.highlight.OutlineTransparency = esplibrary.glow.transparency
                    drawing.highlight.OutlineColor = esplibrary.glow.color
                else
                    drawing.highlight.OutlineTransparency = 1
                end
            end
            --------------------------------------------------------------------------------------------------------------
            if drawing.names.Font ~= esplibrary.textfont then
                drawing.names.Font = esplibrary.textfont
            end
            if drawing.names.Size ~= esplibrary.textsize then
                drawing.names.Size = esplibrary.textsize
            end
            ------------------------------------------------------------------
            if drawing.distance.Font ~= esplibrary.textfont then
                drawing.distance.Font = esplibrary.textfont
            end
            if drawing.distance.Size ~= esplibrary.textsize then
                drawing.distance.Size = esplibrary.textsize
            end
            ------------------------------------------------------------------
            if drawing.weapon.Font ~= esplibrary.textfont then
                drawing.weapon.Font = esplibrary.textfont
            end
            if drawing.weapon.Size ~= esplibrary.textsize then
                drawing.weapon.Size = esplibrary.textsize
            end
            ------------------------------------------------------------------
            if drawing.healthtext.Font ~= esplibrary.textfont then
                drawing.healthtext.Font = esplibrary.textfont
            end
            if drawing.healthtext.Size ~= esplibrary.textsize then
                drawing.healthtext.Size = esplibrary.textsize
            end
        else
            utility:remove(player)
        end
    end
    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= localplayer then
            utility:create(v)
        end
    end
end)
utility:connection(esplibrary.unload, function()
    for _, player in pairs(game.Players:GetPlayers()) do
        utility:remove(player)
    end
    mainconnection:Disconnect()
end)
return esplibrary
