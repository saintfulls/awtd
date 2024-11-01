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
    macro_upgrade = true,
    macro_summon = true,
    macro_specialmove = true,
    macro_skipwave = true,
    macro_record = false,
    macro_playback = false,
    auto_join_game = false,
    auto_join_level = 1,
    auto_2x = false
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

function MacroPlayback()
    repeat
        task.wait()
    until game.Players.LocalPlayer:FindFirstChild("leaderstats").Cash ~= nil

    -- Sort macros by the first element (time)
    table.sort(Macros[JSON.macro_profile], function(a, b)
        return a[1] < b[1]
    end)

    for _, v in pairs(Macros[JSON.macro_profile]) do
        local time = v[1]
        local remote_arguments = v[2]
        local money = v[3]

        -- Money tracking (to be removed)
        if money ~= nil then
            repeat
                task.wait()
            until GetMoney() >= money
        end

        repeat
            task.wait()
        until timeElapsed() >= time or time < 0

        if not JSON.macro_playback then
            return
        end

        local action = remote_arguments[2]
        local parameters = remote_arguments[2]

        if action[3] == "SpawnUnit" and JSON.macro_summon then
            local args = {
                parameters[1], 
                TableToCFrame(parameters[2]), 
                1, 
                {"1", "1", "1", "1"}
            }
            game:GetService("ReplicatedStorage").Remote.SpawnUnit:InvokeServer(unpack(args))

        elseif action[3] == "UpgradeUnit" and JSON.macro_summon then
            local args = {parameters[1]}
            for _, unit in pairs(game:GetService("Workspace").Unit:GetChildren()) do
                if unit == parameters[1] and unit:WaitForChild("Info").Owner.Value == game.Players.LocalPlayer.Name then
                    local magnitude = (unit.HumanoidRootPart.Position - TableToCFrame(parameters[2]).Position).magnitude
                    if magnitude == 0 then
                        game:GetService("ReplicatedStorage").Remote.UpgradeUnit:InvokeServer(unpack(args))
                    end
                end
            end

        elseif action[2] == "ChangeUnitModeFunction" and JSON.macro_changepriority then
            local args = {parameters[1]}
            for _, unit in pairs(game:GetService("Workspace").Unit:GetChildren()) do
                if unit == parameters[1] and unit:WaitForChild("Info").Owner.Value == game.Players.LocalPlayer.Name then
                    local magnitude = (unit.HumanoidRootPart.Position - TableToCFrame(parameters[3]).Position).magnitude
                    if magnitude == 0 then
                        game:GetService("ReplicatedStorage").Remote.ChangeUnitModeFunction:InvokeServer(unpack(args))
                    end
                end
            end

        elseif action[3] == "SellUnit" and JSON.macro_sell then
            local args = {parameters[1]}
            for _, unit in pairs(game:GetService("Workspace").Unit:GetChildren()) do
                if unit == parameters[1] and unit:WaitForChild("Info").Owner.Value == game.Players.LocalPlayer.Name then
                    local magnitude = (unit.HumanoidRootPart.Position - TableToCFrame(parameters[2]).Position).magnitude
                    if magnitude == 0 then
                        game:GetService("ReplicatedStorage").Remote.SellUnit:InvokeServer(unpack(args))
                    end
                end
            end

        elseif action[1] == "SkipWave" then
            game:GetService("ReplicatedStorage").Remote.SkipWave:FireServer()
        end
    end
end

function CFrameToTable(cframe)
    local x, y, z = cframe.Position.X, cframe.Position.Y, cframe.Position.Z
    local roll, pitch, yaw = cframe:ToOrientation()
    
    return {
        Position = {x, y, z},
        Angles = {roll, pitch, yaw}
    }
end

function TableToCFrame(cframeTable)
    local position = cframeTable.Position
    local angles = cframeTable.Angles

    return CFrame.new(position[1], position[2], position[3]) *
           CFrame.Angles(angles[1], angles[2], angles[3])
end

if game.PlaceId ~= 6558526079 then
    local game_metatable = getrawmetatable(game)
    local namecall_original = game_metatable.__namecall

    setreadonly(game_metatable, false)

    game_metatable.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local Args = {...}
        local money

        if Args and (method == "FireServer" or method == "InvokeServer") then
            if JSON.macro_record and not JSON.macro_playback then
                if Args[1] ~= nil then
                    money = GetMoney()
                    if self.Name == "SpawnUnit" and JSON.macro_summon then
                        table.insert(Macros[JSON.macro_profile], {
                            [1] = timeElapsed(),
                            [2] = {
                                Args[1],
                                CFrameToTable(Args[2]),  -- Convert CFrame to table
                                self.Name
                            },
                            [3] = money
                        })
                    elseif self.Name == "UpgradeUnit" and JSON.macro_upgrade then
                        table.insert(Macros[JSON.macro_profile], {
                            [1] = timeElapsed(),
                            [2] = {
                                Args[1]:GetFullName(),
                                CFrameToTable(Args[2]),  -- Convert CFrame to table
                                self.Name
                            },
                            [3] = money
                        })
                    elseif self.Name == "ChangeUnitModeFunction" and JSON.macro_changepriority then
                        table.insert(Macros[JSON.macro_profile], {
                            [1] = timeElapsed(),
                            [2] = {
                                Args[1]:GetFullName(),
                                self.Name,
                                CFrameToTable(Args[1].HumanoidRootPart.Position)  -- Convert CFrame to table
                            }
                        })
                    elseif self.Name == "SellUnit" and JSON.macro_sell then
                        table.insert(Macros[JSON.macro_profile], {
                            [1] = timeElapsed(),
                            [2] = {
                                Args[1]:GetFullName(),
                                CFrameToTable(Args[1].HumanoidRootPart.Position),  -- Convert CFrame to table
                                self.Name
                            }
                        })
                    elseif self.Name == "SkipEvent" and JSON.macro_skipwave then
                        table.insert(Macros[JSON.macro_profile], {
                            [1] = timeElapsed(),
                            [2] = {self.Name}
                        })
                    end

                    -- Save after recording if conditions are met
                    task.spawn(function()
                        Save()
                    end)
                end
            end
        end

        return namecall_original(self, ...)
    end)
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

function AutomaticChangeSpeed()

end

function JoinGame()
    while JSON.auto_join_game do

    end
end


local Player = game:GetService("Players").LocalPlayer
repeat
    task.wait()
until #Player.Data:GetChildren() > 0

if not game.Workspace:FindFirstChild("PlayerPortal") then
    if JSON.auto_2x then
        task.spawn(AutomaticChangeSpeed)
    end
    task.spawn(StartMacroTimer)
else

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

local Game_Main = Tabs.Game:CreateSection("Toggles")

Tabs.Macro:CreateToggle({
    Name = "Automatic 2x Speed",
    CurrentValue = JSON.auto_2x,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.auto_2x = value
        Save()

        if value and not game.Workspace:FindFirstChild("PlayerPortal") then
            task.spawn(AutomaticChangeSpeed)
        end
    end
})

local Lobby_Main = Tabs.Lobby:CreateSection("Toggles")

Tabs.Lobby:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = JSON.auto_join_game,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.auto_2x = value
        Save()

        if value then
            task.spawn(AutomaticChangeSpeed)
        end
    end
})

local Lobby_Second = Tabs.Lobby:CreateSection("Settings")

Tabs.Lobby:CreateToggle({
    Name = "Auto Next Story Level",
    CurrentValue = JSON.auto,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.auto_2x = value
        Save()

        if value and not game.Workspace:FindFirstChild("Queue") then
            task.spawn(AutomaticChangeSpeed)
        end
    end
})

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

local profile_name = ""

local profile_name_text = Tabs.Macro:CreateInput({
    Name = "Profile Name",
    PlaceholderText = "Enter Name",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text ~= "" then
            profile_name = Text
        end
    end
})

local Button = Tabs.Macro:CreateButton({
    Name = "Create Profile",
    Callback = function()
        if Macros[profile_name] ~= nil then
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
            table.insert(profile_list, profile_name)

            Macro_list:Refresh(profile_list)
            Macro_list:Set(profile_name)
        end
    end
})

local Macro_Settings = Tabs.Macro:CreateSection("Macro Settings")

Tabs.Macro:CreateToggle({
    Name = "Play Macro",
    CurrentValue = JSON.macro_summon,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_summon = Value
        Save()

    end
})

Tabs.Macro:CreateToggle({
    Name = "Play Macro",
    CurrentValue = JSON.macro_sell,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_sell = Value
        Save()

    end
})

Tabs.Macro:CreateToggle({
    Name = "Play Macro",
    CurrentValue = JSON.macro_upgrade,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_upgrade = Value
        Save()

    end
})

Tabs.Macro:CreateToggle({
    Name = "Play Macro",
    CurrentValue = JSON.macro_changepriority,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_changepriority = Value
        Save()

    end
})

Tabs.Macro:CreateToggle({
    Name = "Play Macro",
    CurrentValue = JSON.macro_skipwave,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_skipwave = Value
        Save()

    end
})

