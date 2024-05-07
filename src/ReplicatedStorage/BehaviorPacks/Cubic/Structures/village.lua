local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end 

local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local IndexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)

local Carver = require(game.ServerStorage.Generation.math.Carver2)
local to1dXZ = IndexUtils.to1DXZ
local Storage = unpack(require(game.ServerStorage.core.Chunk.Generator.ChunkAndStorage))
local to1d = IndexUtils.to1D
local Block = require(game.ReplicatedStorage.Handler.Block)

return  {
    Alias = "c:village",
    chance = 500,
    override = 2,
    layout = {
        key = {
            "c:wood","c:leaf","c:plank",0
        },
        shape = function(CarvedOut,cx,cz,ofx,height,ofz,strut,random:Random)
            local path = Block.compress(2, 1)
            local hut = strut.layout.hut
            local rx,rz = cx*8+ofx,cz*8+ofz
            local surface 
            local currentBuffer
            local function update(cx_,cz_)
                local c = Vector3.new(cx_,0,cz_)
                currentBuffer = Storage.getFeatureBuffer(c)
                local data = Storage.getChunkData(c)
                if not data or not currentBuffer then return false end 
                surface = data.Surface
                if not surface then return false end 
                cx,cz = cx_,cz_
                return true
            end
            update(cx,cz)
            local function branch(rx,rz,dir,chance)
                if chance == 0 then return end 
                if random:NextInteger(1, 100) > chance then return end 
                local range = random:NextInteger(5, 60)
                local interval = 7
                for o =0,range do
                    interval-=1
                    local x = 0
                    local z =0
                    if dir == 1 then
                        x = rx+o
                    elseif dir == 2 then
                        z = rz+o
                    elseif dir == 3 then
                        x = rx-o
                    elseif dir == 4 then
                        z = rz -o
                    end
                    for i =0,1 do
                        local sign = if i == 0 then -1 else 1
                        if dir == 1 or dir ==3 then
                            z = rz+i
                        elseif dir == 2 or dir == 4 then
                            x = rx+i
                        end
                        local chx,chz,xx,_,zz = ConversionUtils.gridToLocalAndChunk(x,height,z)
                        if chx ~= cx or chz ~= cz then
                             update(chx,chz)  
  
                        end
                        if not surface then break end 
                        local idx = to1dXZ[xx][zz]
                        local atHeight = buffer.readu8(surface, idx-1)
                        buffer.writeu32(currentBuffer, (to1d[xx][atHeight][zz]-1)*4, path)
                        if interval <=0 and random:NextInteger(1, 5)  == 1 then
                            interval = 7
                            local x = x
                            local z = z
                             if i == 1 then
                                if dir == 1 then
                                    z+= 3
                                elseif dir == 2 then
                                    x += 3
                                elseif dir == 3 then
                                    z +=3
                                elseif dir == 4 then
                                    x +=3
                                end
                                
                            else
                                if dir == 1 then
                                    z -= 7
                                elseif dir == 2 then
                                    x -=  7
                                elseif dir == 3 then
                                    z -= 7
                                elseif dir == 4 then
                                    x -= 7
                                end
                                
                             end
                            local chx,chz,xx,_,zz = ConversionUtils.gridToLocalAndChunk(x,height,z)
                            Carver.addStructure(chx, chz, xx, atHeight+1, zz, hut, strut.layout.key)
                        end
                     end 
                end

            end
            branch(rx,rz,1,100)
            branch(rx,rz,2,100)
            branch(rx,rz,3,100)
            branch(rx,rz,4,100)
          --  Carver.addStructure(cx, cz, ofx, height, ofz, hut, stru.layout.key, 2, CarvedOut)
        end,
        hut = (function()
            local t = {}
            for x = 0,4 do
                for y = 0,6 do
                    for z = 0,4 do
                        t[Vector3.new(x,y,z)] = 4
                    end
                end
            end

            for i = 0,3 do
                t[Vector3.new(0,i,0)] = 1
            end
            for i = 0,4 do
                t[Vector3.new(4,i,0)] = 1
            end
            for i = 0,4 do
                t[Vector3.new(0,i,4)] = 1
            end
            for i = 0,4 do
                t[Vector3.new(4,i,4)] = 1
            end

            for x =0,4 do
                for z = 0,4 do
                    t[Vector3.new(x,4,z)] = 2
                end
            end
            for x =0,2 do
                for z = 0,2 do
                    t[Vector3.new(x+1,5,z+1)] = 2
                end
            end
            t[Vector3.new(2,6,2)] = 2

           for i=1,3 do
                for y =0,3 do
                    t[Vector3.new(i,y,0)] = 3
                end
           end
           t[Vector3.new(2,0,0)] = 4
           t[Vector3.new(2,1,0)] = 4

            for i=1,3 do
                for y =0,3 do
                    t[Vector3.new(0,y,i)] = 3
                end
            end
            t[Vector3.new(0,0,2)] = 4
            t[Vector3.new(0,1,2)] = 4

            for i=1,3 do
                for y =0,3 do
                    t[Vector3.new(4,y,i)] = 3
                end
            end
            t[Vector3.new(4,0,2)] = 4
            t[Vector3.new(4,1,2)] = 4

            for i=1,3 do
                for y =0,3 do
                    t[Vector3.new(i,y,4)] = 3
                end
           end
           t[Vector3.new(2,0,4)] = 4
           t[Vector3.new(2,1,4)] = 4

            return t
        end)()
    }

}