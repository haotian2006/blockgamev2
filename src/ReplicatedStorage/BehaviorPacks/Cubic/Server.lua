local Types = require(game.ReplicatedStorage.ModHandler)
local MH:Types.AutoFill = Types
local Server = {}
local Remotes = MH.Remote
local BlockPlace = Remotes.GetRemote("BlockPlace")
local PlaceBlockFunction = MH.Behaviors.Getfunction("PlaceBlockServer")
local Behaviors = MH.Behaviors
local resource = MH.Resources
local data = MH.DataHandler
local qf = MH.Functions
local rotation = require(game.ReplicatedStorage.Utils.RotationUtils)
BlockPlace.OnServerEvent:Connect(function(plr,coords1,ori)
    if data.GetEntityFromPlayer(plr) and data.GetEntityFromPlayer(plr):GetState('Dead') then return end  
    
    local coords = coords1  
    local plre = data.GetEntityFromPlayer(plr)
    local item = plre.HoldingItem or {}
    item = qf.deepCopy(item)
    if item[1] and ori then
        do
            local block = resource.IsBlock(item[1])
            block = Behaviors.GetBlock(block)
            block = block.components
            local x,y,z = unpack(ori:split(","))
            x = block.RotateX and x or 0 
            y = block.RotateY and y or 0
            z = block.RotateZ and z or 0
            ori = x..','..y..','..z
        end
        item[1] ..= ','..rotation.keyPairs[ori]
    end
    --print(item)
    if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z) and item[1] and resource.IsBlock(item[1]) and not data.GetBlock(coords.X,coords.Y,coords.Z) then 
        data.PlaceBlockGLOBAL(coords1.X,coords1.Y,coords1.Z,item[1])
    end
end)
function  Server:Init()
    
end
return Server