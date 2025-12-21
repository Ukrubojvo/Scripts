--!strict

print("\nEXECUTOR DETECTED : "..identifyexecutor())
print((hookfunction and "✅ Support [HOOKFUNCTION]" or "❌ Unsupport [HOOKFUNCTION]"))
print((hookmetamethod and "✅ Support [HOOKMETAMETHOD]" or "❌ Unsupport [HOOKMETAMETHOD]"))
print((writefile and "✅ Support [WRITEFILE]" or "❌ Unsupport [WRITEFILE]"))
print((readfile and "✅ Support [READFILE]" or "❌ Unsupport [READFILE]"))
print((getconnections and "✅ Support [GETCONNECTIONS]" or "❌ Unsupport [HOOKFUNCTION]"))
print((require and "✅ Support [REQUIRE]" or "❌ Unsupport [REQUIRE]"))
print((request and "✅ Support [REQUEST]" or "❌ Unsupport [REQUEST]"))

assert(isfolder and makefolder, "Unable to create folder")
local _xpcall, _pcall, _task, _math = xpcall, pcall, task, math
if not isfolder("AntiLua") then
    makefolder("AntiLua")
end

if game.PlaceId ~= 5470087938 then return end
if not game:IsLoaded() then game.Loaded:Wait() end

shared = shared
if not shared.AntiLuaLoading then
    shared.AntiLuaLoading = true
else
    return "Already Loaded"
end

local on_autoexec = false
local on_desyncset = false
if isfile("AntiLua/autoexec.bin") then
    local _, autoexec = _pcall(readfile, "AntiLua/autoexec.bin")
    if _ and autoexec == "0x00" then
        on_autoexec = true
        delfile("AntiLua/autoexec.bin")
    elseif _ and autoexec == "0x02" then
        on_desyncset = true
        delfile("AntiLua/autoexec.bin")
    end
end
if on_autoexec then shared.AntiLuaLoading = false return end

local function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end

local run = function(func)
    _xpcall(func, function(err)
        shared.AntiLuaLoading = false
        warn(err)
    end)
end

getgenv().InterfaceName = "AntiLuaGUI"
getgenv().SecureMode = true

local LoadedSystem = false
local Starlight = loadstring(game:HttpGetAsync("https://raw.nebulasoftworks.xyz/starlight"))()  
local NebulaIcons = loadstring(game:HttpGetAsync("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
local cloneref = missing("function", cloneref, function(...) return ... end)
local queueteleport = missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
local httprequest = missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))

local Services = setmetatable({}, {
    __index = function(self, name)
        self[name] = cloneref(game:GetService(name))
        return self[name]
    end
})

local Lighting = Services.Lighting
local RunService = Services.RunService
local HttpService = Services.HttpService
local UserInputService = Services.UserInputService
local TeleportService  = Services.TeleportService
local SoundService = Services.SoundService
local GroupService = Services.GroupService
local MarketplaceService = Services.MarketplaceService
local ReplicatedStorage = Services.ReplicatedStorage

local players = Services.Players
local lp = players.LocalPlayer
local cam = workspace.CurrentCamera
local executor = identifyexecutor()
local isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
local serversUrl = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
local AutoGun = false
local GunSelect = {"P1", "PK"}
local GunSpawned = false
local TimerConnection = nil
local NotificationsEnabled = false
local notify_sound = nil
local Connect = {
    connections = {}
}

local AntiLuaGUI = {}
local Draggable = {
    items = {}
}

local printcolor = {
    coloredMessages = {},
    processedLabels = {},
    config = {
        showTimestamp = false
    }
}

_task.spawn(function()
    if not isfile("AntiLua/notify.wav") then writefile("AntiLua/notify.wav", tostring(game:HttpGetAsync("https://github.com/Ukrubojvo/api/raw/main/notify.wav"))) end
    notify_sound = Instance.new("Sound", workspace)
    notify_sound.SoundId = getcustomasset("AntiLua/notify.wav")
    notify_sound.Volume = 1
    notify_sound.Looped = false
end)

function printcolor:getTimestamp()
    local time = os.date("*t")
    return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
end

function printcolor:print(text, color, options)
    options = options or {}
    local showTime = options.showTimestamp
    if showTime == nil then
        showTime = self.config.showTimestamp
    end
    
    local displayText = text
    if showTime then displayText = self:getTimestamp() .. " - " .. text end
    local uniqueID = "[#" .. HttpService:GenerateGUID(false):sub(1, 8) .. "#]"
    local markedText = displayText .. uniqueID
    print(markedText)
    
    local finalColor
    if typeof(color) == "Color3" then
        finalColor = color
    elseif type(color) == "string" then
        local hex = color:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16) / 255
            local g = tonumber(hex:sub(3,4), 16) / 255
            local b = tonumber(hex:sub(5,6), 16) / 255
            finalColor = Color3.new(r, g, b)
        else
            warn("Incorrect hex format. Please use the #RRGGBB format.")
            return
        end
    elseif type(color) == "table" and #color == 3 then
        finalColor = Color3.fromRGB(color[1], color[2], color[3])
    else
        warn("The colour must be specified as Color3, a hex string, or an RGB table.")
        return
    end
    
    local iconId = options.icon
    
    self.coloredMessages[uniqueID] = {
        originalText = displayText,
        markedText = markedText,
        color = finalColor,
        icon = iconId,
        timestamp = os.clock()
    }
    
    local currentTime = os.clock()
    for id, data in pairs(self.coloredMessages) do
        if currentTime - data.timestamp > 300 then
            self.coloredMessages[id] = nil
        end
    end
end

function printcolor:processLabel(label)
    if self.processedLabels[label] then return end
    
    local labelText = label.Text
    for uniqueID, messageData in pairs(self.coloredMessages) do
        if labelText:find(uniqueID, 1, true) then
            label.TextColor3 = messageData.color
            label.Text = messageData.originalText
            self.processedLabels[label] = true
            
            if messageData.icon then
                local parent = label.Parent
                if parent then
                    local iconLabel = parent:FindFirstChildOfClass("ImageLabel")
                    if iconLabel then
                        iconLabel.Image = messageData.icon
                    end
                end
            end
            
            break
        end
    end
end

function printcolor:applyColors(devConsole)
    for _, child in ipairs(devConsole:GetDescendants()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text ~= "" then
            self:processLabel(child)
        end
    end
end

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

function Draggable.make(frame)
    if not frame or Draggable.items[frame] then return end
    Draggable.items[frame] = {dragging = false}
    
    Connect.connect(frame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local info = Draggable.items[frame]
            info.dragging = true
            info.drag_start = input.Position
            info.start_pos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    info.dragging = false
                end
            end)
        end
    end)
    
    Connect.connect(frame.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local info = Draggable.items[frame]
            info.drag_input = input
        end
    end)
    
    Connect.connect(UserInputService.InputChanged, function(input)
        local info = Draggable.items[frame]
        if input == info.drag_input and info.dragging then
            local delta = input.Position - info.drag_start
            local new_x = info.start_pos.X.Offset + delta.X
            local new_y = info.start_pos.Y.Offset + delta.Y
            frame.Position = UDim2.new(info.start_pos.X.Scale, new_x, info.start_pos.Y.Scale, new_y)
        end
    end)
end

function Draggable.clear()
    for frame, info in pairs(Draggable.items) do
        info.dragging = false
        info.drag_start = nil
        info.start_pos = nil
        info.drag_input = nil
    end
    Draggable.items = {}
end

local function PrintInstanceTree(Instance, Indent)
    Indent = Indent or ""
    print(Indent .. Instance.Name .. " [" .. Instance.ClassName .. "]")
    for _, Child in ipairs(Instance:GetChildren()) do
        PrintInstanceTree(Child, Indent .. "  ")
    end
end

local function IsSelectedGun(Name)
    for _, Gun in ipairs(GunSelect) do
        if Gun == Name then
            return true
        end
    end
    return false
end

local function list_servers(cursor)
    local raw = game:HttpGet(serversUrl .. ((cursor and "&cursor=" .. cursor) or ""))
    return HttpService:JSONDecode(raw)
end

local function teleport(mode)
    if mode == "rejoin" then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
        return
    end
    if mode == "hop" then
        local server = nil
        local next_page = nil
        repeat
            local data = list_servers(next_page)
            if #data.data > 0 then
                server = data.data[_math.random(1, _math.max(1, _math.floor(#data.data / 3)))]
            end
            next_page = data.nextPageCursor
        until server

        if server and server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
        end
    end
end

run(function()
    _task.spawn(function()
        local CoreGui = Services.CoreGui
        local DevConsole = CoreGui:WaitForChild("DevConsoleMaster", 10)
        if not DevConsole then return end
        
        _task.wait(0.5)
        printcolor:applyColors(DevConsole)
        
        DevConsole.DescendantAdded:Connect(function(descendant)
            if (descendant:IsA("TextLabel") or descendant:IsA("TextButton")) and descendant.Text ~= "" then
                _task.wait(0.02)
                printcolor:processLabel(descendant)
            end
        end)
        
        while true do
            _task.wait(1)
            printcolor:applyColors(DevConsole)
        end
    end)
end)

run(function()
    AntiLuaGUI["1"] = Instance.new("ScreenGui", gethui() or Services.CoreGui);
    AntiLuaGUI["1"]["IgnoreGuiInset"] = true;
    AntiLuaGUI["1"]["DisplayOrder"] = 214748367;
    AntiLuaGUI["1"]["AutoLocalize"] = false;
    AntiLuaGUI["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
    AntiLuaGUI["1"]["Name"] = [[AntiLuaGUI]];
    AntiLuaGUI["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
    AntiLuaGUI["1"]["ResetOnSpawn"] = false;

    if isMobile then
        AntiLuaGUI["2"] = Instance.new("TextButton", AntiLuaGUI["1"]);
        AntiLuaGUI["2"]["BorderSizePixel"] = 0;
        AntiLuaGUI["2"]["TextSize"] = 24;
        AntiLuaGUI["2"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
        AntiLuaGUI["2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        AntiLuaGUI["2"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
        AntiLuaGUI["2"]["AnchorPoint"] = Vector2.new(1, 0);
        AntiLuaGUI["2"]["BackgroundTransparency"] = 0.2;
        AntiLuaGUI["2"]["Active"] = true
        AntiLuaGUI["2"]["Selectable"] = true
        AntiLuaGUI["2"]["Size"] = UDim2.new(0, 117, 0, 42);
        AntiLuaGUI["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
        AntiLuaGUI["2"]["Text"] = [[]];
        AntiLuaGUI["2"]["Name"] = [[Toggle]];
        AntiLuaGUI["2"]["Position"] = UDim2.new(1, 0, 0.64367, 0);

        AntiLuaGUI["3"] = Instance.new("UIStroke", AntiLuaGUI["2"]);
        AntiLuaGUI["3"]["Transparency"] = 0.5;
        AntiLuaGUI["3"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
        AntiLuaGUI["3"]["Thickness"] = 2;

        AntiLuaGUI["4"] = Instance.new("UIGradient", AntiLuaGUI["2"]);
        AntiLuaGUI["4"]["Rotation"] = 30;
        AntiLuaGUI["4"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(25, 29, 21)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(175, 215, 208))};

        AntiLuaGUI["5"] = Instance.new("UICorner", AntiLuaGUI["2"]);

        AntiLuaGUI["6"] = Instance.new("TextLabel", AntiLuaGUI["2"]);
        AntiLuaGUI["6"]["BorderSizePixel"] = 0;
        AntiLuaGUI["6"]["TextSize"] = 20;
        AntiLuaGUI["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
        AntiLuaGUI["6"]["FontFace"] = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
        AntiLuaGUI["6"]["TextColor3"] = Color3.fromRGB(232, 243, 240);
        AntiLuaGUI["6"]["Interactable"] = false
        AntiLuaGUI["6"]["BackgroundTransparency"] = 1;
        AntiLuaGUI["6"]["Size"] = UDim2.new(1, 0, 1, 0);
        AntiLuaGUI["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
        AntiLuaGUI["6"]["Text"] = [[Anti Lua]];
    end

    AntiLuaGUI["7"] = Instance.new("Frame", AntiLuaGUI["1"]);
    AntiLuaGUI["7"]["BorderSizePixel"] = 0;
    AntiLuaGUI["7"]["BackgroundColor3"] = Color3.fromRGB(35, 37, 44);
    AntiLuaGUI["7"]["AnchorPoint"] = Vector2.new(0, 0.5);
    AntiLuaGUI["7"]["Size"] = UDim2.new(0, 155, 0, 61);
    AntiLuaGUI["7"]["Position"] = UDim2.new(0.127, 0, 0.5, 0);
    AntiLuaGUI["7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    AntiLuaGUI["7"]["Active"] = true
    AntiLuaGUI["7"]["Selectable"] = true
    AntiLuaGUI["7"]["Visible"] = false
    AntiLuaGUI["7"]["Name"] = [[Watermark]];

    AntiLuaGUI["7_1"] = Instance.new("UIStroke", AntiLuaGUI["7"]);
    AntiLuaGUI["7_1"]["Transparency"] = 0.5;
    AntiLuaGUI["7_1"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
    AntiLuaGUI["7_1"]["Thickness"] = 2;

    AntiLuaGUI["8"] = Instance.new("UICorner", AntiLuaGUI["7"]);

    AntiLuaGUI["9"] = Instance.new("Frame", AntiLuaGUI["7"]);
    AntiLuaGUI["9"]["BorderSizePixel"] = 0;
    AntiLuaGUI["9"]["BackgroundColor3"] = Color3.fromRGB(58, 63, 71);
    AntiLuaGUI["9"]["Size"] = UDim2.new(0, 155, 0, 2);
    AntiLuaGUI["9"]["Position"] = UDim2.new(0, 0, 0.39394, 0);
    AntiLuaGUI["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);

    AntiLuaGUI["a"] = Instance.new("TextLabel", AntiLuaGUI["7"]);
    AntiLuaGUI["a"]["TextWrapped"] = true;
    AntiLuaGUI["a"]["ZIndex"] = 5;
    AntiLuaGUI["a"]["BorderSizePixel"] = 0;
    AntiLuaGUI["a"]["TextSize"] = 14;
    AntiLuaGUI["a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
    AntiLuaGUI["a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    AntiLuaGUI["a"]["FontFace"] = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
    AntiLuaGUI["a"]["TextColor3"] = Color3.fromRGB(246, 240, 231);
    AntiLuaGUI["a"]["BackgroundTransparency"] = 1;
    AntiLuaGUI["a"]["Size"] = UDim2.new(0, 139, 0, 24);
    AntiLuaGUI["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    AntiLuaGUI["a"]["Text"] = [[AntiLua]];
    AntiLuaGUI["a"]["Position"] = UDim2.new(0.0479, 0, 0, 0);

    AntiLuaGUI["b"] = Instance.new("TextLabel", AntiLuaGUI["7"]);
    AntiLuaGUI["b"]["ZIndex"] = 5;
    AntiLuaGUI["b"]["BorderSizePixel"] = 0;
    AntiLuaGUI["b"]["TextSize"] = 14;
    AntiLuaGUI["b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
    AntiLuaGUI["b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    AntiLuaGUI["b"]["FontFace"] = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    AntiLuaGUI["b"]["TextColor3"] = Color3.fromRGB(255, 254, 247);
    AntiLuaGUI["b"]["BackgroundTransparency"] = 1;
    AntiLuaGUI["b"]["Size"] = UDim2.new(0, 66, 0, 35);
    AntiLuaGUI["b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    AntiLuaGUI["b"]["Text"] = [[FPS: 999]];
    AntiLuaGUI["b"]["Name"] = [[FPS]];
    AntiLuaGUI["b"]["Position"] = UDim2.new(0.0479, 0, 0.42424, 0);

    AntiLuaGUI["c"] = Instance.new("TextLabel", AntiLuaGUI["7"]);
    AntiLuaGUI["c"]["ZIndex"] = 5;
    AntiLuaGUI["c"]["BorderSizePixel"] = 0;
    AntiLuaGUI["c"]["TextSize"] = 14;
    AntiLuaGUI["c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
    AntiLuaGUI["c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    AntiLuaGUI["c"]["FontFace"] = Font.new([[rbxassetid://12187365364]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    AntiLuaGUI["c"]["TextColor3"] = Color3.fromRGB(255, 254, 247);
    AntiLuaGUI["c"]["BackgroundTransparency"] = 1;
    AntiLuaGUI["c"]["Size"] = UDim2.new(0, 65, 0, 35);
    AntiLuaGUI["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    AntiLuaGUI["c"]["Text"] = [[PING: 1ms]];
    AntiLuaGUI["c"]["Name"] = [[Ping]];
    AntiLuaGUI["c"]["Position"] = UDim2.new(0.52096, 0, 0.42424, 0);

    Draggable.make(AntiLuaGUI["2"])
    Draggable.make(AntiLuaGUI["7"])

    local cooldown = false
    if isMobile then
        Connect.connect(AntiLuaGUI["2"].MouseButton1Up, function()
            if not cooldown then
                cooldown = true
                Starlight.Minimized = not Starlight.Minimized
                _task.wait(0.5)
                cooldown = false
            end
        end)
    end

    AntiLuaGUI["l"] = tick()
    AntiLuaGUI["fps"] = 0
    AntiLuaGUI["FPS"] = RunService.PreRender:Connect(function()
        local s = tick()
        local d = s - AntiLuaGUI["l"]
        AntiLuaGUI["l"] = s
        if d > 0 then
            AntiLuaGUI["fps"] = 1/ d
        end
        AntiLuaGUI["c"].Text = tostring(_math.floor(lp:GetNetworkPing()*1000)).."ms"
        AntiLuaGUI["b"].Text = "FPS: "..tostring(_math.floor(AntiLuaGUI["fps"]))
    end)
end)

run(function()
    Starlight.WindowKeybind = "RightControl"
    local Window = Starlight:CreateWindow({
        Name = "AntiLua",
        Subtitle = "v1.0.0",
        Icon = 84785726693204,

        LoadingEnabled = true,
        LoadingSettings = {
            Title = "운테르 놀이터",
            Subtitle = "Powered by .antilua.",
            Logo = 84785726693204,
        },

        FileSettings = {
            ConfigFolder = "AntiLua"
        },
    })

    local MainTabSection = Window:CreateTabSection("Home")

    local MainTab = MainTabSection:CreateTab({
        Name = "Main",
        Icon = NebulaIcons:GetIcon('view_in_ar', 'Material'),
        Columns = 2,
    }, "INDEX")

    local AFGroup = MainTab:CreateGroupbox({
        Name = "Auto Farms",
        Column = 1,
    }, "INDEX")

    local OtherGroup = MainTab:CreateGroupbox({
        Name = "Other Section",
        Column = 2,
    }, "INDEX")

    local TeleportTab = MainTabSection:CreateTab({
        Name = "Teleport",
        Icon = NebulaIcons:GetIcon('view_in_ar', 'Material'),
        Columns = 1,
    }, "INDEX")

    local TeleportGroup = TeleportTab:CreateGroupbox({
        Name = "Teleport Section",
        Column = 1,
    }, "INDEX")

    local AutoGunGet = AFGroup:CreateToggle({
        Name = "Auto Gun Get",
        CurrentValue = false,
        Style = 2,
        Callback = function(Value)
            if not LoadedSystem then return end
            AutoGun = Value
            if AutoGun then
                for _, chill in pairs(workspace.ToolsInWorkspace:GetChildren()) do
                    if IsSelectedGun(chill.Name) then
                        --PrintInstanceTree(chill)
                        local Handle = chill:FindFirstChild("Handle")
                        if Handle and Handle:IsA("BasePart") then
                            firetouchinterest(lp.Character.HumanoidRootPart, Handle, 0)
                        end
                    end
                end
            end
        end,
    }, "INDEX")

    local Label = AFGroup:CreateLabel({
        Name = "Auto Farm"
    }, "INDEX")

    local GunSelectDropdown = Label:AddDropdown({
        Name = "Gun Select",
        Options = {"P1", "PK"},
        MultipleOptions = true,
        CurrentOption = {"P1", "PK"},
        Callback = function(Option)
            if not LoadedSystem then return end
            GunSelect = Option
        end,
    }, "INDEX")

    local Timer = OtherGroup:CreateToggle({
        Name = "Timer ESP",
        CurrentValue = false,
        Style = 2,
        Callback = function(Value)
            if not LoadedSystem then return end

            local Armory = workspace.Zones.Zone2020.Buildings.Armory
            local IndicatorPart = Armory.Indicator.IndicatorPart
            local SourceLabel = IndicatorPart.TimeLeft.TextLabel

            local BillboardGui = Armory:FindFirstChild("AntiLuaTimer")
            if not BillboardGui then
                BillboardGui = Instance.new("BillboardGui")
                BillboardGui.Name = "AntiLuaTimer"
                BillboardGui.Adornee = IndicatorPart
                BillboardGui.Size = UDim2.fromScale(25, 7)
                BillboardGui.StudsOffset = Vector3.new(0, 20, 0)
                BillboardGui.AlwaysOnTop = true
                BillboardGui.Enabled = false
                BillboardGui.Parent = Armory

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Size = UDim2.fromScale(1, 1)
                TextLabel.BackgroundTransparency = 1
                TextLabel.TextScaled = true
                TextLabel.Font = Enum.Font.GothamBold
                TextLabel.TextStrokeTransparency = 0
                TextLabel.Parent = BillboardGui
            end

            local TargetLabel = BillboardGui:FindFirstChildWhichIsA("TextLabel")
            BillboardGui.Enabled = Value

            if TimerConnection then
                TimerConnection:Disconnect()
                TimerConnection = nil
            end

            if Value then
                TimerConnection = RunService.RenderStepped:Connect(function()
                    if not TargetLabel then return end

                    if IndicatorPart.Color == Color3.fromRGB(105, 255, 105) then
                        TargetLabel.Text = "[ Get Gun ]"
                        TargetLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
                        return
                    end

                    local Time = tonumber(SourceLabel.Text)
                    if not Time then return end

                    local Alpha = math.clamp(Time / 45, 0, 1)

                    local Green = Color3.fromRGB(105, 255, 105)
                    local Red = Color3.fromRGB(255, 98, 98)

                    TargetLabel.TextColor3 = Red:Lerp(Green, Alpha)

                    TargetLabel.Text = `[ {Time}s ]`
                end)
            end
        end,
    }, "INDEX")

    local Notify = OtherGroup:CreateToggle({
        Name = "Notifications",
        CurrentValue = false,
        Style = 2,
        Callback = function(Value)
            if not LoadedSystem then return end
            NotificationsEnabled = Value
        end,
    }, "INDEX")

    local antifling = nil
    local AntiFling = OtherGroup:CreateToggle({
        Name = "AntiFling",
        CurrentValue = false,
        Style = 2,
        Callback = function(Value)
            if not LoadedSystem then return end
            if antifling and not Value then
                antifling:Disconnect()
                antifling = nil
                return
            end
            antifling = RunService.Stepped:Connect(function()
                for _, player in pairs(players:GetPlayers()) do
                    if player ~= lp and player.Character then
                        for _, v in pairs(player.Character:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    }, "INDEX")

    local RejoinButton = TeleportGroup:CreateButton({
        Name = "Rejoin",
        Icon = NebulaIcons:GetIcon('user', 'Lucide'),
        Style = 1   ,
        Callback = function()
            if AntiLuaGUI then AntiLuaGUI["1"]:Destroy() end
            DebrisConnect = false
            Connect.disconnectAll()
            _task.wait(1)
            teleport('rejoin')
        end,
    }, "INDEX")

    local ServerHopButton = TeleportGroup:CreateButton({
        Name = "Server Hop",
        Icon = NebulaIcons:GetIcon('rabbit', 'Lucide'),
        Style = 1,
        Callback = function()
            if AntiLuaGUI then AntiLuaGUI["1"]:Destroy() end
            DebrisConnect = false
            Connect.disconnectAll()
            _task.wait(1)
            teleport('hop')
        end,
    }, "INDEX")

    run(function()
        local PlayerTab = MainTabSection:CreateTab({
            Name = "LocalPlayer",
            Icon = NebulaIcons:GetIcon('view_in_ar', 'Material'),
            Columns = 2,
        }, "INDEX")

        local Groupbox = PlayerTab:CreateGroupbox({
            Name = "Section",
            Column = 1,
        }, "INDEX")

        local player = lp
        --fly
        local CONTROL = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
        local flyConnection, inputBeganConnection, inputEndedConnection
        local SPEED = 50
        --noclip
        local noclipConnection
        local originalCollisions = {}
        --speed
        local SpeedBoostValue = 1
        local SpeedBoostStatus = false

        local SpeedSlider = Groupbox:CreateSlider({
            Name = "Speed Boost Value",
            Icon = NebulaIcons:GetIcon('chart-no-axes-column-increasing', 'Lucide'),
            Range = {0, 100},
            Increment = 1,
            CurrentValue = 1,
            Callback = function(Value)
                SpeedBoostValue = Value
            end,
        }, "INDEX")

        local SpeedBoost = Groupbox:CreateToggle({
            Name = "Speed Boost",
            CurrentValue = false,
            Style = 2,
            Callback = function(state)
                if not LoadedSystem then return end
                SpeedBoostStatus = state
                if state then
                    _task.spawn(function()
                        while SpeedBoostStatus do
                            local char = lp.Character or lp.CharacterAdded:Wait()
                            local humanoid = char:WaitForChild("Humanoid")
                            if humanoid and humanoid.Parent then
                                local delta = RunService.Heartbeat:Wait()
                                if humanoid.MoveDirection.Magnitude > 0 then
                                    char:TranslateBy(humanoid.MoveDirection * SpeedBoostValue * delta * 10)
                                end
                            end
                            _task.wait()
                        end
                    end)
                end
            end,
        }, "INDEX")

        local FlySpeedSlider = Groupbox:CreateSlider({
            Name = "Fly Speed",
            Icon = NebulaIcons:GetIcon('speed', 'Material'),
            Range = {10, 300},
            Increment = 5,
            CurrentValue = SPEED,
            Callback = function(Value)
                SPEED = Value
            end,
        }, "INDEX")

        local Fly = Groupbox:CreateToggle({
            Name = "Fly",
            CurrentValue = false,
            Style = 2,
            Callback = function(state)
                if not LoadedSystem then return end
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")
                if state then
                    inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if gameProcessed then return end
                        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1
                        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1
                        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1
                        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1
                        elseif input.KeyCode == Enum.KeyCode.Space then CONTROL.U = 1
                        elseif input.KeyCode == Enum.KeyCode.LeftShift then CONTROL.D = -1
                        end
                    end)

                    inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
                        elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
                        elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
                        elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
                        elseif input.KeyCode == Enum.KeyCode.Space then CONTROL.U = 0
                        elseif input.KeyCode == Enum.KeyCode.LeftShift then CONTROL.D = 0
                        end
                    end)

                    flyConnection = RunService.RenderStepped:Connect(function(dt)
                        if not character or not root then return end
                        local cf = cam.CFrame
                        local move = Vector3.new(0, 0, 0)
                        move = move + cf.LookVector * (CONTROL.F + CONTROL.B)
                        move = move + cf.RightVector * (CONTROL.R + CONTROL.L)
                        move = move + cf.UpVector * (CONTROL.U + CONTROL.D)

                        if move.Magnitude > 0 then
                            local moveDir = move.Unit * SPEED * dt
                            root.CFrame = CFrame.new(root.Position + moveDir, root.Position + moveDir + cf.LookVector)
                        end

                        root.AssemblyLinearVelocity = Vector3.zero
                    end)
                else
                    if flyConnection then flyConnection:Disconnect() end
                    if inputBeganConnection then inputBeganConnection:Disconnect() end
                    if inputEndedConnection then inputEndedConnection:Disconnect() end
                    CONTROL = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
                end
            end,
        }, "INDEX")

        local Noclip = Groupbox:CreateToggle({
            Name = "Noclip",
            CurrentValue = false,
            Style = 2,
            Callback = function(state)
                if not LoadedSystem then return end
                local character = player.Character or player.CharacterAdded:Wait()
                local root = character:WaitForChild("HumanoidRootPart")
                if state then
                    local function NoclipLoop()
                        if state and player.Character then
                            for _, child in pairs(player.Character:GetDescendants()) do
                                if child:IsA("BasePart") and child.CanCollide then
                                    originalCollisions[child] = child.CanCollide
                                    child.CanCollide = false
                                end
                            end
                        end
                    end
                    NoclipLoop()
                    noclipConnection = RunService.Stepped:Connect(NoclipLoop)
                else
                    if noclipConnection then
                        noclipConnection:Disconnect()
                    end
                    for part, canCollide in pairs(originalCollisions) do
                        if part.Parent then
                            part.CanCollide = canCollide
                        end
                    end
                    originalCollisions = {}
                end
            end,
        }, "INDEX")
    end)


    Starlight:OnDestroy(function()
        shared.AntiLuaLoading = false
        shared.AntiLuaLoader = false
        if AntiLuaGUI then AntiLuaGUI["1"]:Destroy() end
        DebrisConnect = false
        Connect.disconnectAll()
        _pcall(function()
            Services.CoreGui:FindFirstChild("RobloxNetworkPauseNotification").Enabled = true
        end)
        if antifling then
            antifling:Disconnect()
            antifling = nil
        end
        if TimerConnection then
            TimerConnection:Disconnect()
            TimerConnection = nil
        end
        local Armory = workspace.Zones.Zone2020.Buildings.Armory
        local BillboardGui = Armory:FindFirstChild("AntiLuaTimer")
        if BillboardGui then
            BillboardGui:Destroy()
        end
    end)

    Starlight:LoadAutoloadConfig()
end)

run(function()
    _xpcall(function()
        Services.CoreGui:FindFirstChild("RobloxNetworkPauseNotification").Enabled = false
    end, function(err)
        warn(err)
    end)
    Connect.connect(workspace.ToolsInWorkspace.ChildAdded, function(Tool)
        if not AutoGun then return end
        if Tool.Name == "P1" or Tool.Name == "PK" then
            GunSpawned = true
            if NotificationsEnabled then
                notify_sound:Play()
                Starlight:Notification({
                    Title = "AntiLua",
                    Content = `Gun has spawned: {Tool.Name}`,
                    Duration = 10,
                    Icon = NebulaIcons:GetIcon('bell', 'Lucide'),
                })
            end
        end
        if not IsSelectedGun(Tool.Name) then return end
        --PrintInstanceTree(Tool)
        local Handle = Tool:FindFirstChild("Handle")
        if Handle and Handle:IsA("BasePart") then
            firetouchinterest(lp.Character.HumanoidRootPart, Handle, 0)
        end
    end)
    --[[
    Connect.connect(RunService.RenderStepped, function()
        if not AutoGun then return end
        for _, chill in pairs(workspace.ToolsInWorkspace:GetChildren()) do
            if IsSelectedGun(chill.Name) then
                --PrintInstanceTree(chill)
                local Handle = chill:FindFirstChild("Handle")
                if Handle and Handle:IsA("BasePart") then
                    firetouchinterest(lp.Character.HumanoidRootPart, Handle, 0)
                end
            end
        end
    end)
    ]]

    for _, chill in pairs(workspace.ToolsInWorkspace:GetChildren()) do
        if chill.Name == "P1" or chill.Name == "PK" then
            --PrintInstanceTree(chill)
            local Handle = chill:FindFirstChild("Handle")
            if Handle and Handle:IsA("BasePart") then
                firetouchinterest(lp.Character.HumanoidRootPart, Handle, 0)
            end
        end
    end
end)

LoadedSystem = true
