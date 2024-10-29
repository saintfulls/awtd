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

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Rayfield Example Window",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "SapphireHub/Anime World Tower Defense/Settings/", -- Create a custom folder for your hub/game
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
        FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
        SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
        GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
        Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
     }
})

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

local JSON

local startTime
local startTimeOffset

if not pcall(function()
    readfile(SettingsFile)
end) then
    writefile(SettingsFile, game:GetService("HttpService"):JSONEncode(DefaultSettings))
end

local Macros = {}
local folder_name = "SapphireHub/Anime World Tower Defense/" .. game.Players.LocalPlayer.UserId

if not isfolder(folder_name) then
    makefolder(folder_name)
end

if #listfiles(folder_name) == 0 then
    writefile(folder_name .. "/" .. "Default Profile.json",
        game:GetService("HttpService"):JSONEncode(MacroDefaultSettings))
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

function SaveMacros()
    for profile_name, macro_table in pairs(Macros) do
        local save_data = {}
        save_data[profile_name] = macro_table
        writefile(folder_name .. "/" .. profile_name .. ".json", game:GetService("HttpService"):JSONEncode(save_data))
    end
end

function Save()
    writefile(SettingsFile, game:GetService("HttpService"):JSONEncode(JSON))
    SaveMacros()
end

Save()
for k, v in pairs(DefaultSettings) do
    if JSON[k] == nil then
        JSON[k] = v
    end
end

for i, v in pairs(game:GetService("ReplicatedStorage").Remote.ReturnData:InvokeServer()) do
    print(i, v)
end
function MacroPlayback()
    -- check if its in game first or not and if money exists.
    repeat
        task.wait()
    until game.Players.LocalPlayer:FindFirstChild("Money") ~= nil

    -- sort recorded macro before using it.
    table.sort(Macros[JSON.macro_profile], function(a, b)
        return a[1] < b[1]
    end)

    for _, v in pairs(Macros[JSON.macro_profile]) do
        local time = v[1]
        local remote_arguments = v[2]
        local money = v[3]

        -- money tracking (to be removed)
        if JSON.macro_money_tracking and money ~= nil then
            repeat
                task.wait()
            until GetMoney() >= money
        end

        repeat
            task.wait()
            -- if action happened before wave started, can execute all at once.
        until timeElapsed() >= time or time < 0

        if not JSON.macro_playback then
            return
        end

        local action = remote_arguments[1]
        local parameters = remote_arguments[2]

        if action == "Summon" and JSON.macro_summon then
            local args = {
                [1] = action,
                [2] = {
                    ["Rotation"] = tonumber(parameters["Rotation"]),
                    ["cframe"] = stringToCFrame(parameters["cframe"]),
                    ["Unit"] = parameters["Unit"]
                }
            }

            game:GetService("ReplicatedStorage").Remotes.Input:FireServer(unpack(args))
        end

        if (action == "UseSpecialMove" and JSON.macro_specialmove and
            table.find(JSON.macro_blacklist_specialmove, parameters["Name"]) == nil) or
            (action == "AutoToggle" and JSON.macro_autospecialmove) then
            for _, unit in pairs(game:GetService("Workspace").Unit:GetChildren()) do
                if unit.Name == parameters["Name"] and unit:WaitForChild("Owner").Value == game.Players.LocalPlayer then
                    local magnitude =
                        (unit.HumanoidRootPart.Position - stringToCFrame(parameters["Location"]).Position).magnitude

                    if magnitude == 0 then
                        local args = {
                            [1] = action,
                            [2] = unit
                        }

                        if remote_arguments[3] ~= nil then
                            table.insert(args, remote_arguments[3])
                        end

                        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(unpack(args))

                        if action == "AutoToggle" then
                            local args = {
                                [1] = "UseSpecialMove",
                                [2] = unit
                            }

                            game:GetService("ReplicatedStorage").Remotes.Input:FireServer(unpack(args))
                        end
                    end
                end
            end
        end

        if (action == "Upgrade" and JSON.macro_upgrade) or (action == "ChangePriority" and JSON.macro_changepriority) or
            (action == "Sell" and JSON.macro_sell) then
            for _, unit in pairs(game:GetService("Workspace").Unit:GetChildren()) do
                if unit.Name == parameters["Name"] and unit:WaitForChild("Owner").Value == game.Players.LocalPlayer then
                    local magnitude =
                        (unit.HumanoidRootPart.Position - stringToCFrame(parameters["Location"]).Position).magnitude

                    if magnitude == 0 then
                        local args = {
                            [1] = action,
                            [2] = unit
                        }

                        if action == "Upgrade" then
                            game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer(unpack(args))
                        else
                            game:GetService("ReplicatedStorage").Remotes.Input:FireServer(unpack(args))
                        end
                    end
                end
            end
        end

        if (action == "VoteWaveConfirm" and JSON.macro_skipwave) then
            task.spawn(function()
                repeat
                    task.wait()
                until game.Players.LocalPlayer.PlayerGui.HUD.ModeVoteFrame.Visible

                local args = {
                    [1] = action
                }

                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(unpack(args))
            end)
        end

        task.wait(0.24)
    end
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

local game_metatable = getrawmetatable(game)
local namecall_original = game_metatable.__namecall

setreadonly(game_metatable, false)

function CFrameToTable(cframe)
    local components = {cframe:GetComponents()}
    return components
end

function TableToCFrame(tbl)
    return CFrame.new(unpack(tbl))
end

game_metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local Args = {...}

    local money = GetMoney()
    if Args and (method == "FireServer" or method == "InvokeServer") then
        if JSON.macro_record and not JSON.macro_playback then
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

local Tabs = {
    Game = Window:CreateTab("Game", 4483362458),
    Lobby = Window:CreateTab("Lobby", 4483362458),
    Macro = Window:CreateTab("Macro", 4483362458),
    Webhook = Window:CreateTab("Webhook", 4483362458),
    Miscellaneous = Window:CreateTab("Miscellaneous", 4483362458)
}

local Macro_Main = Macro:CreateSection("Main")
local Macro_Settings = Macro:CreateSection("Macro Settings")

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

local Macro_list = Macro_Main:CreateDropdown({
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

local Macro_Record = Macro_Main:CreateToggle({
    Name = "Record Macro",
    CurrentValue = JSON.macro_record,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        JSON.macro_record = Value
        Save()
        if not value then
            Rayfield:Notify({
                Title = "Macro",
                Content = "Saved Macro :" .. Option,
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
                Content = "Recording Macro :" .. Option,
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

local Macro_Playback = Macro_Main:CreateToggle({
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

local profile_name = ""

local profile_name_text = Macro_Settings:CreateInput({
    Name = "Profile Name",
    PlaceholderText = "Enter Name",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text ~= "" then
            Text = profile_name
        end
    end,
 })

 local Button = Macro_Settings:CreateButton({
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
    end,
 }) 
