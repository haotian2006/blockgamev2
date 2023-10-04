local funcs = {}
local SharedChunk = require(script.Parent.ChunkShared)
local ResourcePacks = require(game.ReplicatedStorage.ResourceHandler)
local gamesettings = require(game.ReplicatedStorage.GameSettings)
local settings = gamesettings
local chx = settings.ChunkSize.X
local chy = settings.ChunkSize.Y
local function CreateBorder(lx,lz)
    return {
        lx+1 >= chx,
        lx-1 <= -1,
        lz+1 >= chx ,
        lz-1 <= -1
    },`{lx+1 >= chx},{lx-1 <= -1},{lz+1 >= chx},{lz-1 <= -1}`
end
local borders = {}
local nchx = chx-1

do
    local temp = {}
    for x =0,nchx do
        for z = 0,nchx do
            local id = x + z *chx + 1
            local info,str = CreateBorder(x,z)
            borders[id] = temp[str] or info
            temp[str] = info
        end
    end
    temp = nil
end
local function GetBorders(lx,lz)
    return borders[lx + lz *chx + 1]
end
    
local farea3 = (chx)*(chy) 
function funcs.cullSection(cx,cz,quadx,quadz)
    local current = (SharedChunk:Get(`{cx},{cz}`)[1])
    local found = {SharedChunk:Get(`{cx+1},{cz}`)[1],SharedChunk:Get(`{cx-1},{cz}`)[1],SharedChunk:Get(`{cx},{cz+1}`)[1],SharedChunk:Get(`{cx},{cz-1}`)[1]}
    local foundidx = {}
    local resource = {}
    local function checkBlock(x,y,z,chunk)
        local id = gamesettings.to1D(x,y,z)
        if not id then return end 
        local g = foundidx[id]
        if g ~= nil then return g end 
        local ch = chunk and found[chunk] or current
        local data = ch[id]
        if not data then   foundidx[id] = false return false end 
        if resource[data] == nil then
            local type,ori,id2 = data:match("([^,]*),?([^,]*),?([^,]*)")
            local d = ResourcePacks.Blocks[type]
            local flag = d.Transparency
            if flag and flag ~= 0 then else flag = false  end
            resource[data] = d and not flag
        end
        foundidx[id]=  resource[data]
        return resource[data]
    end
    local b1,b2,b3,b4
    local function cull(x,y,z)
        local num = 0
        if b1 then
            if checkBlock(0,y,z,1) then num +=1 end 
        else
            if checkBlock(x+1,y,z) then num +=1 end 
        end
        if b2 then
            if checkBlock(7,y,z,2) then num +=2 end 
        else
            if checkBlock(x-1,y,z) then num +=2 end 
        end
        if checkBlock(x,y+1,z) then num +=4 end 
        if checkBlock(x,y-1,z) then num +=8 end 
        if b3 then
            if checkBlock(x,y,0,3) then num +=16 end 
        else
            if checkBlock(x,y,z+1) then num +=16  end 
        end
        if b4 then
            if checkBlock(x,y,7,4) then num +=32 end 
        else
            if checkBlock(x,y,z-1) then num +=32  end 
        end
        return num == 63,num
    end
    local loc = {}
    local count = 1
    debug.profilebegin("cull")
    for qx =0,4-1 do
		local x = qx+4*quadx
		for qz  =0,4-1 do
			local z = qz+4*quadz
            b1,b2,b3,b4 = unpack(GetBorders(x,z))
            for y = 0,255 do
               local idx = gamesettings.to1D(x,y,z)
               if not current[idx] then continue end 
               local can,i = cull(x,y,z)
               if not can then
                loc[count] = Vector2int16.new(idx,i)
                count +=1 
               end
            end
        end
     end
     debug.profileend()
     return loc
end
return funcs