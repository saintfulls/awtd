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
            ts:Teleport(game.GameId)
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
    auto_next_story = false,
    auto_join_delay = 10,
    auto_2x = false,
    auto_join_increment_story = false,
    auto_start_game = false,
    auto_join_difficulty = "Normal",
    auto_join_mode = "Story",
    auto_join_endless_mode = "Random Enemy",
    auto_join_raid_stage = "",
    auto_join_legend_stage = "",
    auto_join_event_stage = "",
    Macro_Maps_Profile = {
        Story = {},
        Infinite = {},
        Raid = {},
        legend_stage = {},
        EventStage = {},
        Other = {}
    },
    auto_replay = false,
}

local macroMapList = {
    ["Story"] = { {
        name = "To Be Hokage",
        levels = 5
    }, {
        name = "Dragon Orb",
        levels = 5
    }, {
        name = "East Island",
        levels = 5
    }, {
        name = "Peace Symbol",
        levels = 5
    }, {
        name = "Katamura Danger",
        levels = 5
    }, {
        name = "Demon Sister 1st",
        levels = 1
    }, {
        name = "Demon Sister 2nd",
        levels = 4
    }, {
        name = "Jo-Mission",
        levels = 5
    }, {
        name = "Chainsaw Devil",
        levels = 5
    }, {
        name = "Arranca Invation 1st",
        levels = 2
    }, {
        name = "Arranca Invation 2nd",
        levels = 3
    }, {
        name = "Sorcerer School",
        levels = 5
    }, {
        name = "String Kingdom",
        levels = 5
    } },
    ["Infinite"] = {
        "Endless Spider Forest",
        "Endless Snow Hill",
        "Random Enemy",
        "Darkness Tower"
    },
    ["Raid"] = {
        "Charuto Bridge",
        "Exploding Planet",
        "Exploding Planet 2nd Stage",
        "MarineFord",
        "Hero City",
        "Katamura City",
        "Spider MT.",
        "Pillar Cave",
        "Katana Revenge",
        "Soul Hall",
        "Tomb of the Star",
        "String Kingdom",
        "Shinobi Battleground",


    },
    ["Event"] = {
        "Forbidden Graveyard",
        "Training Field",
        "Boss Rush",
        "Random Unit",
        "Metal Rush",
        "Blue Element",
        "Green Element",
        "Purple Element",
        "Yellow Element",
        "Red Element"
    },
    ["Legend Stage"] = {
        "Paradox Invasion",
        "Victory Valley",
        "Dream Island",
        "Ruin Society",
        "Shadow Realm",
        "Idol Concert",
        "Evil Pink Dungeon",

    }
}

local function getWorldByStage(stageValue, mapList)
    local storyStageToWorld = {}
    local cumulativeStage = 0

    for _, world in ipairs(mapList["Story"]) do
        for i = 1, world.levels do
            cumulativeStage = cumulativeStage + 1
            storyStageToWorld[cumulativeStage] = world.name
        end
    end

    return storyStageToWorld[stageValue]
end

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

local foundAnything = ""

function TPReturner()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local actualHour = os.date("!*t").hour
    local File = pcall(function()
        AllIDs = game:GetService('HttpService'):JSONDecode(readfile(
            "SapphireHub/Anime World Tower Defense/" ..
            "NotSameServers.json"))
    end)
    if not File then
        table.insert(AllIDs, actualHour)
        writefile("SapphireHub/Anime World Tower Defense/" ..
            "NotSameServers.json",
            game:GetService('HttpService'):JSONEncode(AllIDs))
    end
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet(
            'https://games.roblox.com/v1/games/' ..
            PlaceID ..
            '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet(
            'https://games.roblox.com/v1/games/' ..
            PlaceID ..
            '/servers/Public?sortOrder=Asc&limit=100&cursor=' ..
            foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and
        Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("SapphireHub/Anime World Tower Defense/" ..
                                "NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                task.wait()
                pcall(function()
                    writefile("SapphireHub/Anime World Tower Defense/" ..
                        "NotSameServers.json",
                        game:GetService('HttpService'):JSONEncode(AllIDs))
                    task.wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(
                        PlaceID, ID, game.Players.LocalPlayer)
                end)
                task.wait(4)
            end
        end
    end
end

function Teleport()
    while task.wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then TPReturner() end
        end)
    end
end

function StartAutomaticNextButton()
    repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui.EndUI.UI.CountDown.Text ~= "-"
    if JSON.auto_join_increment_story and not JSON.auto_replay then
        task.wait(2)
        clickUI(game:GetService("Players").LocalPlayer.PlayerGui.EndUI.UI.NextStage)
        JSON.auto_join_level = JSON.auto_join_level + 1
        Save()
    end
end

function StartAutomaticReplayButton()
    repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui.EndUI.UI.CountDown.Text ~= "-"
    if JSON.auto_replay and not JSON.auto_join_increment_story then
        task.wait(2)
        clickUI(game:GetService("Players").LocalPlayer.PlayerGui.EndUI.UI.Replay)
    end
end

function MacroPlayback()
    repeat task.wait() until game.Players.LocalPlayer.leaderstats:FindFirstChild("Cash") ~=
    nil

    table.sort(Macros[JSON.macro_profile], function(a, b)
        return a[1] < b[1]
    end)

    for _, v in pairs(Macros[JSON.macro_profile]) do
        local time = v[1]
        local remote_arguments = v[2]
        local money = v[3]

        local parameters = remote_arguments

        repeat
            task.wait()
        until timeElapsed() >= time or time < 0

        if money ~= nil then
            repeat
                task.wait()
            until GetMoney() >= money
        end

        if not JSON.macro_playback then
            return
        end

        if parameters[3] == "SpawnUnit" and JSON.macro_summon then
            local args = { parameters[1], TableToCFrame(parameters[2]), 1, { "1", "1", "1", "1" } }
            game:GetService("ReplicatedStorage").Remote.SpawnUnit:InvokeServer(unpack(args))
        end
        if parameters[3] == "UpgradeUnit" and JSON.macro_summon then
            for _, unit in pairs(game:GetService("Workspace").Units:GetChildren()) do
                if unit.Name == parameters[1] and unit:WaitForChild("Info").Owner.Value == game.Players.LocalPlayer.Name then
                    local magnitude = (unit.HumanoidRootPart.Position - TableToCFrame(parameters[2]).Position).magnitude
                    if magnitude == 0 then
                        local args = { unit }
                        game:GetService("ReplicatedStorage").Remote.UpgradeUnit:InvokeServer(unpack(args))
                    end
                end
            end
        end
        if parameters[3] == "ChangeUnitModeFunction" and JSON.macro_changepriority then
            local args = { parameters[1] }
            for _, unit in pairs(game:GetService("Workspace").Units:GetChildren()) do
                if unit.Name == parameters[1] and unit:WaitForChild("Info").Owner.Value == game.Players.LocalPlayer.Name then
                    local magnitude = (unit.HumanoidRootPart.Position - TableToCFrame(parameters[3]).Position).magnitude
                    if magnitude == 0 then
                        game:GetService("ReplicatedStorage").Remote.ChangeUnitModeFunction:InvokeServer(unpack(args))
                    end
                end
            end
        end
        if parameters[3] == "SellUnit" and JSON.macro_sell then
            local args = { parameters[1] }
            for _, unit in pairs(game:GetService("Workspace").Units:GetChildren()) do
                if unit.Name == parameters[1] and unit:WaitForChild("Info").Owner.Value == game.Players.LocalPlayer.Name then
                    local magnitude = (unit.HumanoidRootPart.Position - TableToCFrame(parameters[2]).Position).magnitude
                    if magnitude == 0 then
                        game:GetService("ReplicatedStorage").Remote.SellUnit:InvokeServer(unpack(args))
                    end
                end
            end
        end
        if parameters[1] == "SkipWave" and JSON.macro_skipwave then
            if game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").Visible then
                game:GetService("ReplicatedStorage").Remote.SkipEvent:FireServer()
            end
        end

        task.wait(0.24)
    end
end

function CFrameToTable(cframe)
    local position = cframe.Position
    local lookVector = cframe.LookVector
    local rightVector = cframe.RightVector

    local pitch = math.asin(-lookVector.Y)
    local yaw = math.atan2(lookVector.X, lookVector.Z)
    local roll = math.atan2(-rightVector.Y, rightVector.X)

    return {
        Position = { position.X, position.Y, position.Z },
        Angles = { pitch, yaw, roll }
    }
end

function TableToCFrame(cframeTable)
    local position = cframeTable.Position
    local angles = cframeTable.Angles

    local cframe = CFrame.new(position[1], position[2], position[3])
    cframe = cframe * CFrame.Angles(angles[1], angles[2], angles[3])

    return cframe
end

if game.PlaceId ~= 6558526079 then
    local game_metatable = getrawmetatable(game)
    local namecall_original = game_metatable.__namecall

    setreadonly(game_metatable, false)

    game_metatable.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local Args = { ... }
        local money

        if Args and (method == "FireServer" or method == "InvokeServer") then
            if JSON.macro_record and not JSON.macro_playback then
                money = GetMoney()
                if self.Name == "SpawnUnit" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {
                            [1] = Args[1],
                            [2] = CFrameToTable(Args[2]),
                            [3] = self.Name
                        },
                        [3] = money
                    })
                elseif self.Name == "UpgradeUnit" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {
                            [1] = Args[1].Name,
                            [2] = CFrameToTable(Args[1].HumanoidRootPart.CFrame), -- Convert CFrame to table
                            [3] = self.Name
                        },
                        [3] = money
                    })
                elseif self.Name == "ChangeUnitModeFunction" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {
                            [1] = Args[1].Name,
                            [2] = CFrameToTable(Args[1].HumanoidRootPart.CFrame), -- Convert CFrame to table
                            [3] = self.Name
                        }
                    })
                elseif self.Name == "SellUnit" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {
                            [1] = Args[1].Name,
                            [2] = CFrameToTable(Args[1].HumanoidRootPart.CFrame), -- Convert CFrame to table
                            [3] = self.Name
                        }
                    })
                elseif self.Name == "SkipEvent" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {
                            [1] = self.Name
                        }
                    })
                end

                task.spawn(function()
                    Save()
                end)
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
    while JSON.auto_2x do
        if workspace.TimeSpeed.Value ~= 2 then
            local args = {
                [1] = "x1 Speed"
            }

            game:GetService("ReplicatedStorage").Remote.x2Event:FireServer(unpack(args))
        end
        wait()
    end
end

function JoinGame()
    task.wait(JSON.auto_join_delay)

    if not JSON.auto_join_game then
        return
    end

    local args = {}
    if JSON.auto_join_mode == "Story" then
        if JSON.auto_join_level then
            args = {
                [1] = {
                    ["StageSelect"] = tostring(JSON.auto_join_level),
                    ["Image"] = "",
                    ["FriendOnly"] = true,
                    ["Difficult"] = JSON.auto_join_difficulty
                }

            }
            game:GetService("ReplicatedStorage").Remote.CreateRoom:FireServer(unpack(args))
            task.wait(1)
            clickUI(game.Players.LocalPlayer.PlayerGui.InRoomUi.RoomUI.QuickStart.TextButton)
            task.wait(60)
            if JSON.auto_join_game then
                Teleport()
            end
        end

    elseif JSON.auto_join_mode == "Endless" then
        if JSON.auto_join_endless_mode then
            args = {
                [1] = {
                    ["StageSelect"] = tostring(JSON.auto_join_endless_mode),
                    ["Image"] = "",
                    ["FriendOnly"] = true,
                    ["Difficult"] = JSON.auto_join_difficulty
                }

            }
            game:GetService("ReplicatedStorage").Remote.CreateRoom:FireServer(unpack(args))
            task.wait(1)
            clickUI(game.Players.LocalPlayer.PlayerGui.InRoomUi.RoomUI.QuickStart.TextButton)
            task.wait(60)
            if JSON.auto_join_game then
                Teleport()
            end
        end
    elseif JSON.auto_join_mode == "Event" then
        if JSON.auto_join_event_stage then
            args = {
                [1] = {
                    ["StageSelect"] = tostring(JSON.auto_join_event_stage),
                    ["Image"] = "",
                    ["FriendOnly"] = true,
                    ["Difficult"] = JSON.auto_join_difficulty
                }

            }
            game:GetService("ReplicatedStorage").Remote.CreateRoom:FireServer(unpack(args))
            task.wait(1)

            task.wait(60)
            if JSON.auto_join_game then
                Teleport()
            end
        end
    elseif JSON.auto_join_mode == "Raid" then
        if JSON.auto_join_raid_stage then
            args = {
                [1] = {
                    ["StageSelect"] = tostring(JSON.auto_join_raid_stage),
                    ["Image"] = "",
                    ["FriendOnly"] = true,
                    ["Difficult"] = JSON.auto_join_difficulty
                }

            }
            game:GetService("ReplicatedStorage").Remote.CreateRoom:FireServer(unpack(args))
            task.wait(1)
            clickUI(game.Players.LocalPlayer.PlayerGui.InRoomUi.RoomUI.QuickStart.TextButton)
            task.wait(60)
            if JSON.auto_join_game then
                Teleport()
            end
        end
    elseif JSON.auto_join_mode == "Legend Stages" then
        if JSON.auto_join_endless_mode then
            args = {
                [1] = {
                    ["StageSelect"] = tostring(JSON.auto_join_endless_mode),
                    ["Image"] = "",
                    ["FriendOnly"] = true,
                    ["Difficult"] = JSON.auto_join_difficulty
                }

            }
            game:GetService("ReplicatedStorage").Remote.CreateRoom:FireServer(unpack(args))
            task.wait(1)
            clickUI(game.Players.LocalPlayer.PlayerGui.InRoomUi.RoomUI.QuickStart.TextButton)

            task.wait(60)
            if JSON.auto_join_game then
                Teleport()
            end
        end
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

    if workspace.StageSelect ~= nil then
        local stageValue = workspace.StageSelect.Value

        if tonumber(stageValue) then
            stageValue = tonumber(stageValue)
            local selectedWorld = getWorldByStage(stageValue, macroMapList)

            if selectedWorld then
                print("Selected stage:", stageValue)
                print("The world is:", selectedWorld)

                if JSON.Macro_Maps_Profile["Story"] and JSON.Macro_Maps_Profile["Story"][selectedWorld] then
                    JSON.macro_profile = JSON.Macro_Maps_Profile["Story"][selectedWorld]
                else
                    print("World profile not found for:", selectedWorld)
                end
            else
                print("World not found for the selected stage:", stageValue)
            end
        elseif table.find(macroMapList.Raid, stageValue) then
            print("Selected Raid:", stageValue)
            if JSON.Macro_Maps_Profile["Raid"] and JSON.Macro_Maps_Profile["Raid"][stageValue] then
                JSON.macro_profile = JSON.Macro_Maps_Profile["Raid"][stageValue]
            end
        elseif table.find(macroMapList["Infinite"], stageValue) then
            print("Selected Infinite:", stageValue)
            if JSON.Macro_Maps_Profile["Infinite"] and JSON.Macro_Maps_Profile["Infinite"][stageValue] then
                JSON.macro_profile = JSON.Macro_Maps_Profile["Infinite"][stageValue]
            end
        elseif table.find(macroMapList["Legend Stage"], stageValue) then
            print("Selected Stage:", stageValue)
            if JSON.Macro_Maps_Profile["legend_stage"] and JSON.Macro_Maps_Profile["legend_stage"][stageValue] then
                JSON.macro_profile = JSON.Macro_Maps_Profile["legend_stage"][stageValue]
            end
        elseif table.find(macroMapList["Event"], stageValue) then
            print("Selected Stage:", stageValue)
            if JSON.Macro_Maps_Profile["EventStage"] and JSON.Macro_Maps_Profile["EventStage"][stageValue] then
                JSON.macro_profile = JSON.Macro_Maps_Profile["EventStage"][stageValue]
            end
        end
    else
        print("StageSelect not found in workspace.")
    end

    if JSON.macro_playback then
        task.spawn(MacroPlayback)
    end

    if JSON.auto_join_increment_story then
        task.spawn(StartAutomaticNextButton)
    end

    if JSON.auto_replay then
        task.spawn(StartAutomaticReplayButton)
    end

    if JSON.auto_start_game then
        task.spawn(function()
            while JSON.auto_start_game do
                if not game.Workspace:FindFirstChild("PlayerPortal") then
                    if game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").Visible and
                        game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").topic.Text ==
                        "[Ready]" then
                        game:GetService("ReplicatedStorage").Remote.SkipEvent:FireServer()
                    end
                end
                task.wait()
            end
        end)
    end
    task.spawn(StartMacroTimer)
else
    if JSON.auto_join_game then
        task.spawn(JoinGame)
    end
end
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Sapphire Hub",
    LoadingTitle = "Anime World Tower Defense",
    LoadingSubtitle = "by saintfulls",
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
        Key = { "Hello" }
    }
})

local StoryDropDown = {}

local Tabs = {
    Game = Window:CreateTab("Game", 4483362458),
    Lobby = Window:CreateTab("Lobby", 4483362458),
    Macro = Window:CreateTab("Macro", 4483362458),
    MacroMaps = Window:CreateTab("Macro Maps", 4483362458),
    Webhook = Window:CreateTab("Webhook", 4483362458),
    Miscellaneous = Window:CreateTab("Miscellaneous", 4483362458)
}

local Game_Main = Tabs.Game:CreateSection("Toggles")

Tabs.Game:CreateToggle({
    Name = "Automatic Start/Skip",
    CurrentValue = JSON.auto_start_game,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.auto_start_game = Value
        Save()
        while Value do
            if not game.Workspace:FindFirstChild("PlayerPortal") and not JSON.macro_playback then
                if game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").Visible and
                    game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").topic.Text ==
                    "[Ready]" then
                    game:GetService("ReplicatedStorage").Remote.SkipEvent:FireServer()
                elseif game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").Visible and
                    game.Players.LocalPlayer.PlayerGui:WaitForChild("InterFace"):WaitForChild("Skip").topic.Text ==
                    "Skip?" then
                    game:GetService("ReplicatedStorage").Remote.SkipEvent:FireServer()
                end
            end
            task.wait()
        end
    end
})

Tabs.Game:CreateToggle({
    Name = "Automatic 2x Speed",
    CurrentValue = JSON.auto_2x,
    Flag = "Toggle1",
    Callback = function(value)
        JSON.auto_2x = value
        Save()

        if value and not game.Workspace:FindFirstChild("PlayerPortal") then
            task.spawn(AutomaticChangeSpeed)
        end
    end
})



local Lobby_Main = Tabs.Lobby:CreateSection("Modes")

Tabs.Lobby:CreateDropdown({
    Name = "Game modes",
    Options = { "Story", "Endless", "Raid", "Event", "Legend Stages" },
    CurrentOption = { JSON.auto_join_mode },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        JSON.auto_join_mode = Option[1]
        Save()
    end
})

Tabs.Lobby:CreateToggle({
    Name = "Auto Join Game",
    CurrentValue = JSON.auto_join_game,
    Flag = "Toggle1",
    Callback = function(value)
        JSON.auto_join_game = value
        Save()

        if value and game.Workspace:FindFirstChild("PlayerPortal") then
            task.spawn(JoinGame)
        end
    end
})

Tabs.Lobby:CreateSection("Stages")
Tabs.Lobby:CreateDropdown({
    Name = "Raid Mode",
    Options = macroMapList.Raid,
    CurrentOption = { JSON.auto_join_raid_stage },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        JSON.auto_join_raid_stage = Option[1]
        Save()
    end
})

Tabs.Lobby:CreateDropdown({
    Name = "Event Stage",
    Options = macroMapList.Event,
    CurrentOption = { JSON.auto_join_event_stage },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        JSON.auto_join_event_stage = Option[1]
        Save()
    end
})

Tabs.Lobby:CreateDropdown({
    Name = "Endless Mode",
    Options = macroMapList["Infinite"],
    CurrentOption = { JSON.auto_join_endless_mode },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        JSON.auto_join_endless_mode = Option[1]
        Save()
    end
})

Tabs.Lobby:CreateDropdown({
    Name = "Legend Stage",
    Options = macroMapList["Legend Stage"],
    CurrentOption = { JSON.auto_join_legend_stage },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        JSON.auto_join_legend_stage = Option[1]
        Save()
    end
})

local Lobby_Second = Tabs.Lobby:CreateSection("Settings")

Tabs.Lobby:CreateToggle({
    Name = "Auto Next Level",
    CurrentValue = JSON.auto_join_increment_story,
    Flag = "Toggle1",
    Callback = function(value)
        JSON.auto_join_increment_story = value
        Save()
        if value then
            task.spawn(StartAutomaticNextButton)
        end
    end
})

Tabs.Lobby:CreateToggle({
    Name = "Auto Replay",
    CurrentValue = JSON.auto_replay,
    Flag = "Toggle1",
    Callback = function(value)
        JSON.auto_replay = value
        Save()
        if value then
            task.spawn(StartAutomaticReplayButton)
        end
    end
})




local StoryLevel = 0
local ClearedStages = game.Players.LocalPlayer.Data.ClearedStages.Value

local stageValues = string.split(ClearedStages, ",")

for _, stage in ipairs(stageValues) do
    local stageNum = tonumber(stage)
    if stageNum and stageNum > StoryLevel then
        StoryLevel = stageNum + 1
    end
end

if JSON.auto_join_level > StoryLevel then
    JSON.auto_join_level = StoryLevel
    Save()
end

Tabs.Lobby:CreateDropdown({
    Name = "Difficulty",
    Options = { "Normal", "Insane", "Nightmare", "Challenger" },
    CurrentOption = { JSON.auto_join_difficulty },
    MultipleOptions = false,
    Flag = "Dropdown1",
    Callback = function(Option)
        JSON.auto_join_difficulty = Option[1]
        Save()
    end
})

Tabs.Lobby:CreateSlider({
    Name = "Story Mode Level",
    Range = { 1, StoryLevel },
    Increment = 1,
    Suffix = "level",
    CurrentValue = JSON.auto_join_level,
    Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        JSON.auto_join_level = Value
        Save()
    end
})
Tabs.Lobby:CreateSlider({
    Name = "Auto Join Delay",
    Range = { 0, 60 },
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = JSON.auto_join_delay,
    Flag = "Slider1",
    Callback = function(Value)
        JSON.auto_join_delay = Value
        Save()
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
    CurrentOption = { JSON.macro_profile },
    MultipleOptions = false,
    Callback = function(Option)
        JSON.macro_profile = Option[1]
        if Macros[JSON.macro_profile] == nil then
            Macros[JSON.macro_profile] = {}
        end

        Save()

        Rayfield:Notify({
            Title = "Macro Profile",
            Content = "Using " .. JSON.macro_profile,
            Duration = 6.5,
            Image = 4483362458,
            Actions = {    -- Notification Buttons

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
                Actions = {    -- Notification Buttons

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

                    Ignore = {
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
    Name = "Macro Playback",
    CurrentValue = JSON.macro_playback,
    Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        JSON.macro_playback = Value
        Save()

        if Value then
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

Tabs.Macro:CreateButton({
    Name = "Create Profile",
    Callback = function()
        if Macros[profile_name] ~= nil then
            Rayfield:Notify({
                Title = "Macro Profile",
                Content = "Macro already exists :" .. profile_name,
                Duration = 6.5,
                Image = 4483362458,
                Actions = {

                    Ignore = {
                        Name = "Okay!",
                        Callback = function()

                        end
                    }

                }
            })
        else
            Macros[profile_name] = {}
            JSON.macro_profile = profile_name

            for _, dropdown in ipairs(StoryDropDown) do
                dropdown:Refresh()
            end
            Save()

            table.insert(profile_list, profile_name)

            Macro_list:Refresh(profile_list)
            Macro_list:Set(profile_name)
        end
    end
})

Tabs.Macro:CreateButton({
    Name = "Clear Profile",
    Callback = function()
        Macros[JSON.macro_profile] = {}
        Save()
    end
})

Tabs.Macro:CreateButton({
    Name = "Delete Profile",
    Callback = function()
        if table.getn(profile_list) == 1 then
            Rayfield:Notify({
                Title = "Macro Profile",
                Content = "Can't delete last profile",
                Duration = 6.5,
                Image = 4483362458,
                Actions = {

                    Ignore = {
                        Name = "Okay!",
                        Callback = function()

                        end
                    }

                }
            })
            return
        else
            local removed_profile_name = JSON.macro_profile
            delfile(folder_name .. "/" .. JSON.macro_profile .. ".json")
            Macros[JSON.macro_profile] = nil
            table.remove(profile_list, table.find(profile_list, removed_profile_name))

            for _, v in pairs(profile_list) do
                if v ~= nil then
                    JSON.macro_profile = v
                    break
                end
            end

            Save()

            for _, dropdown in ipairs(StoryDropDown) do
                dropdown:Refresh()
            end

            Macro_list:Refresh(profile_list)
            Macro_list:Set(JSON.macro_profile)
        end
    end
})

local Macro_Settings = Tabs.Macro:CreateSection("Playback Settings")

Tabs.Macro:CreateToggle({
    Name = "Summon Unit",
    CurrentValue = JSON.macro_summon,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_summon = Value
        Save()
    end
})

Tabs.Macro:CreateToggle({
    Name = "Sell Unit",
    CurrentValue = JSON.macro_sell,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_sell = Value
        Save()
    end
})

Tabs.Macro:CreateToggle({
    Name = "Upgrade Unit",
    CurrentValue = JSON.macro_upgrade,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_upgrade = Value
        Save()
    end
})

Tabs.Macro:CreateToggle({
    Name = "Change Unit Priority",
    CurrentValue = JSON.macro_changepriority,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_changepriority = Value
        Save()
    end
})

Tabs.Macro:CreateToggle({
    Name = "Skip Wave",
    CurrentValue = JSON.macro_skipwave,
    Flag = "Toggle1",
    Callback = function(Value)
        JSON.macro_skipwave = Value
        Save()
    end
})

Tabs.MacroMaps:CreateSection("Story")

for tabName, mapsList in pairs(macroMapList) do
    for _, mapName in ipairs(mapsList) do
        if tabName == "Story" then
            local dropdown = Tabs.MacroMaps:CreateDropdown({
                Name = mapName.name,
                Options = profile_list,
                CurrentOption = { JSON.Macro_Maps_Profile["Story"][mapName.name] },
                MultipleOptions = false,
                Callback = function(Option)
                    JSON.Macro_Maps_Profile["Story"][mapName.name] = Option[1]
                    Save()

                    Rayfield:Notify({
                        Title = "Macro Maps Profile",
                        Content = "Using " .. JSON.Macro_Maps_Profile["Story"][mapName.name],
                        Duration = 6.5,
                        Image = 4483362458,
                        Actions = {    -- Notification Buttons

                            Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                                Name = "Okay!",
                                Callback = function()

                                end
                            }

                        }
                    })
                end
            })
            table.insert(StoryDropDown, dropdown)
        end
    end
end

Tabs.MacroMaps:CreateSection("Raid")

for tabName, mapsList in pairs(macroMapList) do
    for _, mapName in ipairs(mapsList) do
        if tabName == "Raid" then
            local dropdown = Tabs.MacroMaps:CreateDropdown({
                Name = mapName,
                Options = profile_list,
                CurrentOption = { JSON.Macro_Maps_Profile["Raid"][mapName] },
                MultipleOptions = false,
                Callback = function(Option)
                    JSON.Macro_Maps_Profile["Raid"][mapName] = Option[1]
                    Save()

                    Rayfield:Notify({
                        Title = "Macro Maps Profile",
                        Content = "Using " .. JSON.Macro_Maps_Profile["Raid"][mapName],
                        Duration = 6.5,
                        Image = 4483362458,
                        Actions = {    -- Notification Buttons

                            Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                                Name = "Okay!",
                                Callback = function()

                                end
                            }

                        }
                    })
                end
            })
            table.insert(StoryDropDown, dropdown)
        end
    end
end

Tabs.MacroMaps:CreateSection("Endless")

for tabName, mapsList in pairs(macroMapList) do
    for _, mapName in ipairs(mapsList) do
        if tabName == "Infinite" then
            local dropdown = Tabs.MacroMaps:CreateDropdown({
                Name = mapName,
                Options = profile_list,
                CurrentOption = { JSON.Macro_Maps_Profile["Infinite"][mapName] },
                MultipleOptions = false,
                Callback = function(Option)
                    JSON.Macro_Maps_Profile["Infinite"][mapName] = Option[1]
                    Save()

                    Rayfield:Notify({
                        Title = "Macro Maps Profile",
                        Content = "Using " .. JSON.Macro_Maps_Profile["Infinite"][mapName],
                        Duration = 6.5,
                        Image = 4483362458,
                        Actions = {    -- Notification Buttons

                            Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                                Name = "Okay!",
                                Callback = function()

                                end
                            }

                        }
                    })
                end
            })
            table.insert(StoryDropDown, dropdown)
        end
    end
end
Tabs.MacroMaps:CreateSection("Legend Stage")

for tabName, mapsList in pairs(macroMapList) do
    for _, mapName in ipairs(mapsList) do
        if tabName == "Legend Stage" then
            local dropdown = Tabs.MacroMaps:CreateDropdown({
                Name = mapName,
                Options = profile_list,
                CurrentOption = { JSON.Macro_Maps_Profile["legend_stage"][mapName] },
                MultipleOptions = false,
                Callback = function(Option)
                    JSON.Macro_Maps_Profile["legend_stage"][mapName] = Option[1]
                    Save()

                    Rayfield:Notify({
                        Title = "Macro Maps Profile",
                        Content = "Using " .. JSON.Macro_Maps_Profile["legend_stage"][mapName],
                        Duration = 6.5,
                        Image = 4483362458,
                        Actions = {    -- Notification Buttons

                            Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
                                Name = "Okay!",
                                Callback = function()

                                end
                            }

                        }
                    })
                end
            })
            table.insert(StoryDropDown, dropdown)
        end
    end
end

Tabs.MacroMaps:CreateSection("Event")

for tabName, mapsList in pairs(macroMapList) do
    for _, mapName in ipairs(mapsList) do
        if tabName == "Event" then
            local dropdown = Tabs.MacroMaps:CreateDropdown({
                Name = mapName,
                Options = profile_list,
                CurrentOption = { JSON.Macro_Maps_Profile["EventStage"][mapName] },
                MultipleOptions = false,
                Callback = function(Option)
                    JSON.Macro_Maps_Profile["EventStage"][mapName] = Option[1]
                    Save()

                    Rayfield:Notify({
                        Title = "Macro Maps Profile",
                        Content = "Using " .. JSON.Macro_Maps_Profile["EventStage"][mapName],
                        Duration = 6.5,
                        Image = 4483362458,
                        Actions = {
                            Ignore = {
                                Name = "Okay!",
                                Callback = function()

                                end
                            }

                        }
                    })
                end
            })
            table.insert(StoryDropDown, dropdown)
        end
    end
end


function clickUI(gui)
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")

    local GuiService = game:GetService("GuiService")
    GuiService.SelectedObject = gui

    local mousePosition = UserInputService:GetMouseLocation()

    if gui.AbsolutePosition.X <= mousePosition.X and mousePosition.X <= gui.AbsolutePosition.X + gui.AbsoluteSize.X and
        gui.AbsolutePosition.Y <= mousePosition.Y and mousePosition.Y <= gui.AbsolutePosition.Y + gui.AbsoluteSize.Y then
        VirtualInputManager:SendMouseButtonEvent(mousePosition.X, mousePosition.Y, Enum.UserInputType.MouseButton1, true,
            game)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(mousePosition.X, mousePosition.Y, Enum.UserInputType.MouseButton1, false,
            game)
    else
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end
end
