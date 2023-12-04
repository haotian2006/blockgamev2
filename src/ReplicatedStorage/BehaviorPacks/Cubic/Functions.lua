--!nocheck
local func = {}
local ModingMod = require(game.ReplicatedStorage.ModHandler)
local rotationUtil = require(game.ReplicatedStorage.Utils.RotationUtils)
local MH:ModingMod.AutoFill = ModingMod
type InputData = ModingMod.InputData
func.PlaceBlockServer = function(entity,Block,id)
    do
        return
    end
	local ModingMods:ModingMod.AutoFill = ModingMod
    local lookvector = entity.Headdir and entity.Headdir.Unit
    local behaviorhandler = ModingMods.Behaviors 
    if not lookvector or not  behaviorhandler.GetBlock(Block) or entity:GetState('Dead') then  return end 
    local ResourceHandler = ModingMods.Resources
    local data = ModingMods.DataHandler
    local ArmsHandler = ModingMods.Manager.ArmsManager  
    local math = ModingMods.Math
    local Ray = ModingMods.Ray
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {entity.Id}
    rayinfo.GetNormal = true
    rayinfo.RaySize = Vector3.new(.025,.025,.025)
    local raystuff = Ray.Cast(entity:GetEyePosition(),lookvector*5.1,rayinfo)
    local v = raystuff.Objects[1]
    if  v and v.Type == "Block" then
        local coords = v.BlockPosition+v.Normal
        local hitpos = v.PointOfInt
        local orientation = nil
        local block = behaviorhandler.GetBlock(Block)
        if block and block.components then
            block = block.components
            orientation = {0,0,0}
            local direaction = lookvector
            local angle = math.GetAngleDL(direaction) 
            local dx = math.abs(direaction.X)
            local dz = math.abs(direaction.Z)
            if dx < dz then
                dx = 0
                dz = direaction.Z / dz
            else
                dz = 0 
                dx = direaction.X/dx
            end
            if (dx == -1 or dx == 1) and block.RotateY then orientation[2] = dx end
            if dz == -1 and block.RotateY then
                    orientation[2] = '-0'
            elseif  dz == 1 then
                orientation[3] = 0
            end
            if hitpos.Y >  coords.Y and block.RotateZ then  orientation[3] = '-0' else
            end
            if angle >=-40 and angle <= - 39 and block.RotateX then
                orientation[1] = 1
            elseif angle >= 39 and angle <=  40 and block.RotateX then
                orientation[1] = -1
            end
        end
        local coords1 = coords
        local item = 'T|s%'..Block
        if id then item..='/I|s%'..id end 
        do
            local x,y,z = unpack(orientation)
            x = block.RotateX and x or 0 
            y = block.RotateY and y or 0
            z = block.RotateZ and z or 0
            item ..= '/O|s%'..x..','..y..','..z
        end
        --print(item)
        if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z) and item and not data.GetBlock(coords.X,coords.Y,coords.Z) then 
            data.InsertBlock(coords.X,coords.Y,coords.Z,item)

            require(game.ReplicatedStorage.BridgeNet).CreateBridge("UpdateBlocks"):FireAll({Add = {[coords1.X..','..coords1.Y..','..coords1.Z] = item}})
        end
end

end
local rotation = require(game.ReplicatedStorage.Utils.RotationUtils)
func.PlaceBlockClientO = function(entity,Data:InputData) 
	local ModingMods:ModingMod.AutoFill = ModingMod
	local lookvector = workspace.CurrentCamera.CFrame.LookVector
    local ResourceHandler = ModingMods.Resources 
    local behaviorhandler = ModingMods.Behaviors
    local data = ModingMods.DataHandler
    local ArmsHandler = ModingMods.Manager.ArmsManager
    local math = ModingMods.Math
    local Ray = ModingMods.Ray
    local rayinfo = Ray.newInfo()
	local placeBlockEvent = ModingMods.Remote.GetRemote("BlockPlace")
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {entity.Id}
    rayinfo.GetNormal = true
    rayinfo.RaySize = Vector3.new(.025,.025,.025)
    local raystuff = Ray.Cast(entity.Entity.Eye.Position/3,lookvector*5.1,rayinfo)
    local v = raystuff.Objects[1]
    local item = entity.HoldingItem or {}
    if  v and v.Type == "Block" and item[1] and ResourceHandler.IsBlock(item[1]) then
        local coords = v.BlockPosition+v.Normal
        local hitpos = v.PointOfInt
        local orientation = nil
        local block = ResourceHandler.IsBlock(item[1])
        block = behaviorhandler.GetBlock(block)
        if block and block.components then
            block = block.components
            orientation = {0,0,0}
            local direaction = lookvector
            local angle = math.GetAngleDL(direaction) 
            local dx = math.abs(direaction.X)
            local dz = math.abs(direaction.Z)
            if dx < dz then
                dx = 0
                dz = direaction.Z / dz
            else
                dz = 0
                dx = direaction.X/dx
            end
            if (dx == -1 or dx == 1) and block.RotateY then orientation[2] = dx end
            if dz == -1 and block.RotateY then
                    orientation[2] = '-0'
            elseif  dz == 1 then
                orientation[3] = 0
            end
            if hitpos.Y >  coords.Y and block.RotateZ then  
                orientation[3] = '-0'
            else
            end
            if angle >=-41 and angle <= - 39 and block.RotateX then
                orientation[1] = 1
            elseif angle >= 39 and angle <=  41 and block.RotateX then
                orientation[1] = -1
            end
            orientation = (orientation[1]..','..orientation[2]..','..orientation[3])
            if orientation == '0,0,0' then 
                orientation =nil
            end
          --  print(angle)
        end
        do
            return  
        end
        if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z,data)  then 
            local b= item[1]..(orientation and '_'..rotation.keyPairs[orientation] or "")
           -- print(orientation)
       --     data.InsertBlock(coords.X,coords.Y,coords.Z,b)
            entity:PlayAnimation("Place",true)
            ArmsHandler.PlayAnimation('Attack',true)
            MH.Remote.GetRemote("BlockPlace"):FireServer(coords,orientation)
        end
    end
end
func.PlaceBlockClient = function(entity,Data:InputData)
    local ModingMods:ModingMod.AutoFill = ModingMod
	local lookvector = workspace.CurrentCamera.CFrame.LookVector
    local ResourceHandler = ModingMods.Resources 
    local behaviorhandler = ModingMods.Behaviors
    local data = ModingMods.DataHandler
    local ArmsHandler = ModingMods.Manager.ArmsManager
    local math = ModingMods.Math
    local Ray = ModingMods.Ray
    local rayinfo = Ray.newInfo()
	local placeBlockEvent = ModingMods.Remote.GetRemote("BlockPlace")
    rayinfo.BreakOnFirstHit = true
    rayinfo.BlackList = {entity.Id}
    rayinfo.GetNormal = true
    rayinfo.RaySize = Vector3.new(.025,.025,.025)
    local raystuff = Ray.Cast(entity.Entity.Eye.Position/3,lookvector*5.1,rayinfo)
    local v = raystuff.Objects[1]
    local item = entity.HoldingItem or {}
    if  v and v.Type == "Block" and item[1] and ResourceHandler.IsBlock(item[1]) then
        local coords = v.BlockPosition+v.Normal
        local hitpos = v.PointOfInt
        local block,type = ResourceHandler.IsBlock(item[1])
        block = behaviorhandler.GetBlock(block)
        local orientation = rotationUtil.calculateRotationFromData(block,v,raystuff)
        if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z,data)  then 
            local b= type..(orientation and ','..rotation.keyPairs[orientation] or "")
           -- print(orientation)
       --     data.InsertBlock(coords.X,coords.Y,coords.Z,b)  
            require(game.Players.LocalPlayer.PlayerScripts.Render).updateBlocks(b,coords.X,coords.Y,coords.Z)
            -- entity:PlayAnimation("Place",true)
            -- ArmsHandler.PlayAnimation('Attack',true)
            -- MH.Remote.GetRemote("BlockPlace"):FireServer(coords,b)
        end
    end
end
func.SwordAttack = function(entity,Data:InputData)
    if not entity or entity:GetState('Dead') or entity.Ingui then    return end 
    local Item = Data.ItemData
    local lookvector = workspace.CurrentCamera.CFrame.LookVector
    local Ray = MH.Ray
    local rayinfo = Ray.newInfo()
    rayinfo.BreakOnFirstHit = true 
    rayinfo.BlackList = {tostring(Data.Player.UserId)}
    rayinfo.Debug = false
    rayinfo.RaySize = Vector3.new(.025,.025,.025)
    local raystuff = Ray.Cast(entity.Entity.Eye.Position/3,lookvector*Item.Range,rayinfo)
    if #raystuff.Objects >= 1 then
        local newpos = {}
        for i,v in raystuff.Objects do
            if  v.Type == "Block" then
    
            elseif v.Type == "Entity"  then
                MH.Remote.GetRemote("Damage"):FireServer(v.EntityId,lookvector)
            end
        end
    end
    entity:PlayAnimation("Attack",true)
    MH.Manager.ArmsManager.PlayAnimation('Attack',true)
end
return func 