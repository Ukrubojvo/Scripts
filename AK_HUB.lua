local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
 
local Window = Rayfield:CreateWindow({
   Name = "❤AK Hub❤",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "로딩중..",
   LoadingSubtitle = "😀by norn😀",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },
 
   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
 
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})
 
local MainTab = Window:CreateTab("💲에임 + ESP💲", nil) -- Title, Image
local MainSection = MainTab:CreateSection("라이벌/아스널")
 
local Button = MainTab:CreateButton({
   Name = "💥라이벌,아스널💥",
   Callback = function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/blackowl1231/ZYPHERION/refs/heads/main/main.lua')))()
   end,
})
 
local MainTab = Window:CreateTab("💀어드민💀", nil) -- Title, Image
local MainSection = MainTab:CreateSection("어드민")
 
local Button = MainTab:CreateButton({
   Name = "🔥어드민🔥",
   Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
   end,
})
 
local MainTab = Window:CreateTab("💤배드워즈💤", nil) -- Title, Image
local MainSection = MainTab:CreateSection("메인")
 
local Button = MainTab:CreateButton({
   Name = "🎉배드워즈🎉",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/vapevoidware/main/NewMainScript.lua", true))()
getgenv().Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/SuperGamingBros4/Roblox-HAX/main/Better_UI_Library.lua"))()
   end,
})
 
local MainTab = Window:CreateTab("🐟피쉬🐟", nil) -- Title, Image
local MainSection = MainTab:CreateSection("피쉬")
 
local Button = MainTab:CreateButton({
   Name = "🐋피쉬🐋",
   Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
   end,
})
 
local MainTab = Window:CreateTab("🥓암보결🥓", nil) -- Title, Image
local MainSection = MainTab:CreateSection("히트박스,ESP는 암보결이 아닌 다른 게임에서도 작동합니다")
 
local Button = MainTab:CreateButton({
   Name = "암보결 히트박스",
   Callback = function()
    loadstring(game:GetObjects("rbxassetid://14713089094")[1].Source)()
   end,
})
 
local MainTab = Window:CreateTab("🤠프리즌 라이프🤠", nil) -- Title, Image
local MainSection = MainTab:CreateSection("현재 킬아우라는 작동을 안하며 킬올만 작동합니다")
 
local Button = MainTab:CreateButton({
   Name = "킬올 프리즌 라이프",
   Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/thaibao/main/TbaohubPrisonLife"))()
   end,
})
