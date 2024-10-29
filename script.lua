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
    auto_join_level = 1,
}

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
    writefile(folder_name .. "\\" .. "Default Profile.json",
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
        writefile(folder_name .. "\\" .. profile_name .. ".json", game:GetService("HttpService"):JSONEncode(save_data))
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
    print(v)
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

local game_metatable = getrawmetatable(game)
local namecall_original = game_metatable.__namecall

setreadonly(game_metatable, true)

game_metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local script = getcallingscript()

    local Args = {...}

    if Args ~= nil and (method == "FireServer" or method == "InvokeServer") then
        if self.Name == "SpawnUnit" then

        elseif self.Name == "UpgradeUnit" then

        elseif self.Name == "ChangeUnitModeFunction" then

        elseif self.Name == "SellUnit" then

        elseif self.Name == "SkipEvent" then

        end

        return namecall_original(self, ...)
    end
end)

-- jjgeongezubgezbgihegey_geuizegog_e_go_egeheuiuhgeihgeihegiohegihegiezghiuohegzhiegzieguotoezghiheghegoegzheiguohegzhiezghiegheghzeghzihegzehgziezghiuge
