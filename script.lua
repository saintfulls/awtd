local game_metatable = getrawmetatable(game)
local namecall_original = game_metatable.__namecall

setreadonly(game_metatable, false)

game_metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local script = getcallingscript()

    local Args = {...}

    -- for future offset reference.
    -- game:GetService("Workspace")["Don't Care"].Terrain.Base.Part
    if Args ~= nil and (method == "FireServer" or method == "InvokeServer") then
        print(self.Name)
    end

    return namecall_original(self, ...)
end)
