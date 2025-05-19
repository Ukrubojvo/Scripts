local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Players = game.Players
local lplr = Players.LocalPlayer
local ReplicatedStorage = game.ReplicatedStorage
local RunService = game:GetService("RunService")
local Mouse = lplr:GetMouse()
local Options = Fluent.Options
local envts = {}
local runs 
local rp = Players:GetPlayers()[math.random(1 , #Players:GetPlayers())]
---------------------------//기본변수//---------------------------
local Them = "Darker"
local Version = "1.4.0"
local carbontab = nil
local ACS7tab = nil
local ACS2tab = nil
local BabbabTab = nil
local Place = nil
local taebtab = nil
local Add = nil
local ac = nil
local whansungtab = nil
local Baekhotab = nil
-----------------------------------------------------------------
local function acskil(plr)
	local Event = ReplicatedStorage.ACS_Engine.Events.AcessId

	local key = Event:InvokeServer(Players.LocalPlayer.UserId) .. "-" .. tostring(Players.LocalPlayer.UserId)

	Event = ReplicatedStorage.ACS_Engine.Events.Damage 

	local gun = game:FindFirstChild("ACS_Settings" , true).Parent
	local module = require(gun.ACS_Settings)
	Event:InvokeServer(gun, plr.Character.Humanoid, 25, 1, module, { minDamageMod=150, DamageMod=150 }, nil, nil, key)
end
local function baekhokill(plr)
	ReplicatedStorage.Soru:FireServer(rp , plr ,{['MinDamageMod'] = math.huge} , {['Name'] = "Head"})
end
local function aacskil(plr)
	ReplicatedStorage.ACS_Engine.Eventos.Damage:FireServer(plr.Character.Humanoid, math.huge, 0, 0)
end
local function acsgod(plr)
	ReplicatedStorage.ACS_Engine.Eventos.Damage:FireServer(game.Players.LocalPlayer.Character.Humanoid, - math.huge, 0, 0)
end
pcall(function()
	local placeId = game.PlaceId
	local placeInfo = game:GetService("MarketplaceService"):GetProductInfo(placeId)
	Place = placeInfo.Name
end)
local function gnoti(str)	
	Fluent:Notify({
		Title = "SYTIC HUB",
		Content = str,
		SubContent = "good signal", -- Optional
		Duration = 5 
	})
end
local function bnoti(str)
	Fluent:Notify({
		Title = "SYTIC HUB",
		Content = str,
		SubContent = "bad signal", 
		Duration = 5 
	})
end
local function findgun()
	if game.PlaceId == 9812972023 then return "밥밥부대"; end
	if game.PlaceId == 102005983028042 then return "완성재단"; end
	if game.PlaceId == 13785298879 then return "태비부대"; end
	if game.PlaceId == 17879852615 then return "백호산부대"; end

	local ACS = ReplicatedStorage:FindFirstChild("ACS_Engine")
	if ACS then
		if ACS:FindFirstChild("Eventos") then
			return "1.7.5"
		else
			return "2.0.1"
		end 
	else
		local carbon = ReplicatedStorage:FindFirstChild("CarbonResource")
		if carbon then
			return "carbonEngine"
		else
			return "Nofind"
		end    
	end
end

local function whangsungExecute(str)
	ReplicatedStorage:WaitForChild('안티치트'):FireServer(str)
end

local Window = Fluent:CreateWindow({
	Title = "SYTICE HUB " .. Version,
	SubTitle = "by sytic",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
	Theme = Them,
	MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local function loadbaekho()
if Baekhotab == nil  then
		Baekhotab = Window:AddTab({ Title = "백호산부대 [Zegun]", Icon = "locate" })
		local aSection = Baekhotab:AddSection("모든 플레이어 킬")
		Baekhotab:AddButton({
			Title = "킬올",
			Description = "서버에 있는 모든플레이어를 죽입니다",
			Callback = function()
				rp = Players:GetPlayers()[math.random(1 , #Players:GetPlayers())]
				for i ,v in pairs(Players:GetPlayers()) do
					baekhokill(v)				
				end
			end
		})
else
		bnoti("백호산 탭은 이미 생성되어 있습니다.")
end
end
local function loadWhansung()
	if whansungtab == nil then

		whansungtab = Window:AddTab({ Title = "완성재단 [CE]", Icon = "locate" })
		local aSection = whansungtab:AddSection("모든 플레이어 킬")
		whansungtab:AddButton({
			Title = "킬올",
			Description = "서버에 있는 모든플레이어를 죽입니다",
			Callback = function()
				whangsungExecute('killall')
			end
		})
		local a = 2
		local aSection = whansungtab:AddSection("서버 폭발")
		local Slider = whansungtab:AddSlider("Slider", 
			{
				Title = "핑핵 파워",
				Description = "Server Ping Power",
				Default = 2,
				Min = 0,
				Max = 100,
				Rounding = 1,
				Callback = function(Value)
					a = Value
				end
			})

		Slider:OnChanged(function(Value)
			a = Value			
		end)
		local Toggle = whansungtab:AddToggle("핑핵 실행", 
			{
				Title = "핑핵", 
				Description = "토글을 키면 핑핵이실행됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						local ev = ReplicatedStorage.ACS_Engine.Events.Equip
						runs = game['Run Service'].RenderStepped:Connect(function ()
							for i = 1 , a do	
								ev:FireServer({["Name"] = ReplicatedStorage.ACS_Engine.GunModels:FindFirstChildOfClass("Model").Name} , 11)
							end
						end) 
					else
						if runs then
							runs:Disconnect()
							print("핑핵 종료")	
						end
					end
				end 
			})
		local aSection = whansungtab:AddSection("올킥")
		whansungtab:AddButton({
			Title = "킥올",
			Description = "서버에 있는 모든플레이어를 강제퇴장시킵니다",
			Callback = function()
				whangsungExecute('kickall')
			end
		})

		local aSection = whansungtab:AddSection("맵 지우기")
		whansungtab:AddButton({
			Title = "맵 전부다 지우기",
			Description = "맵을 전부다 지웁니다.",
			Callback = function()
				whangsungExecute('deletemap')
			end
		})
		local aSection = whansungtab:AddSection("HD Admin")
		whansungtab:AddButton({
			Title = "HD Admin 오너",
			Description = "HD Admin 오너랭크를 얻습니다",
			Callback = function()
				whangsungExecute('hdowner')
			end
		})
	else
		bnoti("완성재단 탭은 이미 생성되어 있습니다.")
	end
end

local function carbonA()
	if carbontab == nil then
		carbontab = Window:AddTab({ Title = "카본엔진 [CE]", Icon = "locate" })
		local aSection = carbontab:AddSection("이벤트 경로체크")

		local CResource = ReplicatedStorage:FindFirstChild("CarbonResource")
		carbontab:AddButton({
			Title = "이벤트 경로체크",
			Description = "카본엔진의 이벤트 경로를 체크합니다",
			Callback = function()
				envts = {}
				lplr.Character.Humanoid.Health = 0
				task.wait(0.3)
				for u, e in pairs(CResource.Events:GetChildren()) do
					envts[e.Name] = e
				end

			end
		})
		local aSection = carbontab:AddSection("모든 플레이어 킬")
		carbontab:AddButton({
			Title = "킬올",
			Description = "서버에 있는 모든플레이어를 죽입니다",
			Callback = function()
				for idx, plr in pairs(Players:GetPlayers()) do
					envts["DamageEvent"]:FireServer(plr.Character:FindFirstChild("Humanoid"), 100000, "Torso", {'nil','Auth','nil','nil'})
				end
			end
		})
		carbontab:AddButton({
			Title = "폭발 올",
			Description = "서버에 있는 모든플레이어를 폭발시킵니다",
			Callback = function()
				for idx, plr in pairs(Players:GetPlayers()) do
					envts["ExplosiveEvent"]:FireServer(nil, plr.Character:GetPivot().Position, 50000, 10, 10, nil, nil, nil, nil, nil, nil,nil, "Auth")
				end
			end
		})
		local aSection = carbontab:AddSection("서버 폭발")
		local Slider = carbontab:AddSlider("Slider", 
			{
				Title = "핑핵 파워",
				Description = "Server Ping Power",
				Default = 2,
				Min = 0,
				Max = 100,
				Rounding = 1,
				Callback = function(Value)
					getfenv().carbonPinghackPower = Value
				end
			})

		Slider:OnChanged(function(Value)
			getfenv().carbonPinghackPower = Value			
		end)
		local Toggle = carbontab:AddToggle("핑핵 실행", 
			{
				Title = "핑핵ㅣVolume1", 
				Description = "토글을 키면 핑핵이실행됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						runs = game['Run Service'].RenderStepped:Connect(function ()
							for i = 1 , getfenv().carbonPinghackPower do
								for i , v in pairs(Players:GetPlayers()) do
									envts["ExplosiveEvent"]:FireServer(nil, v.Character:GetPivot().Position, 50000, 10, 10, nil, nil, nil, nil, nil, nil,nil, "Auth")
								end	
							end
						end) 
					else
						if runs then
							runs:Disconnect()
							print("핑핵 종료")	
						end
					end
				end 
			})

		local Toggle = carbontab:AddToggle("핑핵 실행", 
			{
				Title = "핑핵ㅣVolume2", 
				Description = "토글을 키면 핑핵이실행됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						runs = game['Run Service'].RenderStepped:Connect(function ()
							for i = 1 , getfenv().carbonPinghackPower do
								envts['Equip']:FireServer(false,"AK105",nil)
							end
						end) 
					else
						if runs then
							runs:Disconnect()
							print("핑핵 종료")	
						end
					end
				end 
			})



	else
		bnoti("Tab 은 이미 생성되어있습니다.")
	end
end
local function taeb()
	if taebtab == nil then
		taebtab = Window:AddTab({ Title = "태비부대 [CE]", Icon = "locate" })
		local aSection = taebtab:AddSection("이벤트 경로체크")

		local CResource = ReplicatedStorage:FindFirstChild("CarbonResource")
		taebtab:AddButton({
			Title = "이벤트 경로체크",
			Description = "카본엔진의 이벤트 경로를 체크합니다",
			Callback = function()
				envts = {}
				lplr.Character.Humanoid.Health = 0
				task.wait(0.3)
				for u, e in pairs(CResource.Events:GetChildren()) do
					envts[e.Name] = e
				end

			end
		})
		local aSection = taebtab:AddSection("모든 플레이어 킬")
		taebtab:AddButton({
			Title = "킬올",
			Description = "서버에 있는 모든플레이어를 죽입니다",
			Callback = function()
				for idx, plr in pairs(Players:GetPlayers()) do
					envts["DamageEvent"]:FireServer(plr.Character:FindFirstChild("Humanoid"), 100000, "Torso", {'nil','ruX2TEWTq1','nil','nil'})
				end
			end
		})
		taebtab:AddButton({
			Title = "폭발 올",
			Description = "서버에 있는 모든플레이어를 폭발시킵니다",
			Callback = function()
				for idx, plr in pairs(Players:GetPlayers()) do
					envts["ExplosiveEvent"]:FireServer(nil, plr.Character:GetPivot().Position, 50000, 10, 10, nil, nil, nil, nil, nil, nil,nil, "ruX2TEWTq1")
				end
			end
		})
		local aSection = taebtab:AddSection("서버 폭발")
		local Slider = taebtab:AddSlider("Slider", 
			{
				Title = "핑핵 파워",
				Description = "Server Ping Power",
				Default = 2,
				Min = 0,
				Max = 100,
				Rounding = 1,
				Callback = function(Value)
					getfenv().carbonPinghackPower = Value
				end
			})

		Slider:OnChanged(function(Value)
			getfenv().carbonPinghackPower = Value			
		end)
		local Toggle = taebtab:AddToggle("핑핵 실행", 
			{
				Title = "핑핵ㅣVolume1", 
				Description = "토글을 키면 핑핵이실행됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						runs = game['Run Service'].RenderStepped:Connect(function ()
							for i = 1 , getfenv().carbonPinghackPower do
								for i , v in pairs(Players:GetPlayers()) do
									envts["ExplosiveEvent"]:FireServer(nil, v.Character:GetPivot().Position, 50000, 10, 10, nil, nil, nil, nil, nil, nil,nil, "ruX2TEWTq1")
								end	
							end
						end) 
					else
						if runs then
							runs:Disconnect()
							print("핑핵 종료")	
						end
					end
				end 
			})

		local Toggle = taebtab:AddToggle("핑핵 실행", 
			{
				Title = "핑핵ㅣVolume2", 
				Description = "토글을 키면 핑핵이실행됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						runs = game['Run Service'].RenderStepped:Connect(function ()
							for i = 1 , getfenv().carbonPinghackPower do
								envts['Equip']:FireServer(false,"AK105",nil)
							end
						end) 
					else
						if runs then
							runs:Disconnect()
							print("핑핵 종료")	
						end
					end
				end 
			})



	else
		bnoti("Tab 은 이미 생성되어있습니다.")
	end
end
local function Acs7a()
	if ACS7tab == nil then
		ACS7tab = Window:AddTab({ Title = "ACS 1.7.5 [ACS]", Icon = "locate" })
		local aSection = ACS7tab:AddSection("서버 폭발")
		local Slider = ACS7tab:AddSlider("Slider", 
			{
				Title = "핑핵 파워",
				Description = "Server Ping Power",
				Default = 2,
				Min = 0,
				Max = 100,
				Rounding = 1,
				Callback = function(Value)
					print("Slider was changed:", Value)
				end
			})

		Slider:OnChanged(function(Value)
			getfenv().PinghackPower = Value			
		end)
		local Toggle = ACS7tab:AddToggle("핑핵 실행", 
			{
				Title = "핑핵", 
				Description = "토글을 키면 핑핵이실행됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						runs = game['Run Service'].RenderStepped:Connect(function ()
							print(1)
							for i = 1 , getfenv().PinghackPower do
								local Size = {
									X = 1,
									Y = 1,
									Z = 1
								}
								ReplicatedStorage['ACS_Engine'].Eventos.Breach:FireServer(3,{Fortified={},Destroyable=workspace},CFrame.new(),CFrame.new(),{CFrame=game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame,Size=Size}) 
							end
						end) 
					else
						if runs then
							runs:Disconnect()
							print("핑핵 종료")	
						end
					end
				end 
			})
		local aSection = ACS7tab:AddSection("킬올")
		ACS7tab:AddButton({
			Title = "킬올",
			Description = "서버에 있는 모든플레이어를 죽입니다.",
			Callback = function()
				for i , plr in pairs(game.Players:GetPlayers()) do
					aacskil(plr)
				end
			end
		})

		local Input = ACS7tab:AddInput("ACS_Namekill", {
			Title = "닉네임 킬",
			Description = "닉네임으로 유저를 죽입니다.",
			Default = "",
			Placeholder = "PlayerName",
			Numeric = false, -- Only allows numbers
			Finished = true, -- Only calls callback when you press enter
			Callback = function(Value)
				local p = Players:FindFirstChild(Value)
				if p then
					aacskil(p)
				else
					bnoti("플레이어 이름을 정확히 입력해주세요.")
				end
			end
		})
		local aSection = ACS7tab:AddSection("리더스텟 테러")
		ACS7tab:AddButton({
			Title = "리더스텟을 테러합니다",
			Description = "서버에 있는 모든사람의 리더스텟을 고장냅니다.",
			Callback = function()
				for i , plr in pairs(Players:GetPlayers()) do
					for idx , a in pairs(plr['leaderstats']:GetChildren()) do
						ReplicatedStorage.ACS_Engine.Eventos.Recarregar:FireServer(math.huge,{['ACS_Modulo'] = {['Variaveis'] = {['StoredAmmo'] = a}}})					end
				end
			end
		})
		local aSection = ACS7tab:AddSection("소리 테러")
		local Toggle = ACS7tab:AddToggle("소리테러", 
			{
				Title = "소리테러", 
				Description = "토글을 키면 소리테러가실행됩니다.",
				Default = false,
				Callback = function(state)
					getfenv().whileloop = state
					while task.wait() do
						if not getfenv().whileloop then break end
						for i , v in pairs(Players:GetPlayers()) do
							ReplicatedStorage.ACS_Engine.Eventos.Whizz:FireServer(v)
						end
					end
				end 
			})
		local aSection = ACS7tab:AddSection("갓")
		local Toggle = ACS7tab:AddToggle("갓", 
			{
				Title = "갓 모드", 
				Description = "체력이 무제한이 됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						acsgod()
					else
						game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 150
					end
				end 
			})
	else
		bnoti("Tab 은 이미 생성되어있습니다.")

	end
end
local function bab()
	if BabbabTab == nil then
		BabbabTab = Window:AddTab({ Title = "밥밥부대 [FE]", Icon = "locate" })
		local aSection = BabbabTab:AddSection("킬올")
		BabbabTab:AddButton({
			Title = "밥밥부대 총 킬올",
			Description = "서버에있는 모든 플레이어를 죽입니다",
			Callback = function()
				local gun = lplr.Character:FindFirstChildOfClass("Tool") 
				if not gun then bnoti("총을 들고 사용해주세요.") return end
					for i , v in pairs(game.Players:GetPlayers()) do

						local args = {
							[1] = "Gun",
							[2] = gun,
							[3] = require(gun['Setting']['1']) ,
							[4] = v.Character.Humanoid,
							[5] = v.Character.HumanoidRootPart,
							[6] = v.Character.Head,
							[7] = {
								["ChargeLevel"] = 0,
								["ExplosionEffectFolder"] = game:GetService("ReplicatedStorage"):WaitForChild("Miscs"):WaitForChild("GunVisualEffects"):WaitForChild("Common"):WaitForChild("ExplosionEffect"),
								["MuzzleFolder"] = game:GetService("ReplicatedStorage"):WaitForChild("Miscs"):WaitForChild("GunVisualEffects"):WaitForChild("Common"):WaitForChild("MuzzleEffect"),
								["HitEffectFolder"] = game:GetService("ReplicatedStorage"):WaitForChild("Miscs"):WaitForChild("GunVisualEffects"):WaitForChild("Common"):WaitForChild("HitEffect"),
								["GoreEffect"] = game:GetService("ReplicatedStorage"):WaitForChild("Miscs"):WaitForChild("GunVisualEffects"):WaitForChild("Common"):WaitForChild("GoreEffect"),
								["BloodEffectFolder"] = game:GetService("ReplicatedStorage"):WaitForChild("Miscs"):WaitForChild("GunVisualEffects"):WaitForChild("Common"):WaitForChild("BloodEffect")
							},
							[8] = 10319
						}

						ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("InflictTarget"):InvokeServer(unpack(args))

					end

			end
		})

		BabbabTab:AddButton({
			Title = "밥밥부대 수갑 킬올",
			Description = "서버에있는 모든 플레이어를 죽입니다",
			Callback = function()
				local lineObject = game:GetService("ReplicatedStorage"):FindFirstChild("line")

				if lineObject then
					lineObject:Destroy() 
				end			
				for idx , plr in pairs(game.Players:GetPlayers()) do
					if plr.Team.Name ~= "시민" then
						local lplrc = lplr.Character
						lplrc:MoveTo(plr.Character:GetPivot().Position)
						task.wait(0.25)
						local args = {
							[1] = plr.Character
						}
						game:GetService("Players").LocalPlayer.Character:FindFirstChild("Cuffs.").CuffsRemote:FireServer(unpack(args))
						lplrc:MoveTo(Vector3.new(304.109619140625, -441.8008728027344, 107.42218017578125))
						task.wait(0.25)
						local args = {
							[1] = plr.Character
						}
						game:GetService("Players").LocalPlayer.Character:FindFirstChild("Cuffs.").CuffsRemote:FireServer(unpack(args))
					end
				end

			end
		})



	else
		bnoti("Tab 은 이미 생성되어있습니다.")
	end
end



local function Acs2a()
	if ACS2tab == nil then
		ACS2tab = Window:AddTab({ Title = "ACS 2.0.1 [ACS]", Icon = "locate" })
		local aSection = ACS2tab:AddSection("서버 폭발")
		local Slider = ACS2tab:AddSlider("Slider", 
			{
				Title = "핑핵 파워",
				Description = "Server Ping Power",
				Default = 2,
				Min = 0,
				Max = 100,
				Rounding = 1,
				Callback = function(Value)
					print("Slider was changed:", Value)
				end
			})

		Slider:OnChanged(function(Value)
			getfenv().PinghackPower = Value			
		end)
		local Toggle = ACS2tab:AddToggle("핑핵 실행", 
			{
				Title = "핑핵", 
				Description = "토글을 키면 핑핵이실행됩니다.",
				Default = false,
				Callback = function(state)
					if state then
						local ev = game.ReplicatedStorage.ACS_Engine.Events.Equip
						runs = game['Run Service'].RenderStepped:Connect(function ()
							for i = 1 , getfenv().PinghackPower do
								ev:FireServer({["Name"] = ReplicatedStorage.ACS_Engine.GunModels:FindFirstChildOfClass("Model").Name} , 1)
							end
						end) 
					else
						if runs then
							runs:Disconnect()
							print("핑핵 종료")	
						end
					end
				end 
			})
		local aSection = ACS2tab:AddSection("킬올")
		ACS2tab:AddButton({
			Title = "킬올",
			Description = "서버에 있는 모든플레이어를 죽입니다.",
			Callback = function()
				for i , plr in pairs(game.Players:GetPlayers()) do
					acskil(plr)
				end
			end
		})

		local Input = ACS2tab:AddInput("ACS_Namekill", {
			Title = "닉네임 킬",
			Description = "닉네임으로 유저를 죽입니다.",
			Default = "",
			Placeholder = "PlayerName",
			Numeric = false, -- Only allows numbers
			Finished = true, -- Only calls callback when you press enter
			Callback = function(Value)
				local p = Players:FindFirstChild(Value)
				if p then
					acskil(p)
				else
					bnoti("플레이어 이름을 정확히 입력해주세요.")
				end
			end
		})
		local aSection = ACS2tab:AddSection("리더스텟 테러")
		ACS2tab:AddButton({
			Title = "리더스텟을 테러합니다",
			Description = "서버에 있는 모든사람의 리더스텟을 고장냅니다.",
			Callback = function()
				for i , plr in pairs(Players:GetPlayers()) do
					for idx , a in pairs(plr['leaderstats']:GetChildren()) do
						ReplicatedStorage.ACS_Engine.Events.Refil:FireServer(a , -math.huge)
					end
				end
			end
		})
		local aSection = ACS2tab:AddSection("소리 테러")
		local Toggle = ACS2tab:AddToggle("소리테러", 
			{
				Title = "소리테러", 
				Description = "토글을 키면 소리테러가실행됩니다.",
				Default = false,
				Callback = function(state)
					getfenv().whileloop = state
					while task.wait() do
						if not getfenv().whileloop then break end
						for i , v in pairs(Players:GetPlayers()) do
							ReplicatedStorage.ACS_Engine.Events.Whizz:FireServer(v)
						end
					end
				end 
			})




	else
		bnoti("Tab 은 이미 생성되어있습니다.")

	end
end




local Tabs = {
	EngineCheck = Window:AddTab({ Title = "EngineCheck", Icon = "scan" }),
	Settings = Window:AddTab({ Title = "PlayerSetting", Icon = "settings" })
}


local ySection = Tabs["Settings"]:AddSection("플레이어 스피드")
local Slider = Tabs["Settings"]:AddSlider("Slider", 
	{
		Title = "플레이어 스피드",
		Description = "Player Speed",
		Default = lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Callback = function(Value)
			lplr.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
		end
	})
local yaSection = Tabs["Settings"]:AddSection("플레이어 점프파워")
local Slider = Tabs["Settings"]:AddSlider("Slider", 
	{
		Title = "플레이어 점프파워",
		Description = "Player JumpPower",
		Default = lplr.Character:FindFirstChildOfClass("Humanoid").JumpHeight,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Callback = function(Value)
			lplr.Character:FindFirstChildOfClass("Humanoid").JumpHeight = Value
		end
	})
local yaSection = Tabs["Settings"]:AddSection("색 변경")

local Dropdown = Tabs["Settings"]:AddDropdown("Dropdown", {
	Title = "Dropdown",
	Description = "Dropdown description",
	Values = {"Darker", "Dark", "Light", "Rose", "Aqua", "Amethyst"},
	Multi = false,
	Default = 1,
})
Dropdown:OnChanged(function(Value)
	Window['Theme'] = Value
end)
local yaSection = Tabs["Settings"]:AddSection("ESP")
local Toggle = Tabs["Settings"]:AddToggle("ESP", 
	{
		Title = "ESP", 
		Description = "토글을 키면 ESP 가 실행됩니다.",
		Default = false,
		Callback = function(state)
			if state then
				for i , v in pairs(Players:GetPlayers()) do
					ac = v.Character or v.CharacterAdded:Wait()
					if ac:FindFirstChild("ESP_SYTICHUB") then return end
					local cl = Instance.new("Highlight")
					cl.Parent = ac
					cl.FillColor = ac:FindFirstChild("Head").Color or Color3.fromRGB(170, 255, 0)
					cl.Name = "ESP_SYTICHUB"
				end
			else
				for i , v in pairs(Players:GetPlayers()) do
					local char = v.Character
					local espa = char:FindFirstChild("ESP_SYTICHUB")
					if espa then
						espa:Destroy()
					end
				end
			end
		end 
	})
local yaSection = Tabs["Settings"]:AddSection("Infinite Yield")
Tabs["Settings"]:AddButton({
	Title = "Infinite Yield",
	Description = "Infinite Yield를 킵니다.",
	Callback = function ()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end
})

local mSection = Tabs["EngineCheck"]:AddSection("게임")

Tabs["EngineCheck"]:AddParagraph({
	Title = "Running in",
	Content = Place
})
local xSection = Tabs["EngineCheck"]:AddSection("게임 총 엔진 찾기")

Tabs["EngineCheck"]:AddButton({
	Title = "엔진 찾기",
	Description = "find Engine in this game",
	Callback = function()
		local CheckgunResult = findgun()
		if CheckgunResult == "1.7.5" then
			Acs7a()		
		elseif CheckgunResult == "2.0.1" then 
			Acs2a()
		elseif    CheckgunResult == "carbonEngine" then
			carbonA()
		elseif CheckgunResult == "Nofind"  then
			bnoti("총킷을 찾을수없음")
		elseif CheckgunResult == "밥밥부대" then
			bab()
		elseif CheckgunResult == "완성재단" then
			loadWhansung()	Acs2a() carbonA()
		elseif CheckgunResult == "태비부대" then
			taeb()
		elseif CheckgunResult == "백호산부대" then
			loadbaekho()
		end
	end
})



gnoti("사이틱 허브가 정상적으로 실행됨")
