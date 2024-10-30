for _, v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end

repeat
    task.wait()
until game.CoreGui:FindFirstChild("RobloxPromptGui")

local po, ts = game.CoreGui.RobloxPromptGui.promptOverlay, game:GetService("TeleportService")

local teleportOnFailed = po.ChildAdded:Connect(function(a)
    if a.Name == "ErrorPrompt" then
        repeat
            ts:Teleport(game.PlaceId)
            task.wait(1)
        until false
    end
end)

local DefaultSettings = {
    macro_profile = "Default Profile",
    macro_sell = true,
    macro_changepriority = true,
    macro_specialmove = true,
    macro_skipwave = false,
    macro_record = false,
    macro_playback = false,
    auto_join_game = false,
    auto_join_level = 1
}

-- Make required folders if they don't exist
if not isfolder("SapphireHub") then
    makefolder("SapphireHub")
end
if not isfolder("SapphireHub/Anime World Tower Defense") then
    makefolder("SapphireHub/Anime World Tower Defense")
end
if not isfolder("SapphireHub/Anime World Tower Defense/Settings") then
    makefolder("SapphireHub/Anime World Tower Defense/Settings")
end

local SettingsFile = "SapphireHub/Anime World Tower Defense/Settings/" .. game.Players.LocalPlayer.UserId .. ".json"
local MacroDefaultSettings = {
    ["Default Profile"] = {}
}
local JSON, Macros, startTime, startTimeOffset
local folder_name = "SapphireHub/Anime World Tower Defense/" .. game.Players.LocalPlayer.UserId

if not pcall(function()
    readfile(SettingsFile)
end) then
    writefile(SettingsFile, game:GetService("HttpService"):JSONEncode(DefaultSettings))
end

Macros = {}

if not isfolder(folder_name) then
    makefolder(folder_name)
end

for _, file in pairs(listfiles(folder_name)) do
    if not pcall(function()
        local json_content = game:GetService("HttpService"):JSONDecode(readfile(file))

        for k, v in pairs(json_content) do
            if Macros[k] ~= nil then
                delfile(file)
            else
                Macros[k] = v
            end
        end
    end) then
        print("Error reading file: " .. file)
    end
end
if not pcall(function()
    JSON = game:GetService("HttpService"):JSONDecode(readfile(SettingsFile))
end) then
    writefile(SettingsFile, game:GetService("HttpService"):JSONEncode(DefaultSettings))
    JSON = DefaultSettings
end

local function SaveMacros()
    for profile_name, macro_table in pairs(Macros) do
        -- Check if profile_name is a string

        local save_data = {
            [profile_name] = macro_table
        }
        local path = folder_name .. "/" .. profile_name .. ".json"

        -- Use pcall to handle any potential errors in writing
        local success, err = pcall(function()
            writefile(path, game:GetService("HttpService"):JSONEncode(save_data))
        end)

        if not success then
            warn("Failed to save file at " .. path .. ": " .. tostring(err))
        end

    end
end

local function Save()
    local settings_path = folder_name .. "/Settings.json"

    -- Use pcall to handle errors in saving JSON settings
    local success, err = pcall(function()
        writefile(settings_path, game:GetService("HttpService"):JSONEncode(JSON))
    end)

    if not success then
        warn("Failed to save settings: " .. tostring(err))
    end

    SaveMacros()
end

Save()

for k, v in pairs(DefaultSettings) do
    if JSON[k] == nil then
        JSON[k] = v
    end
end

function MacroPlayback()

end

function StartMacroTimer()
    repeat
        task.wait()
    until not game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").Visible and
        game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").topic.Text ~= "[Ready]"
    startTime = os.time()
    startTimeOffset = os.time()
    timeElapsed()
end

function GetMoney()
    return game.Players.LocalPlayer.leaderstats.Cash.Value
end

function timeElapsed()
    if startTime == nil then
        return -10
    else
        return (os.time() - startTime) + (startTimeOffset - startTime)
    end
end
function CFrameToTable(cframe)
    local components = {cframe:GetComponents()}
    return components
end

function TableToCFrame(tbl)
    return CFrame.new(unpack(tbl))
end
local game_metatable = getrawmetatable(game)
local namecall_original = game_metatable.__namecall

setreadonly(game_metatable, false)

game_metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local Args = {...}
    local money

    if Args and (method == "FireServer" or method == "InvokeServer") then
        if JSON.macro_record and not JSON.macro_playback then
            if game.Players.LocalPlayer.leaderstats.Cash then
                money = GetMoney()
            end

            if self.Name == "SpawnUnit" then
                table.insert(Macros[JSON.macro_profile], {
                    [1] = timeElapsed(),
                    [2] = {
                        [1] = Args[1],
                        [2] = CFrameToTable(Args[2])
                    },
                    [3] = money
                })
            elseif self.Name == "UpgradeUnit" then
                -- Logic for UpgradeUnit
            elseif self.Name == "ChangeUnitModeFunction" then
                -- Logic for ChangeUnitModeFunction
            elseif self.Name == "SellUnit" then
                -- Logic for SellUnit
            elseif self.Name == "SkipEvent" then
                -- Logic for SkipEvent
            end
            task.spawn(function()
                Save()
            end)
        end
    end
    return namecall_original(self, ...)
end)

local Player = game:GetService("Players").LocalPlayer
repeat
    task.wait()
until #Player.Data:GetChildren() > 0

if not game.Workspace:FindFirstChild("PlayerPortal") then
    task.spawn(StartMacroTimer)
end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Sapphire Hub",
    LoadingTitle = "Anime World Tower Defense",
    LoadingSubtitle = "by Saintfulls",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "SapphireHub/Anime World Tower Defense/Settings/",
        FileName = game.Players.LocalPlayer.UserId .. ".json"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local Tabs = {
    Game = Window:CreateTab("Game", 4483362458),
    Lobby = Window:CreateTab("Lobby", 4483362458),
    Macro = Window:CreateTab("Macro", 4483362458),
    Webhook = Window:CreateTab("Webhook", 4483362458),
    Miscellaneous = Window:CreateTab("Miscellaneous", 4483362458)
}

local Macro_Main = Tabs.Macro:CreateSection("Main")

local profile_list = {}
for i, _ in pairs(Macros) do
    table.insert(profile_list, i)
end

if Macros[JSON.macro_profile] == nil then
    for _, v in pairs(profile_list) do
        if v ~= nil then
            JSON.macro_profile = v
            break
        end
    end
end

local Macro_list = Tabs.Macro:CreateDropdown({
    Name = "Macro List",
    Options = profile_list,
    CurrentOption = {JSON.macro_profile},
    MultipleOptions = false,
    Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Option)
        JSON.macro_profile = Option
        if Macros[Option] == nil then
            Macros[Option] = {}
        end
        Save()

        Rayfield:Notify({
            Title = "Macro Profile",
            Content = "Using " .. Option,
            Duration = 6.5,
            Image = 4483362458,
            Actions = { -- Notification Buttons

                Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                    Name = "Okay!",
                    Callback = function()

                    end
                }

            }
        })
    end
})

local Macro_Record = Tabs.Macro:CreateToggle({
    Name = "Record Macro",
    CurrentValue = JSON.macro_record,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        JSON.macro_record = Value
        Save()
        if not Value then
            Rayfield:Notify({
                Title = "Macro",
                Content = "Saved Macro :" .. JSON.macro_profile,
                Duration = 6.5,
                Image = 4483362458,
                Actions = { -- Notification Buttons

                    Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                        Name = "Okay!",
                        Callback = function()

                        end
                    }

                }
            })
        else
            Rayfield:Notify({
                Title = "Macro",
                Content = "Recording Macro :" .. JSON.macro_profile,
                Duration = 6.5,
                Image = 4483362458,
                Actions = { -- Notification Buttons

                    Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                        Name = "Okay!",
                        Callback = function()

                        end
                    }

                }
            })
        end
    end
})

local Macro_Playback = Tabs.Macro:CreateToggle({
    Name = "Play Macro",
    CurrentValue = JSON.macro_playback,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        JSON.macro_playback = Value
        Save()

        if value then
            task.spawn(MacroPlayback)
        end
    end
})
local Macro_Settings = Tabs.Macro:CreateSection("Macro Settings")
local profile_name = ""

local profile_name_text = Tabs.Macro:CreateInput({
    Name = "Profile Name",
    PlaceholderText = "Enter Name",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text ~= "" then
            Text = profile_name
        end
    end
})

local Button = Tabs.Macro:CreateButton({
    Name = "Create Profile",
    Callback = function()
        if Macros[profile_name] ~= nil then
            venyx:Notify("Macro Profile", "Macro already exists: " .. profile_name)
            Rayfield:Notify({
                Title = "Macro Profile",
                Content = "Macro already exists :" .. profile_name,
                Duration = 6.5,
                Image = 4483362458,
                Actions = { -- Notification Buttons

                    Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                        Name = "Okay!",
                        Callback = function()

                        end
                    }

                }
            })
        else
            -- creates new profile if it doesn't exist.
            Macros[profile_name] = {}

            -- sets current profile to newly created profile
            JSON.macro_profile = profile_name
            Save()
            -- inserts profile into list of profiles.
            table.insert(profile_list, JSON.macro_profile)

            Macro_list:Set(profile_list)
        end
    end
})
