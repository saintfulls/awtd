local game_metatable = getrawmetatable(game)
local namecall_original = game_metatable.__namecall

setreadonly(game_metatable, false)

game_metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local Args = {...}
    local money

    if Args and (method == "FireServer" or method == "InvokeServer") then
        if JSON.macro_record and not JSON.macro_playback then
            local player = game.Players.LocalPlayer
            local leaderstats = player:FindFirstChild("leaderstats")

         
            if Args[1] ~= nil and leaderstats and leaderstats:FindFirstChild("Cash") and game.PlaceId ~= 6558526079 then
                money = GetMoney()
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
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {
                            [1] = Args[1],
                            [2] = CFrameToTable(Args[2])
                        },
                        [3] = money
                    })
                elseif self.Name == "ChangeUnitModeFunction" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {}
                    })
                elseif self.Name == "SellUnit" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {
                            [1] = Args[1],
                            [2] = CFrameToTable(Args[2])
                        }
                    })
                elseif self.Name == "SkipEvent" then
                    table.insert(Macros[JSON.macro_profile], {
                        [1] = timeElapsed(),
                        [2] = {}
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
