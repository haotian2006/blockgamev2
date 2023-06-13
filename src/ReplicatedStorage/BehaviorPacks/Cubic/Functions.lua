local func = {}
local ModingMod = require(game.ReplicatedStorage.ModHandler)
export type InputData = {ItemData : {},Index:number,Item:string,InputData:{},Input:string,IsDown:boolean,Controls:{},ItemHandler:{},Player:Player}
func.PlaceBlockServer = function(entity,Block,id)
	local ModingMods:ModingMod.AutoFill = ModingMod
    local lookvector = entity.headdir and entity.headdir.Unit
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
            if hitpos.Y >  coords.Y and block.RotateZ then  orientation[3] = '-0' else
            end
            if angle >=-40 and angle <= - 39 and block.RotateX then
                orientation[1] = 1
            elseif angle >= 39 and angle <=  40 and block.RotateX then
                orientation[1] = -1
            end
            orientation = (orientation[1]..','..orientation[2]..','..orientation[3])
            if orientation == '0,0,0' then 
                orientation =nil
            end
        end
        if data.canPlaceBlockAt(coords.X,coords.Y,coords.Z,data)  then 
            data.InsertBlock(coords.X,coords.Y,coords.Z,item[1]..(orientation and '/O|s%'..orientation or ""))
            entity:PlayAnimation("Place",true)
            ArmsHandler.PlayAnimation('Attack',true)
        end
    end

end
return func 