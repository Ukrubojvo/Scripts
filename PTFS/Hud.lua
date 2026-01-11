print("\nEXECUTOR DETECTED : "..identifyexecutor())
print((writefile and "✅ Support [WRITEFILE]" or "❌ Unsupport [WRITEFILE]"))
print((readfile and "✅ Support [READFILE]" or "❌ Unsupport [READFILE]"))
print((require and "✅ Support [REQUIRE]" or "❌ Unsupport [REQUIRE]"))

assert(isfolder and makefolder, "폴더를 생성할 수 없습니다")
if not isfolder("AircraftHud") then
    makefolder("AircraftHud")
end

if game.PlaceId ~= 20321167 then return end
if not game:IsLoaded() then game.Loaded:Wait() end

local function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end

local run = function(func)
    xpcall(func, function(err)
        warn(err)
    end)
end

local cloneref = missing("function", cloneref, function(...) return ... end)
local Services = setmetatable({}, {
    __index = function(self, name)
        self[name] = cloneref(game:GetService(name))
        return self[name]
    end
})

-- Services
local Players: Players = Services.Players
local RunService: RunService = Services.RunService
local UserInputService: UserInputService = Services.UserInputService
local ReplicatedStorage: ReplicatedStorage = Services.ReplicatedStorage

local Player: Player = Players.LocalPlayer
local Camera: Camera = workspace.CurrentCamera

-- Settings
local ToggleKey = Enum.KeyCode.RightControl
local HudColor = Color3.fromRGB(255, 255, 255)
local AccentColor = Color3.fromRGB(150, 150, 150)
local MaxSpeedMarkers = 2000
local MaxAltMarkers = 50000
local YawThreshold = 1.15
local YawSensitivity = 150
local ShowPlaneSymbol = false
local GPWS = true
local GPWSExcludeList = {}
local TooLow = false
local PullUp = false
local TerrainAhead = false
local SinkRatePullUp = false

local Connect = {
    connections = {}
}

function Connect.connect(event, callback)
    local conn = event:Connect(callback)
    table.insert(Connect.connections, conn)
    return conn
end

function Connect.disconnectAll()
    for _, conn in ipairs(Connect.connections) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    Connect.connections = {}
end

local Existing = Player.PlayerGui:FindFirstChild("AircraftHUD")
if Existing then
    Existing:Destroy()
end
local ExistingPart = workspace:FindFirstChild("AircraftSymbolPart")
if ExistingPart then
    ExistingPart:Destroy()
end
local ExistingSound1 = workspace:FindFirstChild("TerrainPullUpWarning")
if ExistingSound1 then
    ExistingSound1:Destroy()
end
local ExistingSound2 = workspace:FindFirstChild("TooLowTerrainWarning")
if ExistingSound2 then
    ExistingSound2:Destroy()
end
local ExistingSound3 = workspace:FindFirstChild("SinkRatePullUpWarning")
if ExistingSound3 then
    ExistingSound3:Destroy()
end

local Enabled = true
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local LastPosition = HumanoidRootPart.Position
local Velocity = Vector3.new(0, 0, 0)
local SmoothedSpeed = 0

local terrain_pullup = nil
local too_low_terrain = nil
local sinkrate_pullup = nil

run(function()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Model") and part.Name == "Runway" then
            table.insert(GPWSExcludeList, part)
        end
    end
end)

run(function()
    if not isfile("AircraftHud/terrain_pullup.mp3") then writefile("AircraftHud/terrain_pullup.mp3", tostring(game:HttpGetAsync("https://github.com/Ukrubojvo/api/raw/main/terrain-pull-up.mp3"))) end
    if not isfile("AircraftHud/sinkrate_pullup.mp3") then writefile("AircraftHud/sinkrate_pullup.mp3", tostring(game:HttpGetAsync("https://github.com/Ukrubojvo/api/raw/main/Sinkrate%20Pull%20Up.mp3"))) end
    terrain_pullup = Instance.new("Sound", workspace)
    terrain_pullup.Name = "TerrainPullUpWarning"
    terrain_pullup.SoundId = getcustomasset("AircraftHud/terrain_pullup.mp3")
    terrain_pullup.Volume = 2.5
    terrain_pullup.Looped = true

    too_low_terrain = Instance.new("Sound", workspace)
    too_low_terrain.Name = "TooLowTerrainWarning"
    too_low_terrain.SoundId = "rbxassetid://115757279674475"
    too_low_terrain.Volume = 2.5
    too_low_terrain.Looped = true

    sinkrate_pullup = Instance.new("Sound", workspace)
    sinkrate_pullup.Name = "SinkRatePullUpWarning"
    sinkrate_pullup.SoundId = getcustomasset("AircraftHud/sinkrate_pullup.mp3")
    sinkrate_pullup.Volume = 2.5
    sinkrate_pullup.Looped = true
end)

run(function()
    Connect.connect(Player.CharacterAdded, function(NewCharacter)
        Character = NewCharacter
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        LastPosition = HumanoidRootPart.Position
        SmoothedSpeed = 0
    end)

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "AircraftHUD"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.Parent = Player.PlayerGui

    local Root = Instance.new("Frame")
    Root.Size = UDim2.fromScale(1, 1)
    Root.BackgroundTransparency = 1
    Root.Visible = true
    Root.Parent = Gui

    local YawBar = Instance.new("Frame")
    YawBar.Name = "YawIndicator"
    YawBar.Size = UDim2.fromOffset(3, 40)
    YawBar.AnchorPoint = Vector2.new(0.5, 0.5)
    YawBar.Position = UDim2.fromScale(0.5, 0.5)
    YawBar.BackgroundColor3 = HudColor
    YawBar.BorderSizePixel = 0
    YawBar.Visible = false
    YawBar.Parent = Root

    local YawLabel = Instance.new("TextLabel")
    YawLabel.Size = UDim2.fromOffset(60, 20)
    YawLabel.Position = UDim2.fromOffset(-50, 45)
    YawLabel.BackgroundTransparency = 1
    YawLabel.TextColor3 = HudColor
    YawLabel.TextSize = 14
    YawLabel.Font = Enum.Font.GothamBold
    YawLabel.Text = "SLIP"
    YawLabel.Parent = YawBar
    -----------------------------------------------------------

    local PitchContainer = Instance.new("Frame")
    PitchContainer.Size = UDim2.fromScale(1, 1)
    PitchContainer.BackgroundTransparency = 1
    PitchContainer.Parent = Root

    local PitchLines = {}
    run(function()
        for i = -90, 90, 10 do
            if i ~= 0 then
                local Line = Instance.new("Frame")
                Line.Size = UDim2.fromOffset(i % 30 == 0 and 80 or 50, 2)
                Line.AnchorPoint = Vector2.new(0.5, 0.5)
                Line.BackgroundColor3 = i % 30 == 0 and HudColor or AccentColor
                Line.BorderSizePixel = 0
                Line.Parent = PitchContainer
                
                if i % 30 == 0 then
                    local LeftLabel = Instance.new("TextLabel")
                    LeftLabel.Size = UDim2.fromOffset(30, 16)
                    LeftLabel.Position = UDim2.fromOffset(-35, -8)
                    LeftLabel.BackgroundTransparency = 1
                    LeftLabel.Text = tostring(math.abs(i))
                    LeftLabel.TextColor3 = HudColor
                    LeftLabel.TextSize = 12
                    LeftLabel.Font = Enum.Font.GothamBold
                    LeftLabel.TextXAlignment = Enum.TextXAlignment.Right
                    LeftLabel.Parent = Line
                end
                
                PitchLines[i] = Line
            end
        end
    end)

    local HLeft = Instance.new("Frame")
    HLeft.Size = UDim2.fromOffset(160, 3)
    HLeft.AnchorPoint = Vector2.new(1, 0.5)
    HLeft.Position = UDim2.fromScale(0.5, 0.5)
    HLeft.BackgroundColor3 = AccentColor
    HLeft.BorderSizePixel = 0
    HLeft.Parent = Root

    local HRight = Instance.new("Frame")
    HRight.Size = UDim2.fromOffset(160, 3)
    HRight.AnchorPoint = Vector2.new(0, 0.5)
    HRight.Position = UDim2.fromScale(0.5, 0.5)
    HRight.BackgroundColor3 = AccentColor
    HRight.BorderSizePixel = 0
    HRight.Parent = Root

    local PitchLabel = Instance.new("TextLabel")
    PitchLabel.Size = UDim2.fromOffset(80, 20)
    PitchLabel.AnchorPoint = Vector2.new(1, 0.5)
    PitchLabel.Position = UDim2.fromScale(1, 0)
    PitchLabel.BackgroundTransparency = 0
    PitchLabel.BackgroundColor3 = AccentColor
    PitchLabel.TextColor3 = HudColor
    PitchLabel.TextSize = 14
    PitchLabel.Font = Enum.Font.GothamBold
    PitchLabel.Text = "Real Pitch"
    PitchLabel.Parent = HRight

    local PitchLabelCorner = Instance.new("UICorner")
    PitchLabelCorner.CornerRadius = UDim.new(0, 10)
    PitchLabelCorner.Parent = PitchLabel

    local AircraftSymbol = Instance.new("Frame")
    AircraftSymbol.Size = UDim2.fromOffset(80, 80)
    AircraftSymbol.AnchorPoint = Vector2.new(0.5, 0.5)
    AircraftSymbol.Position = UDim2.fromScale(0.5, 0.5)
    AircraftSymbol.BackgroundTransparency = 1
    AircraftSymbol.Parent = Gui

    local PlanePart = nil
    if ShowPlaneSymbol then
        PlanePart = Instance.new("Part")
        PlanePart.Name = "AircraftSymbolPart"
        PlanePart.Size = Vector3.new(1, 1, 0.1)
        PlanePart.Anchored = true
        PlanePart.CanCollide = false
        PlanePart.Transparency = 1
        PlanePart.CFrame = CFrame.new(0, 0, 0)
        PlanePart.CastShadow = false
        PlanePart.Parent = workspace

        local SurfaceGui = Instance.new("SurfaceGui")
        SurfaceGui.Face = Enum.NormalId.Back
        SurfaceGui.AlwaysOnTop = true
        SurfaceGui.LightInfluence = 0
        SurfaceGui.Brightness = 1
        SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        SurfaceGui.PixelsPerStud = 200
        SurfaceGui.Parent = PlanePart

        local PlaneImage = Instance.new("ImageLabel")
        PlaneImage.Size = UDim2.fromScale(1, 1)
        PlaneImage.Position = UDim2.fromScale(0.5, 0.5)
        PlaneImage.AnchorPoint = Vector2.new(0.5, 0.5)
        PlaneImage.BackgroundTransparency = 1
        PlaneImage.Image = "rbxassetid://77014659801653"
        PlaneImage.ImageColor3 = HudColor
        PlaneImage.ScaleType = Enum.ScaleType.Fit
        PlaneImage.Parent = SurfaceGui
        PlanePart.CFrame = PlanePart.CFrame * CFrame.Angles(math.rad(55), 0, 0)
    end

    local DotWidth = Instance.new("Frame")
    DotWidth.Size = UDim2.fromOffset(10, 2)
    DotWidth.AnchorPoint = Vector2.new(0.5, 0.5)
    DotWidth.Position = UDim2.fromScale(0.5, 0.5)
    DotWidth.BackgroundColor3 = HudColor
    DotWidth.BorderSizePixel = 0
    DotWidth.ZIndex = 2
    DotWidth.Parent = AircraftSymbol

    local DotWidthCorner = Instance.new("UICorner")
    DotWidthCorner.CornerRadius = UDim.new(1, 0)
    DotWidthCorner.Parent = DotWidth

    local DotHeight = Instance.new("Frame")
    DotHeight.Size = UDim2.fromOffset(2, 10)
    DotHeight.AnchorPoint = Vector2.new(0.5, 0.5)
    DotHeight.Position = UDim2.fromScale(0.5, 0.5)
    DotHeight.BackgroundColor3 = HudColor
    DotHeight.BorderSizePixel = 0
    DotHeight.ZIndex = 2
    DotHeight.Parent = AircraftSymbol

    local DotLabel = Instance.new("TextLabel")
    DotLabel.Size = UDim2.fromOffset(60, 20)
    DotLabel.AnchorPoint = Vector2.new(0.5, 0)
    DotLabel.Position = UDim2.fromScale(0, 1)
    DotLabel.BackgroundTransparency = 1
    DotLabel.TextColor3 = HudColor
    DotLabel.TextTransparency = 0.9
    DotLabel.TextSize = 14
    DotLabel.Font = Enum.Font.GothamBold
    DotLabel.Text = "Plane Pitch"
    DotLabel.Parent = DotHeight

    local DotHeightCorner = Instance.new("UICorner")
    DotHeightCorner.CornerRadius = UDim.new(1, 0)
    DotHeightCorner.Parent = DotHeight

    local SpeedTape = Instance.new("Frame")
    SpeedTape.Size = UDim2.fromOffset(80, 300)
    SpeedTape.AnchorPoint = Vector2.new(0, 0.5)
    SpeedTape.Position = UDim2.fromScale(0.02, 0.5)
    SpeedTape.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SpeedTape.BackgroundTransparency = 0.5
    SpeedTape.BorderSizePixel = 0
    SpeedTape.ClipsDescendants = true
    SpeedTape.Parent = Gui

    local SpeedTapeStroke = Instance.new("UIStroke")
    SpeedTapeStroke.Color = HudColor
    SpeedTapeStroke.Thickness = 2
    SpeedTapeStroke.Parent = SpeedTape

    local SpeedTapeCorner = Instance.new("UICorner")
    SpeedTapeCorner.CornerRadius = UDim.new(0, 12)
    SpeedTapeCorner.Parent = SpeedTape

    local SpeedScroll = Instance.new("Frame")
    SpeedScroll.Size = UDim2.fromOffset(80, MaxSpeedMarkers)
    SpeedScroll.Position = UDim2.fromOffset(0, 0)
    SpeedScroll.BackgroundTransparency = 1
    SpeedScroll.Parent = SpeedTape

    run(function()
        for i = 0, MaxSpeedMarkers, 10 do
            local Marker = Instance.new("Frame")
            Marker.Size = UDim2.fromOffset(i % 50 == 0 and 30 or 15, 2)
            Marker.AnchorPoint = Vector2.new(1, 0.5)
            Marker.Position = UDim2.fromOffset(75, -i)
            Marker.BackgroundColor3 = HudColor
            Marker.BorderSizePixel = 0
            Marker.Parent = SpeedScroll
            
            if i % 50 == 0 then
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.fromOffset(40, 20)
                Label.Position = UDim2.fromOffset(-45, -10)
                Label.BackgroundTransparency = 1
                Label.Text = tostring(i)
                Label.TextColor3 = HudColor
                Label.TextSize = 14
                Label.Font = Enum.Font.GothamBold
                Label.TextXAlignment = Enum.TextXAlignment.Right
                Label.Parent = Marker
            end
        end
    end)

    local SpeedReadout = Instance.new("Frame")
    SpeedReadout.Size = UDim2.fromOffset(70, 30)
    SpeedReadout.AnchorPoint = Vector2.new(0.5, 0.5)
    SpeedReadout.Position = UDim2.fromScale(0.5, 0.5)
    SpeedReadout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SpeedReadout.BackgroundTransparency = 0.2
    SpeedReadout.BorderSizePixel = 0
    SpeedReadout.Parent = SpeedTape

    local SpeedReadoutStroke = Instance.new("UIStroke")
    SpeedReadoutStroke.Color = AccentColor
    SpeedReadoutStroke.Thickness = 2
    SpeedReadoutStroke.Parent = SpeedReadout

    local SpeedReadoutCorner = Instance.new("UICorner")
    SpeedReadoutCorner.CornerRadius = UDim.new(0, 6)
    SpeedReadoutCorner.Parent = SpeedReadout

    local SpeedValue = Instance.new("TextLabel")
    SpeedValue.Size = UDim2.fromScale(1, 1)
    SpeedValue.BackgroundTransparency = 1
    SpeedValue.Text = " 0 >"
    SpeedValue.TextColor3 = HudColor
    SpeedValue.TextSize = 20
    SpeedValue.TextXAlignment = Enum.TextXAlignment.Left
    SpeedValue.Font = Enum.Font.GothamBold
    SpeedValue.Parent = SpeedReadout

    local AltTape = Instance.new("Frame")
    AltTape.Size = UDim2.fromOffset(80, 300)
    AltTape.AnchorPoint = Vector2.new(1, 0.5)
    AltTape.Position = UDim2.fromScale(0.98, 0.5)
    AltTape.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    AltTape.BackgroundTransparency = 0.5
    AltTape.BorderSizePixel = 0
    AltTape.ClipsDescendants = true
    AltTape.Parent = Gui

    local AltTapeStroke = Instance.new("UIStroke")
    AltTapeStroke.Color = HudColor
    AltTapeStroke.Thickness = 2
    AltTapeStroke.Parent = AltTape

    local AltTapeCorner = Instance.new("UICorner")
    AltTapeCorner.CornerRadius = UDim.new(0, 12)
    AltTapeCorner.Parent = AltTape

    local AltScroll = Instance.new("Frame")
    AltScroll.Size = UDim2.fromOffset(80, MaxAltMarkers)
    AltScroll.Position = UDim2.fromOffset(0, 0)
    AltScroll.BackgroundTransparency = 1
    AltScroll.Parent = AltTape

    run(function()
        for i = 0, MaxAltMarkers, 50 do
            local Marker = Instance.new("Frame")
            Marker.Size = UDim2.fromOffset(i % 250 == 0 and 30 or 15, 2)
            Marker.AnchorPoint = Vector2.new(0, 0.5)
            Marker.Position = UDim2.fromOffset(5, -i)
            Marker.BackgroundColor3 = HudColor
            Marker.BorderSizePixel = 0
            Marker.Parent = AltScroll
            
            if i % 250 == 0 then
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.fromOffset(40, 20)
                Label.Position = UDim2.fromOffset(35, -10)
                Label.BackgroundTransparency = 1
                Label.Text = tostring(i)
                Label.TextColor3 = HudColor
                Label.TextSize = 14
                Label.Font = Enum.Font.GothamBold
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Marker
            end
        end
    end)

    local AltReadout = Instance.new("Frame")
    AltReadout.Size = UDim2.fromOffset(70, 30)
    AltReadout.AnchorPoint = Vector2.new(0.5, 0.5)
    AltReadout.Position = UDim2.fromScale(0.5, 0.5)
    AltReadout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    AltReadout.BackgroundTransparency = 0.2
    AltReadout.BorderSizePixel = 0
    AltReadout.Parent = AltTape

    local AltReadoutStroke = Instance.new("UIStroke")
    AltReadoutStroke.Color = AccentColor
    AltReadoutStroke.Thickness = 2
    AltReadoutStroke.Parent = AltReadout

    local AltReadoutCorner = Instance.new("UICorner")
    AltReadoutCorner.CornerRadius = UDim.new(0, 6)
    AltReadoutCorner.Parent = AltReadout

    local AltValue = Instance.new("TextLabel")
    AltValue.Size = UDim2.fromScale(1, 1)
    AltValue.BackgroundTransparency = 1
    AltValue.Text = "< 0 "
    AltValue.TextColor3 = HudColor
    AltValue.TextSize = 20
    AltValue.TextXAlignment = Enum.TextXAlignment.Right
    AltValue.Font = Enum.Font.GothamBold
    AltValue.Parent = AltReadout

    run(function()
        Connect.connect(RunService.RenderStepped, function(dt)
            if not Gui or not Gui.Parent then
                Connect.disconnectAll()
                if PlanePart then
                    PlanePart:Destroy()
                end
                return
            end
            if not Enabled then 
                if PlanePart then
                    PlanePart.CFrame = CFrame.new(0, -1000, 0)
                end
                return 
            end
            
            if not Character or not Character.Parent then
                Character = Player.Character
                if Character then
                    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    LastPosition = HumanoidRootPart.Position
                else
                    return
                end
            end
            
            if not HumanoidRootPart or not HumanoidRootPart.Parent then return end
            local PlaneGui = Player.PlayerGui:FindFirstChild("PlaneGui")
            local Cf = Camera.CFrame
            local Pos = HumanoidRootPart.Position
            if PlanePart then
                local Distance = 10
                local PartCFrame = Cf * CFrame.new(0, 0, -Distance)
                PlanePart.CFrame = PartCFrame * CFrame.Angles(math.rad(-55), 0, 0)
            end

            local DeltaPos = Pos - LastPosition
            Velocity = DeltaPos / dt
            LastPosition = Pos

            --[[
            local CameraLook = Vector3.new(Cf.LookVector.X, 0, Cf.LookVector.Z).Unit
            local HorizontalVelocity = Vector3.new(Velocity.X, 0, Velocity.Z)
            local ForwardSpeed = HorizontalVelocity:Dot(CameraLook)
            local SpeedStuds = math.abs(ForwardSpeed)
            local SpeedKnots = SpeedStuds * 1.94384
            local SmoothFactor = 0.02

            SmoothedSpeed = SmoothedSpeed + (SpeedKnots - SmoothedSpeed) * SmoothFactor
            local AltitudeFeet = Pos.Y * 1.84
            SpeedValue.Text = string.format(" %d >", math.floor(SmoothedSpeed))
            SpeedScroll.Position = UDim2.fromOffset(0, 150 + SmoothedSpeed)
            
            AltValue.Text = string.format("< %d ", math.floor(AltitudeFeet))
            AltScroll.Position = UDim2.fromOffset(0, 150 + AltitudeFeet)
            ]]

            if PlaneGui then
                if not PlaneGui.Enabled then
                    SpeedValue.Text = " N/A >"
                    SpeedScroll.Position = UDim2.fromOffset(0, 150)
                    AltValue.Text = "< N/A "
                    AltScroll.Position = UDim2.fromOffset(0, 150)
                else
                    local OriginalSpeed = PlaneGui:FindFirstChild("Panel") and PlaneGui.Panel:FindFirstChild("Speed") and PlaneGui.Panel.Speed:FindFirstChild("Value") and tonumber(string.match(PlaneGui.Panel.Speed.Value.Text, "%d+")) or 0
                    local OriginalAlt = PlaneGui:FindFirstChild("Panel") and PlaneGui.Panel:FindFirstChild("Altitude") and PlaneGui.Panel.Altitude:FindFirstChild("Value") and tonumber(string.match(PlaneGui.Panel.Altitude.Value.Text, "%d+")) or 0
                    
                    SpeedValue.Text = string.format(" %s >", OriginalSpeed)
                    SpeedScroll.Position = UDim2.fromOffset(0, 150 + tonumber(OriginalSpeed))
                    AltValue.Text = string.format("< %s ", OriginalAlt)
                    AltScroll.Position = UDim2.fromOffset(0, 150 + tonumber(OriginalAlt))
                end
            end

            local RelativeVel = Cf:VectorToObjectSpace(Velocity)
            local YawAngle = 0
            if Velocity.Magnitude > 1 then
                YawAngle = math.deg(math.atan2(RelativeVel.X, -RelativeVel.Z))
            end

            if math.abs(YawAngle) >= YawThreshold then
                YawBar.Visible = true
                local xPos = math.clamp(0.5 + (YawAngle / YawSensitivity), 0.35, 0.65)
                YawBar.Position = UDim2.fromScale(xPos, 0.5)

                if YawAngle < 0 then
                    YawLabel.Position = UDim2.fromOffset(-50, 45)
                else
                    YawLabel.Position = UDim2.fromOffset(0, 45)
                end
            else
                YawBar.Visible = false
            end

            local Look = Cf.LookVector
            local Up = Cf.UpVector
            local Right = Cf.RightVector
            local Pitch = math.asin(math.clamp(Look.Y, -1, 1))
            local PitchDeg = math.deg(Pitch)
            local PitchOffset = -Pitch * 0.8
            local Roll = math.atan2(Right.Y, Up.Y)
            
            Root.Rotation = math.deg(Roll)
            HLeft.Position = UDim2.fromScale(0.5, 0.5 + PitchOffset)
            HRight.Position = UDim2.fromScale(0.5, 0.5 + PitchOffset)

            for angle, line in pairs(PitchLines) do
                local offset = (PitchDeg - angle) / 90 * 0.5
                line.Position = UDim2.fromScale(0.5, 0.5 + offset)
                line.Visible = math.abs(offset) < 0.45
            end

            if GPWS then
                if PlaneGui and PlaneGui.Enabled ~= true then
                    if terrain_pullup.IsPlaying then terrain_pullup:Stop() end
                    if too_low_terrain.IsPlaying then too_low_terrain:Stop() end
                    if sinkrate_pullup.IsPlaying then sinkrate_pullup:Stop() end
                    return
                end

                local RayParams = RaycastParams.new()
                RayParams.FilterType = Enum.RaycastFilterType.Exclude
                GPWSExcludeList = { Character }
                local AircraftFolder = workspace:FindFirstChild("Aircraft")
                if AircraftFolder then
                    table.insert(GPWSExcludeList, AircraftFolder)
                end
                RayParams.FilterDescendantsInstances = GPWSExcludeList

                local OriginalSpeed = PlaneGui and PlaneGui:FindFirstChild("Panel") and PlaneGui.Panel:FindFirstChild("Speed") and PlaneGui.Panel.Speed:FindFirstChild("Value") and tonumber(string.match(PlaneGui.Panel.Speed.Value.Text, "%d+")) or nil
                local HorizontalSpeed = Vector3.new(Velocity.X, 0, Velocity.Z).Magnitude
                local VerticalSpeedFPM = -Velocity.Y * 196.85
                local CurrentSpeedKTS = OriginalSpeed or (HorizontalSpeed * 0.6)

                local OriginalAlt = PlaneGui and PlaneGui:FindFirstChild("Panel") and PlaneGui.Panel:FindFirstChild("Altitude") and PlaneGui.Panel.Altitude:FindFirstChild("Value") and tonumber(string.match(PlaneGui.Panel.Altitude.Value.Text, "%d+")) or nil
                local DownRay = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -5000, 0), RayParams)
                local AGLFeet = OriginalAlt or (DownRay and (DownRay.Distance * 3.28) or 5000)
                local ScanDistance = math.clamp(HorizontalSpeed * 12, 1000, 6000)
                local ForwardRay = nil

                if CurrentSpeedKTS > 160 and AGLFeet < 3000 then
                    ForwardRay = workspace:Raycast(HumanoidRootPart.Position, HumanoidRootPart.CFrame.LookVector * ScanDistance, RayParams)
                end

                if ForwardRay then
                    local ForwardDist = ForwardRay.Distance * 3.28
                    local PullUpThreshold = math.clamp(CurrentSpeedKTS * 10, 1000, 8000)
                    if ForwardDist < (PullUpThreshold * 0.9) then
                        PullUp = true
                        TerrainAhead = true
                    elseif ForwardDist < (PullUpThreshold * 1.1) then
                        TooLow = true
                        TerrainAhead = true
                    end
                end

                local IsLanding = (AGLFeet < 500 and CurrentSpeedKTS < 160)

                if not IsLanding then
                else
                    if TerrainAhead and ForwardRay and (ForwardRay.Distance * 3.28 < 600) then
                        PullUp = true
                    else
                        PullUp = false
                        TooLow = false
                    end
                end

                local Look = Camera.CFrame.LookVector
                local PitchDeg = math.deg(math.asin(math.clamp(Look.Y, -1, 1)))
                if PullUp and PitchDeg > 5 and VerticalSpeedFPM < 3000 then
                    PullUp = false
                end

                if AGLFeet < 1250 and VerticalSpeedFPM > 7500 and not IsLanding then
                    SinkRatePullUp = true
                else
                    SinkRatePullUp = false
                end

                if CurrentSpeedKTS < 40 or VerticalSpeedFPM < -2500 then
                    PullUp = false
                    TooLow = false
                    SinkRatePullUp = false
                end

                if PullUp then
                    if not terrain_pullup.IsPlaying then terrain_pullup:Play() end
                    if too_low_terrain.IsPlaying then too_low_terrain:Stop() end
                elseif TooLow then
                    if not too_low_terrain.IsPlaying then too_low_terrain:Play() end
                    if terrain_pullup.IsPlaying then terrain_pullup:Stop() end
                else
                    if terrain_pullup.IsPlaying then terrain_pullup:Stop() end
                    if too_low_terrain.IsPlaying then too_low_terrain:Stop() end
                end

                if SinkRatePullUp then
                    if not sinkrate_pullup.IsPlaying then sinkrate_pullup:Play() end
                else
                    if sinkrate_pullup.IsPlaying then sinkrate_pullup:Stop() end
                end
            end
        end)
    end)

    run(function()
        Connect.connect(UserInputService.InputBegan, function(Input, Gp)
            if Gp then return end
            if Input.KeyCode == ToggleKey then
                Enabled = not Enabled
                Gui.Enabled = Enabled
            end
        end)
    end)
end)
